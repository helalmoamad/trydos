import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/domin/repositories/prefs_repository.dart';

final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

class FileSaving {
  // ───────────────────────── وسائط الدردشة (صور وفيديو) ─────────────────────
  // مخزن دائم على غرار واتساب: مسار حتمي مشتقّ من الرابط داخل مجلّد التطبيق،
  // فيمكن معرفة وجود الملف قبل أي طلب شبكة. FileSaver لا يصلح لهذا لأنه
  // يختار مسار الحفظ بنفسه، فيستحيل الاستدلال عليه في تشغيل لاحق.

  static const int _maxConcurrentDownloads = 3;
  static int _activeDownloads = 0;
  static final List<Completer<void>> _waitingForSlot = [];

  // Map في دارت مرتّبة بالإدراج، فإعادة إدراج المفتاح تنقله إلى الذيل —
  // وهذا كل ما يلزم لـ LRU بسيط.
  static final Map<String, File> _mediaCache = {};
  static final Map<String, Future<File?>> _mediaInFlight = {};
  static Directory? _mediaDir;

  // ── حدود المخزن ──
  static const int _maxCacheBytes = 200 * 1024 * 1024; // السقف: يبدأ الحذف بعده
  static const int _targetCacheBytes = 160 * 1024 * 1024; // ما نهبط إليه
  static const int _maxCacheEntries = 300; // سقف خريطة الذاكرة
  static const Duration _orphanPartMaxAge = Duration(hours: 1);
  static bool _cleanupScheduled = false;

  /// تسجيل مع تحديث الحداثة. يُستدعى عند كل إصابة أيضاً لا عند الإدراج فقط،
  /// وإلا صار الترتيب بترتيب التنزيل لا بترتيب الاستعمال.
  static void _rememberMedia(String fileUrl, File file) {
    _mediaCache.remove(fileUrl);
    _mediaCache[fileUrl] = file;
    while (_mediaCache.length > _maxCacheEntries) {
      _mediaCache.remove(_mediaCache.keys.first);
    }
  }

  /// إخلاء القرص يرتّب بوقت التعديل. أندرويد يُركّب التخزين غالباً بـ noatime
  /// فوقت الوصول غير موثوق، لذا نلمس الملف عند أول قراءة له من القرص في
  /// الجلسة — عملية كتابة واحدة لكل ملف، تكفي لتمييز المستعمل من المهجور.
  static void _touchOnDisk(File file) {
    file.setLastModified(DateTime.now()).catchError((_) {});
  }

  static Future<void> _acquireSlot() {
    if (_activeDownloads < _maxConcurrentDownloads) {
      _activeDownloads++;
      return Future<void>.value();
    }
    final Completer<void> waiter = Completer<void>();
    _waitingForSlot.add(waiter);
    return waiter.future;
  }

  static void _releaseSlot() {
    if (_waitingForSlot.isNotEmpty) {
      _waitingForSlot.removeAt(0).complete(); // ينتقل المقعد دون تصفير العدّاد
    } else if (_activeDownloads > 0) {
      _activeDownloads--;
    }
  }

  Future<Directory> _mediaDirectory() async {
    final Directory? ready = _mediaDir;
    if (ready != null) return ready;
    final Directory docs = await getApplicationDocumentsDirectory();
    final Directory dir = Directory('${docs.path}/chat_media');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    _mediaDir = dir;
    _scheduleCleanup();
    return dir;
  }

  /// يُسلَّح عند أول استعمال للوسائط وبعد كل تنزيل ناجح، مع تهدئة ١٠ ثوانٍ
  /// تمنع تكديس عمليات تنظيف أثناء تدفّق التنزيلات. يُنزَع التسليح في نهاية
  /// كل جولة ليعمل مجدداً — الاكتفاء بمرة واحدة كان يسمح لجلسة طويلة بتجاوز
  /// السقف أضعافاً. ومقصود ألّا يُلمس main.dart: ترتيب تهيئته مسار عالي الخطورة.
  void _scheduleCleanup() {
    if (_cleanupScheduled) return;
    _cleanupScheduled = true;
    Timer(const Duration(seconds: 10), () {
      _cleanupMediaStore()
          .catchError((Object e) => log('media cleanup failed: $e'))
          .whenComplete(() => _cleanupScheduled = false);
    });
  }

  /// يحذف الأقدم استعمالاً حتى الهبوط إلى [_targetCacheBytes]، ويزيل بقايا
  /// `.part` اليتيمة. لا يمسّ ملفاً له تنزيل جارٍ.
  Future<void> _cleanupMediaStore() async {
    final Directory dir = await _mediaDirectory();
    if (!dir.existsSync()) return;

    final DateTime now = DateTime.now();
    final Set<String> busy = _mediaInFlight.keys
        .map((String url) => '${dir.path}/${_fileNameFor(url)}')
        .toSet();

    final List<File> files = <File>[];
    final Map<String, FileStat> stats = <String, FileStat>{};
    int total = 0;

    await for (final FileSystemEntity entity in dir.list()) {
      if (entity is! File) continue;
      final FileStat stat = await entity.stat();

      if (entity.path.endsWith('.part')) {
        // بقايا انهيار أو إنهاء مفاجئ. الجارية منها محميّة بـ busy.
        final String owner =
            entity.path.substring(0, entity.path.length - '.part'.length);
        if (!busy.contains(owner) &&
            now.difference(stat.modified) > _orphanPartMaxAge) {
          await entity.delete().catchError((Object e) {
            log('failed to delete orphan part: $e');
            return entity;
          });
        }
        continue;
      }

      if (busy.contains(entity.path)) continue;
      files.add(entity);
      stats[entity.path] = stat;
      total += stat.size;
    }

    if (total <= _maxCacheBytes) return;

    // الأقدم أولاً — و _touchOnDisk يجعل «الأقدم» تعني الأقل استعمالاً.
    files.sort(
      (File a, File b) =>
          stats[a.path]!.modified.compareTo(stats[b.path]!.modified),
    );

    int remaining = total;
    for (final File file in files) {
      if (remaining <= _targetCacheBytes) break;
      try {
        final int size = stats[file.path]!.size;
        await file.delete();
        remaining -= size;
        _mediaCache.removeWhere((_, File f) => f.path == file.path);
      } catch (e) {
        log('failed to evict ${file.path}: $e');
      }
    }
    log('media cleanup: ${total ~/ 1024}KB -> ${remaining ~/ 1024}KB');
  }

  /// مسح كامل — جاهز لشاشة إعدادات «إدارة التخزين». غير مربوط بواجهة بعد.
  Future<void> clearMediaCache() async {
    final Directory dir = await _mediaDirectory();
    _mediaCache.clear();
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
      dir.createSync(recursive: true);
    }
  }

  /// اسم ملف حتمي وثابت بين تشغيلات التطبيق. يعتمد على مسار الرابط كاملاً لا
  /// على اسمه الأخير وحده، فلا تتصادم صورتان تحملان الاسم نفسه في دردشتين.
  String _fileNameFor(String fileUrl) {
    final Uri? uri = Uri.tryParse(fileUrl);
    final String raw = uri == null ? fileUrl : uri.path; // بلا معاملات استعلام
    final String cleaned = raw.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    // الذيل هو المميّز (الاسم والامتداد)، فنقتصّ من اليسار عند الطول المفرط.
    return cleaned.length <= 120
        ? cleaned
        : cleaned.substring(cleaned.length - 120);
  }

  /// يرجع ملف الوسائط من القرص إن وُجد، وإلا ينزّله. يرجع `null` عند الفشل
  /// أو الإلغاء — ولا يرجع أبداً ملفاً ناقصاً.
  /// [priority] لطلب بادره المستخدم بنفسه (ضغط زرّ تشغيل مثلاً).
  ///
  /// المسبح ذو الثلاثة مقاعد يتشاركه تحميل صور الدردشة التلقائي، فطلب المستخدم
  /// كان يقف خلفها — ومع مهلة استقبال ٦٠ ثانية تحجز صورة متعثّرة مقعداً دقيقةً
  /// كاملة. وأثناء الانتظار لا يصل أي تقدّم فيبدو المؤشّر معلّقاً.
  /// الطلب الصريح يتخطّى الطابور: المستخدم ينتظر أمام الشاشة، والخلفية لا.
  Future<File?> getOrDownloadMedia(
    String fileUrl,
    String chatId, {
    void Function(double percent, int receivedBytes)? onProgress,
    CancelToken? cancelToken,
    bool priority = false,
  }) {
    final File? cached = _mediaCache[fileUrl];
    if (cached != null && cached.existsSync()) {
      _rememberMedia(fileUrl, cached); // إصابة = استعمال حديث
      return Future<File?>.value(cached);
    }

    // كل مستدعٍ يُسجَّل مستمعاً للتقدّم.
    //
    // إزالة التكرار تشارك **نتيجة** التنزيل، وكانت تُسقط `onProgress` كل
    // مستدعٍ بعد الأول — فيبقى مؤشّره عند الصفر وإن كان التنزيل يعمل، ويبدو
    // معلّقاً. القائمة تُبقي الجميع على اطّلاع.
    if (onProgress != null) {
      (_progressListeners[fileUrl] ??= <void Function(double, int)>[]).add(
        onProgress,
      );
    }

    // طلب واحد لكل رابط: الطلبات المتزامنة تتشارك النتيجة بدل الكتابة فوق بعضها.
    return _mediaInFlight[fileUrl] ??=
        _fetchMedia(fileUrl, chatId, cancelToken, priority).whenComplete(() {
          _mediaInFlight.remove(fileUrl);
          _progressListeners.remove(fileUrl);
        });
  }

  /// مستمعو التقدّم لكل رابط: (نسبة، بايتات مستلمة). النسبة `-1` حين يتعذّر
  /// حسابها لغياب `Content-Length`.
  static final Map<String, List<void Function(double, int)>> _progressListeners =
      {};

  static void _notifyProgress(String fileUrl, double percent, int received) {
    final List<void Function(double, int)>? listeners =
        _progressListeners[fileUrl];
    if (listeners == null || listeners.isEmpty) return;
    for (final void Function(double, int) listener in List.of(listeners)) {
      listener(percent, received);
    }
  }

  /// فحص متزامن للذاكرة وحدها — بلا انتظار إطار. يمنع وميض العنصر البديل
  /// عند إعادة بناء الودجت أثناء التمرير لملف نُزّل في هذه الجلسة.
  File? cachedMediaFileSync(String fileUrl) {
    final File? memory = _mediaCache[fileUrl];
    if (memory != null && memory.existsSync()) {
      _rememberMedia(fileUrl, memory);
      return memory;
    }
    // المجلّد معروف بعد أول عملية وسائط في الجلسة، وعندها يمكن فحص القرص
    // متزامناً أيضاً — فتظهر ملفات الجلسات السابقة بلا وميض كذلك.
    final Directory? dir = _mediaDir;
    if (dir == null) return null;
    final File file = File('${dir.path}/${_fileNameFor(fileUrl)}');
    if (file.existsSync() && file.lengthSync() > 0) {
      _touchOnDisk(file); // أول قراءة من القرص في الجلسة
      _rememberMedia(fileUrl, file);
      return file;
    }
    return null;
  }

  /// يرجع الملف إن كان محفوظاً مسبقاً، **دون أي طلب شبكة**. هذا ما يسمح
  /// بتطبيق سياسة الفيديو (لا تنزيل تلقائي) مع تشغيل فوري لما سبق تنزيله.
  Future<File?> cachedMediaFile(String fileUrl) async {
    final File? memory = _mediaCache[fileUrl];
    if (memory != null && memory.existsSync()) {
      _rememberMedia(fileUrl, memory);
      return memory;
    }
    final Directory dir = await _mediaDirectory();
    final File file = File('${dir.path}/${_fileNameFor(fileUrl)}');
    if (file.existsSync() && file.lengthSync() > 0) {
      _touchOnDisk(file);
      _rememberMedia(fileUrl, file);
      return file;
    }
    return null;
  }

  Future<File?> _fetchMedia(
    String fileUrl,
    String chatId,
    CancelToken? cancelToken,
    bool priority,
  ) async {
    final String finalPath;
    try {
      // خارج الـ try الرئيسي: تعذّر إنشاء المجلّد كان يرمي قبل أي التقاط،
      // والمستدعون يستعملون .then بلا catchError فينتج استثناء غير ملتقَط.
      final Directory dir = await _mediaDirectory();
      finalPath = '${dir.path}/${_fileNameFor(fileUrl)}';
      final File finalFile = File(finalPath);

      // موجود من تشغيل سابق: لا شبكة إطلاقاً. هذا ما يجعل الصور تبقى بعد
      // إغلاق التطبيق بدل إعادة تحميلها في كل مرة.
      if (finalFile.existsSync() && finalFile.lengthSync() > 0) {
        _touchOnDisk(finalFile);
        _rememberMedia(fileUrl, finalFile);
        // التسجيل هنا أيضاً لا عند التنزيل وحده: صفحة البروفايل تبني قائمة
        // الوسائط من هذا السجلّ، وبدونه تختفي منها ملفات الجلسات السابقة.
        _prefsRepository.setAFilePathExist('$fileUrl $finalPath', chatId);
        return finalFile;
      }
    } catch (e) {
      log('media directory unavailable for $fileUrl: $e');
      return null;
    }

    // الطلب الصريح لا يحجز مقعداً ولا ينتظر أحداً.
    if (!priority) await _acquireSlot();
    final File part = File('$finalPath.part');
    try {
      // التنزيل إلى ملف مؤقّت ثم إعادة تسميته — عملية ذرّية. بدونها يرى
      // العارض ملفاً ناقصاً يجتاز existsSync ثم يفشل فك ترميزه.
      await Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
      ).download(
        fileUrl,
        part.path,
        cancelToken: cancelToken,
        onReceiveProgress: (rec, total) {
          // `total = -1` حين لا يرسل الخادم Content-Length — وهو شائع في
          // الفيديو. كان الشرط `if (total > 0)` يعني **صمتاً تاماً** حينها:
          // لا تقدّم يصل، فيبقى المؤشّر جامداً وإن كانت البايتات تتدفّق.
          // نبلّغ دائماً: نسبة إن أمكنت، و`-1` مع البايتات إن تعذّرت.
          _notifyProgress(
            fileUrl,
            total > 0 ? (rec / total) * 100 : -1,
            rec,
          );
        },
      );
      if (!part.existsSync() || part.lengthSync() == 0) {
        log('media download produced an empty file: $fileUrl');
        return null;
      }
      final File saved = part.renameSync(finalPath);
      _rememberMedia(fileUrl, saved);
      _prefsRepository.setAFilePathExist('$fileUrl $finalPath', chatId);
      _scheduleCleanup(); // كل إضافة قد تتجاوز السقف
      return saved;
    } catch (e) {
      log('media download failed for $fileUrl: $e');
      return null;
    } finally {
      if (part.existsSync()) part.deleteSync(); // لا نترك بقايا ناقصة
      // لا تحرير لمقعد لم يُحجز — وإلا زاد سعة المسبح عن حدّه.
      if (!priority) _releaseSlot();
    }
  }

  // ──────────────────────────────────────────────────────────────────────────

  getFilePath(String fileName) {
    return savePath + fileName;
  }

  static String savePath =
      '/storage/emulated/0/Android/data/com.example.trydos/files/';

  // FileSaver يكتب باسم مشتقّ من الرابط، أي أن طلبين لنفس الرابط يكتبان
  // نفس المسار. وبما أن كل ImageMessage/VideoMessage/DocumentMessage تُنشئ
  // طلبها الخاص، كان تحميل ثانٍ يقطع ملفاً تعرضه ودجت أخرى فيفشل فك ترميزه.
  // هذان السجلّان يضمنان تحميلاً واحداً لكل رابط على مستوى التطبيق.
  static final Map<String, Future<File?>> _inFlightDownloads = {};
  static final Map<String, File> _completedDownloads = {};

  downloadFileToLocalStorage(String fileUrl, String chatId,
      {void Function(File file)? action}) async {
    final File? done = _completedDownloads[fileUrl];
    if (done != null && done.existsSync()) {
      action?.call(done);
      return done.path;
    }

    final Future<File?> pending =
        _inFlightDownloads[fileUrl] ??= _startDownload(fileUrl, chatId);
    final File? file = await pending;
    // كما في السابق: لا يُستدعى action إلا عند النجاح.
    if (file != null) action?.call(file);
    return file?.path;
  }

  // FileSaver ينزّل عبر حالة مشتركة، والاستدعاءات المتوازية — عشرات منها عند
  // فتح دردشة مليئة بالصور — كانت تُنتج ملفات ناقصة يفشل فك ترميزها، بينما
  // ينجح الطلب المنفرد (زر إعادة المحاولة) دائماً. لذا ننفّذها واحداً تلو الآخر.
  static Future<void> _downloadQueue = Future<void>.value();

  Future<File?> _startDownload(String fileUrl, String chatId) {
    final Completer<File?> completer = Completer<File?>();
    // لا يُرمى شيء خارج هذا الجسم، وإلا انكسرت السلسلة وتوقّفت كل التحميلات.
    _downloadQueue = _downloadQueue.then((_) async {
      try {
        completer.complete(await _saveToDisk(fileUrl, chatId));
      } catch (e) {
        log('download failed for $fileUrl: $e');
        completer.complete(null);
      } finally {
        _inFlightDownloads.remove(fileUrl);
      }
    });
    return completer.future;
  }

  Future<File?> _saveToDisk(String fileUrl, String chatId) async {
    final String fileName = fileUrl.split('/').last;
    final String value = await FileSaver.instance.saveFile(
      name: fileName,
      link: LinkDetails(link: fileUrl),
    );
    _prefsRepository.setAFilePathExist('$fileUrl $value', chatId);
    final File file = File(value);
    if (!file.existsSync()) {
      log('download produced no readable file: $fileUrl -> $value');
      return null;
    }
    _completedDownloads[fileUrl] = file;
    return file;
  }

  /// ينزّل بتقدّم قابل للإلغاء (سياسة الفيديو: تنزيل عند الطلب فقط).
  /// يرجع الملف عند النجاح و`null` عند الفشل أو الإلغاء.
  Future<File?> downloadFileUsingDio(String fileUrl, CancelToken cancelToken,
      String chatId, void Function(double progress) onProgress,
      {void Function(File file)? action}) async {
    final String fileName = fileUrl.split('/').last;
    final Dio dio = Dio();
    final Directory dir = await getApplicationDocumentsDirectory();
    final String filePath = "${dir.path}/$fileName";
    try {
      await dio.download(
        fileUrl,
        filePath,
        cancelToken: cancelToken,
        // deleteOnError كان false صراحةً: الملف الناقص يبقى على القرص فيجتاز
        // existsSync ثم يفشل فك ترميزه. الاعتماد على الافتراضي (true) يحذفه.
        onReceiveProgress: (rec, total) {
          // total = -1 حين لا يرسل الخادم content-length.
          if (total > 0) onProgress.call((rec / total) * 100);
        },
      );
      // الاكتمال يُعرف بانتهاء الطلب، لا بمقارنة تقدّم عشرية بـ 100.
      final File file = File(filePath);
      if (!file.existsSync()) {
        log('dio download produced no file: $fileUrl');
        return null;
      }
      _prefsRepository.setAFilePathExist('$fileUrl $filePath', chatId);
      action?.call(file);
      return file;
    } catch (e) {
      log('dio download failed for $fileUrl: $e');
      return null;
    }
  }

  Future<File?> checkExistence(String? fileUrl, String chatId,
      {bool download = true, void Function(File? file)? action}) async {
    if (fileUrl == null) {
      return null;
    }
    String fileName = fileUrl.split('/').last;
    String path = await getFilePath(fileName);
    debugPrint('check path : $path');
    File file = File(path);
    bool exist = await file.exists();
    debugPrint('exist? : $exist');
    if (exist) {
      return file;
    } else if (download) {
      debugPrint('go to download');
      await downloadFileToLocalStorage(fileUrl, chatId, action: action);
      return null;
    }
    return null;
  }

  /* bool checkExistenceUrl(
    String? fileUrl,
    String chatId,
  ) {
    if (fileUrl == null) {
      return false;
    }
    String fileName = fileUrl.split('/').last;
    String path = getFilePath(fileName);
    List<String> paths = _prefsRepository.getExistenceFiles();
    return paths.any((element) {
      Map? file = jsonDecode(element) ?? {};

      if (file![chatId].toString().split(" ").length > 1) {
        return file[chatId].toString().split(" ")[1].contains(path);
      }
      return false;
    });
  }
*/
  saveFileToSpecificDirectory(File file) async {
    String fileName = file.path.split('/').last;
    String val = await FileSaver.instance.saveFile(name: fileName, file: file);
    log('name : $fileName');
    log('val : $val');
  }
}
