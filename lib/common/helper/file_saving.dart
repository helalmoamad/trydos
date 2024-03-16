import 'dart:convert';
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
  getFilePath(String fileName) {
    return savePath + fileName;
  }

  static String savePath =
      '/storage/emulated/0/Android/data/com.example.trydos/files/';

  downloadFileToLocalStorage(String fileUrl, String chatId,
      {void Function(File file)? action}) async {
    String fileName = fileUrl.split('/').last;
    FileSaver.instance
        .saveFile(
      name: fileName,
      link: LinkDetails(link: fileUrl),
    )
        .then((value) {
      _prefsRepository.setAFilePathExist(fileUrl + ' ' + value, chatId);
      File file = File(value);
      action?.call(file);
      return value;
    });
  }

  downloadFileUsingDio(String fileUrl, CancelToken cancelToken, String chatId,
      void Function(double progress) onProgress,
      {void Function(File file)? action}) async {
    String fileName = fileUrl.split('/').last;
    Dio dio = Dio();
    Directory dir = await getApplicationDocumentsDirectory();
    String filePath = "${dir.path}/$fileName";
    if (cancelToken.isCancelled) {
      cancelToken = CancelToken();
    }
    dio.download(fileUrl, filePath,
        cancelToken: cancelToken,
        deleteOnError: false, onReceiveProgress: (rec, total) {
      onProgress.call((rec / total) * 100);
      if ((rec / total * 100) == 100) {
        _prefsRepository.setAFilePathExist(fileUrl + ' ' + filePath, chatId);
        action?.call(File(filePath));
      }
    });
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
