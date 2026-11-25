import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
// `TextDirection` مخفيّة: الحزمة تصدّر واحدةً من `intl` تحجب التي في
// Flutter — والمقصود هنا اتجاه الودجت لا اتجاه النصّ.
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:eraser/eraser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:trydos/common/helper/file_saving.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/common/test_utils/test_var.dart';
import 'package:trydos/config/theme/my_color_scheme.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/extensions/state_ext.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/features/app/app_widgets/app_text_field.dart';
import 'package:trydos/features/app/app_widgets/loading_indicator/trydos_loader.dart';
import 'package:trydos/features/app/blocs/app_bloc/app_state.dart';
import 'package:trydos/features/app/loading_indicator.dart';
import 'package:trydos/features/calls/presentation/bloc/calls_bloc.dart';
import 'package:trydos/features/chat/presentation/pages/profile_page.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:trydos/features/chat/presentation/widgets/edit_message_dialog.dart';
import 'package:trydos/features/chat/presentation/widgets/message_reminder_dialog.dart';
import 'package:trydos/features/chat/presentation/widgets/message_tag_dialog.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_widgets/shared_product_message.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/pages/product_details_page_new.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:uuid/uuid.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../core/data/model/pagination_model.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../app/app_widgets/trydos_app_bar/app_bar_params.dart';
import '../../../app/app_widgets/trydos_app_bar/trydos_appbar.dart';
import '../../../app/blocs/app_bloc/app_bloc.dart';
import '../../../app/blocs/app_bloc/app_event.dart';
import '../../../app/my_cached_network_image.dart';
import '../../../app/my_text_widget.dart';
import '../../../calls/presentation/utils/caller_info.dart';
import '../../data/models/my_chats_response_model.dart';
import '../manager/chat_bloc.dart';
import '../manager/chat_event.dart';
import '../manager/chat_state.dart';
import '../widgets/chat_widgets/no_image_widget.dart';
import 'conversation_design.dart';
import '../widgets/chat_v2/chat_bubble_v2.dart';
import '../widgets/chat_v2/message_adapter_v2.dart';
import '../widgets/chat_v2/message_row_v2.dart';
import '../widgets/chat_v2/conversation_header.dart';
import '../widgets/chat_v2/message_menu_v2.dart';
import '../widgets/chat_v2/chat_messages_v2.dart';
import '../widgets/chat_v2/message_flags_v2.dart';
import '../widgets/chat_v2/toast_v2.dart';
import '../widgets/chat_v2/reaction_fly_v2.dart';
import '../widgets/chat_v2/reaction_sheet_v2.dart';
import '../widgets/chat_v2/pick_sheet_v2.dart';
import 'profile_page_design.dart';
import 'package:trydos/core/utils/last_pages_tracker.dart';
import 'package:trydos/common/helper/dev_log.dart';

class SinglePageChat extends StatefulWidget {
  const SinglePageChat({
    Key? key,
    this.dataLength,
    required this.chatId,
    required this.receiverName,
    required this.receiverPhone,
    required this.fullReceiverName,
    required this.senderName,
    this.fromSearch = false,
    this.fromOrder = "false",
    this.senderPhoto,
    this.receiverPhoto,
  }) : super(key: key);
  final int? dataLength;
  final String chatId;
  final String receiverName;
  final bool? fromSearch;
  final String? fromOrder;
  final String fullReceiverName;
  final String receiverPhone;
  final String senderName;
  final String? receiverPhoto;
  final String? senderPhoto;

  @override
  State<SinglePageChat> createState() => _SinglePageChatState();
}

class _SinglePageChatState extends State<SinglePageChat> {
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  late ChatBloc chatBloc;

  /// تهدئة البحث داخل المحادثة.
  ///
  /// `onChange` يُستدعى مع **كل حرف**، وكان كلٌّ منها يُطلق طلب شبكة إلى
  /// `channelSearch`: كلمة من ستة أحرف = ستة طلبات، خمسة منها نتائجها لا تُعرض
  /// أصلاً لأن حارس `currentRequestIdForAvoidPreRequest` في البلوك يُسقط ردّ
  /// الطلب القديم. فالتهدئة توقف الحِمل الضائع ولا تغيّر ما يراه المستخدم.
  Timer? _searchDebounce;

  /// هل شريط البحث ظاهر؟
  ///
  /// يبدأ من `widget.fromSearch` ثم يصير قابلاً للإغلاق بزرّ ✕. حقل الـwidget
  /// نفسه ثابت (`final`) فلا يصلح لحمل حالة تتغيّر.
  late bool _searchOpen = widget.fromSearch ?? false;

  /// يغلق البحث ويعيد المحادثة إلى حالتها الطبيعية.
  void _closeSearch() {
    _searchDebounce?.cancel();
    controller.clear();
    chatBloc.add(
      SearchTextInChatEvent(
        channel_id: widget.chatId,
        searchText: "",
        clearSearch: true,
      ),
    );
    FocusScope.of(context).unfocus();
    setState(() => _searchOpen = false);
    // بعد الإغلاق نعود إلى آخر الرسائل: المستخدم قد يكون وسط المحادثة عند
    // نتيجة بحث، وتركُه هناك بلا سياق بحث يُربك.
    try {
      _scrollToBottom();
    } catch (e) {
      devLog('single_page_chat.dart: ignored error', e);
    }
  }

  final ValueNotifier<int> rebuildMessage = ValueNotifier(-1);

  /// فهرس الرسالة التي قُفز إليها، وعدّادٌ يُشعل ومضتها.
  ///
  /// عدّادٌ لا علمٌ منطقي: قفزتان متتاليتان إلى الرسالة نفسها تُشعلان ومضتين،
  /// وهو ما يفعله `setFlash((f) => ({id, n: f.n + 1}))` في الويب.
  int flashedIndex = -1;
  final ValueNotifier<int> flashSeq = ValueNotifier(0);

  /// تفاعلُ كل رسالة — رمزٌ واحد لا أكثر، كما في الويب.
  ///
  /// **محليٌّ على هذا الجهاز وحده**: خادمُنا لا يحفظ التفاعلات بعد (لا حقل
  /// ولا طلب ولا حدث)، وديمو الويب نفسه يحفظها في حالته لا في خادمه. فهي
  /// تختفي مع إعادة التشغيل ولا يراها الطرف الآخر — تماماً كالديمو.
  ///
  /// ومتى وصل الحقل من الخادم تُقرأ منه بدل هذه الخريطة، ولا يتغيّر شيءٌ
  /// آخر: الشريط والنافذة والحبّة لا تعرف من أين جاء الرمز.
  final Map<String, String> _reactions = <String, String>{};

  /// يضع تفاعلاً أو يرفعه. واختيارُ الرمز نفسه يرفعه — مُبدِّلٌ لا مُراكِم،
  /// وهو سطرُ الاختزال في `demoChatModel.ts` حرفياً.
  void toggleReaction(String messageId, String emoji) {
    setState(() {
      if (_reactions[messageId] == emoji) {
        _reactions.remove(messageId);
      } else {
        _reactions[messageId] = emoji;
      }
    });
  }

  /// حبّةُ تفاعل رسالةٍ، أو `null` إن لم تحمل رمزاً.
  Widget? buildReactionChip(Message message, bool isMine) {
    final String? id = message.id ?? message.localId;
    final String? emoji = id == null ? null : _reactions[id];
    if (emoji == null) return null;
    return ReactionChipV2(isMine: isMine, emoji: emoji, messageId: id);
  }

  /// الرمز الذي تحمله رسالةٌ الآن — يُعلَّم في الشريط وفي النافذة.
  String? reactionOf(Message message) {
    final String? id = message.id ?? message.localId;
    return id == null ? null : _reactions[id];
  }

  /// رمزٌ اختير من الشريط أو من النافذة.
  ///
  /// يُطلِق الطيران **قبل** تغيير الحالة: القائمة تُغلق والحبّة تظهر في
  /// الإطار نفسه، فالحبّة تجد طيرانها جاهزاً عند تركيبها. ولا طيران لرمزٍ
  /// يُرفع، ولا لرمزٍ تحمله الرسالة أصلاً — كما يشترط الويب.
  void onReactPicked(Message message, String emoji, Offset from, double size) {
    final String? id = message.id ?? message.localId;
    if (id == null) return;
    if (_reactions[id] != emoji) {
      ReactionFlyStore.launch(
        messageId: id,
        emoji: emoji,
        center: from,
        size: size,
      );
    }
    rebuildMessage.value = -1;
    toggleReaction(id, emoji);
  }

  /// يفتح نافذة التفاعلات الموسَّعة التي يفتحها زرّ «+».
  Future<void> showReactionSheetV2(Message message) async {
    final String? id = message.id ?? message.localId;
    if (id == null) return;

    await ReactionSheetV2.show(
      context,
      current: _reactions[id],
      searchHint: LocaleKeys.search_emoji.tr(),
      emptyLabel: LocaleKeys.no_emoji_found.tr(),
      titleLabel: LocaleKeys.reactions.tr(),
      labelOf: reactionTabLabel,
      onPick: (emoji, from, size) => onReactPicked(message, emoji, from, size),
    );
  }

  /// اسم تبويبٍ في نافذة التفاعلات بلغة التطبيق.
  String reactionTabLabel(ReactionTab tab) {
    switch (tab) {
      case ReactionTab.all:
        return LocaleKeys.emoji_all.tr();
      case ReactionTab.recent:
        return LocaleKeys.emoji_recent.tr();
      case ReactionTab.popular:
        return LocaleKeys.emoji_popular.tr();
      case ReactionTab.smileys:
        return LocaleKeys.emoji_smileys.tr();
      case ReactionTab.gestures:
        return LocaleKeys.emoji_gestures.tr();
      case ReactionTab.symbols:
        return LocaleKeys.emoji_symbols.tr();
    }
  }

  final ValueNotifier<int> currentFocusedIcon = ValueNotifier(-2);

  final ValueNotifier<Map<String, int>> currentIndextForEachMessage =
      ValueNotifier({});

  final ValueNotifier<bool> clickBackButton = ValueNotifier(false);
  final TextEditingController controller = TextEditingController();
  late AutoScrollController autoScrollController;

  void _scrollToBottom() {
    autoScrollController.jumpTo(0);
  }

  /// نزلنا إلى آخر الرسائل عند فتح الشاشة — فلا يُعاد مع كل بناء.
  bool _didOpenScroll = false;

  int? previousMessageSenderId, currentMessageSenderId;
  List<Widget> data = [];
  Map<String, List<Message>> messagesByDate = {};
  List<Message> removeDuplicateMessages(List<Message> messages) {
    if (messages.isEmpty) return messages;
    // Map لتتبع آخر ظهور لكل id و localId
    Map<String, int> lastOccurrenceById = {};
    Map<String, int> lastOccurrenceByLocalId = {};
    Set<int> indicesToKeep = {};
    // نمر على الرسائل من الأخير للأول لنحدد آخر ظهور لكل id و localId
    for (int i = messages.length - 1; i >= 0; i--) {
      Message message = messages[i];
      // رسائل التاريخ نحتفظ بها دائماً
      if (message.isDateMessage == true) {
        indicesToKeep.add(i);
        continue;
      }
      String? messageId = message.id;
      String? messageLocalId = message.localId;

      bool isDuplicate = false;
      // فحص التكرار حسب id
      if (messageId != null && messageId.isNotEmpty && messageId != "null") {
        if (lastOccurrenceById.containsKey(messageId)) {
          isDuplicate = true; // مكررة حسب id
        } else {
          lastOccurrenceById[messageId] = i;
        }
      }
      // فحص التكرار حسب localId
      if (messageLocalId != null &&
          messageLocalId.isNotEmpty &&
          messageLocalId != "null") {
        if (lastOccurrenceByLocalId.containsKey(messageLocalId)) {
          isDuplicate = true; // مكررة حسب localId
        } else {
          lastOccurrenceByLocalId[messageLocalId] = i;
        }
      }
      // إذا لم تكن مكررة، نحتفظ بها
      if (!isDuplicate) {
        indicesToKeep.add(i);
      }
    }
    // نبني القائمة الجديدة بالترتيب الأصلي
    List<Message> result = [];
    for (int i = 0; i < messages.length; i++) {
      if (indicesToKeep.contains(i)) {
        result.add(messages[i]);
      }
    }
    return result;
  }

  bool rebuild = true;
  bool rebuildForScrollWhenGetAllMessage = false;
  bool rebuildForScrollFirstWord = true;

  DateTime lastDate = DateTime.now();
  late CallsBloc callsBloc;
  int countMessagesReceivedToMeNow = 0;
  late Chat chat;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Map<String, int> messagesIndexes = {};
  List<String> searchResults = [];

  int indexForEveryTextInSearchResult = 0;
  Future<void> playSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(
        AssetSource(
          Platform.isIOS
              ? 'audio/Whatsapp_Tone.m4r'
              : 'audio/Whatsapp_Tone.mp3',
        ),
        volume: 1,
      );
    } catch (e) {
      devLog('Error playing sound: $e');
    }
  }

  @override
  void initState() {
    LastPagesTracker.push('SinglePageChat');
    rebuildMessage.value = -2;
    if (widget.fromOrder == "true") {
      Eraser.clearAppNotificationsByTag(widget.chatId);
    } else {
      Eraser.clearAllAppNotifications();
    }

    callsBloc = BlocProvider.of<CallsBloc>(context);

    chatBloc = BlocProvider.of<ChatBloc>(context);
    chatBloc.add(
      ChangeGlobalUsedVariablesInBloc(currentOpenedChatId: widget.chatId),
    );
    chatBloc.add(
      GetOrderRecipientIdEvent(
        originalUserId: widget.senderName,
        orderId: widget.chatId,
        changeStatusToInit: true,
      ),
    );
    autoScrollController = AutoScrollController();
    callsBloc.add(GetMissedCallCountEvent());
    chatBloc.add(ReadAllMessagesEvent(widget.chatId.toString()));
    chatBloc.add(
      AddUserConntctSatuseEvent(
        userConnectedStatuse: " ",
        chatId: widget.chatId,
      ),
    );
    //  FirebasePresence.listeningToConnectStatus(friendId:);
    //  if (int.tryParse(widget.chatId) != null) {
    //  chatBloc.add(GetMediaCountEvent(channelId: widget.chatId.toString()));
    // }
    chatBloc.add(
      SearchTextInChatEvent(
        channel_id: widget.chatId,
        searchText: "",
        clearSearch: true,
      ),
    );
    autoScrollController.addListener(() {
      if (rebuild) {
        rebuildMessage.value = -1;
      }
      if ((autoScrollController.offset >=
          autoScrollController.position.maxScrollExtent - 400)) {
        _loadMoreMessages();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    callsBloc.add(GetMissedCallCountEvent());
    chatBloc.add(
      const AddUserConntctSatuseEvent(userConnectedStatuse: " ", chatId: " "),
    );
    _searchDebounce?.cancel();
    autoScrollController.dispose();
    _audioPlayer.dispose();
    flashSeq.dispose();
    super.dispose();
  }

  int currentScrolledIndex = -1;

  /// ينتقل إلى نتيجة البحث التالية، ويطلب صفحةً جديدة إن قاربت النتائج.
  ///
  /// كانت دالّةً محلّية داخل `build`، ورفعتُها طريقةً ليستدعيها شريط
  /// التنقّل الجديد الذي يُبنى خارجه — ومنطقُها كما هو حرفاً بحرف.
  void MoveToUpToScrollSearch(
    PaginationStatus resultOfSearchTextInChat,
    Map<String, int> currentIndextForMessages,
  ) {
    if ((searchResults.isNullOrEmpty ||
            indexForEveryTextInSearchResult > (searchResults.length - 5)) &&
        resultOfSearchTextInChat != PaginationStatus.loading &&
        controller.text.length > 0) {
      chatBloc.add(
        SearchTextInChatEvent(
          getWithPagination: true,
          channel_id: widget.chatId,
          searchText: controller.text,
        ),
      );
    }
    if (indexForEveryTextInSearchResult < searchResults.length) {
      indexForEveryTextInSearchResult = indexForEveryTextInSearchResult + 1;
    } else if (resultOfSearchTextInChat == PaginationStatus.success) {
      indexForEveryTextInSearchResult = 0;
    }

    if (searchResults.length > 0) {
      scrollToIndex(
        currentIndextForMessages[searchResults[indexForEveryTextInSearchResult]] ??
            -1,
        currentId: currentIndextForMessages.keys.first,
        forSearchText: true,
        parentMessageId: searchResults[indexForEveryTextInSearchResult],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // `duration` انتقل إلى `buildStatusLine` مع سطر الحالة الذي يستعمله.
    // النزول إلى آخر الرسائل **مرّةً واحدة عند الفتح** لا مع كل إعادة بناء.
    //
    // كان بلا شرط، و`build` يُعاد مع كل تغيّرٍ في الشاشة — فتفاعلٌ على رسالة،
    // أو تذكير، أو وسم، أو أيُّ `setState` يُسقط المستخدمَ إلى أسفل المحادثة
    // وهو يقرأ في وسطها.
    //
    // والعودة بعد رسالةٍ جديدة — مرسَلةٍ أو واردة — يتكفّل بها `BlocListener`
    // أدناه، وهو موضعها الصحيح.
    if (!_didOpenScroll) {
      _didOpenScroll = true;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _scrollToBottom();
      });
    }
    return
    // ignore: deprecated_member_use
    WillPopScope(
      onWillPop: () {
        // Check if keyboard is open
        bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

        if (isKeyboardOpen) {
          // Close keyboard on first back press
          FocusScope.of(context).unfocus();
          return Future.value(false);
        }

        if (controller.text.length > 0) {
          controller.clear();
          try {
            _scrollToBottom();
          } catch (e) {
            devLog('single_page_chat.dart: ignored error', e);
          }
          return Future.value(false);
        }
        BlocProvider.of<AppBloc>(
          context,
        ).add(RefreshChatInputField(false, 'null', false));
        chatBloc.add(const ChangeGlobalUsedVariablesInBloc());
        return Future.value(true);
      },
      child: Scaffold(
        // `bg={C.page}` في الملف. وكانت `#EBFFF8` الخضراء من التصميم القديم.
        backgroundColor: ChatDesign.page,
        resizeToAvoidBottomInset: true,
        appBar: TrydosAppBar(
          // الترويسة الجديدة 50 كما في الملف، ويزيدها سطر الحالة نحو 18.
          // وبـ56 كانت تتجاوز الشريط، فيظهر بياضان بارتفاعين مختلفين:
          // بياض `AppBar` وبياض الترويسة فوقه.
          // الترويسة الجديدة 50، ويزيدها سطر الحالة نحو 18. وفي البحث تحلّ
          // ترويسة البحث محلّها كما في الملف، فلا سطر حالة ولا اسم.
          // الترويسة والشريط بارتفاعٍ واحد — [kHeaderHeight] — ومعهما
          // `fillHeight`، فلا يفضل تحتها شيءٌ ولا تفيض هي عنه.
          heightAppBar: _searchOpen ? (60) : (kHeaderHeight),
          appBarParams: AppBarParams(
            hasLeading: false,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            // الشريط بارتفاع `heightAppBar` كلّه لا بـ56 الافتراضية.
            //
            // الترويسة الجديدة نحو 68 (الخمسون من الملف وسطرُ الحالة فوقها)،
            // فكانت تُرسم داخل 56 وتفيض عمّا تحتها — فتركب صفَّ الصورتين
            // الذي يفتتح جسم المحادثة (`buildSidePhotosRow`)، وهو ما ظهر
            // ويدجتين فوق بعضهما عند اسم المحادثة.
            fillHeight: true,
            // ولا ظلَّ للشريط: `ConversationHeader` ترسم ظلَّها بنفسها
            // (`ChatDesign.headerShadow`) عند حافّتها هي.
            //
            // و`TrydosAppBar` يلفّ `AppBar` بحاويةٍ لها ظلٌّ خاصّ عند حافّة
            // **الشريط** — وهي أخفض من حافّة الترويسة. فكان الظلّان يُرسمان
            // معاً: واحدٌ تحت الاسم والمكالمات، وآخر أسفل منه — فيبدو بينهما
            // شريطٌ رماديٌّ كأنه ويدجت ثانية تحت الترويسة.
            withShadow: false,
            // خلفية الشريط بلون صفحة الرسائل لا الأبيض الافتراضي
            // (`colorScheme.surface`): الترويسة أقصر من الشريط، وما يفضل
            // تحتها كان يظهر شريطاً أبيض بين الترويسة وأوّل الرسائل.
            backgroundColor: ChatDesign.page,
            child: SafeArea(
              child: Column(
                children: [
                  // الترويسة. وفي البحث تغيب: الملف يضع حقل البحث مكانها
                  // لا تحتها.
                  // تملأ الشريط كلَّه — [kHeaderHeight] نفسها.
                  //
                  // محتواها نحو 53 (الصورة 38 بهامش 6، والاسم وسطرُ الحالة
                  // تحته)، فبارتفاعها الطبيعي يفضل تحتها من الشريط نحو 15
                  // — فتبعد صورتا الطرفين عن الترويسة بقدرٍ لا وجود له في
                  // الملف: هناك الترويسة 50 (من 50 إلى 100) وصفُّ الصورتين
                  // عند 104، أي بعدها بأربعة لا أكثر.
                  //
                  // و`SizedBox` لا `Expanded`: `AppBar` يضع `flexibleSpace`
                  // في `Stack` بارتفاعٍ غير محدود، فـ`Expanded` هنا تُسقط
                  // التخطيط كلَّه (`RenderFlex children have non-zero flex
                  // but incoming height constraints are unbounded`) فتبيضّ
                  // الشاشة.
                  if (!_searchOpen)
                    SizedBox(height: kHeaderHeight, child: buildHeaderV2()),
                  if (_searchOpen) ...{
                    ValueListenableBuilder<Map<String, int>>(
                      valueListenable: currentIndextForEachMessage,
                      builder: (context, currentIndextForMessages, _) {
                        currentFocusedIcon.value = -2;
                        return BlocBuilder<ChatBloc, ChatState>(
                          buildWhen: (previous, current) {
                            return previous
                                        .resultOfSearchTextInChat
                                        ?.paginationStatus !=
                                    current
                                        .resultOfSearchTextInChat
                                        ?.paginationStatus ||
                                previous.getMessagesBetweenStatus !=
                                    current.getMessagesBetweenStatus;
                          },
                          builder: (context, state) {
                            searchResults =
                                state.resultOfSearchTextInChat?.items ?? [];
                            if (searchResults.length > 0 &&
                                indexForEveryTextInSearchResult == 0 &&
                                controller.text.length > 0 &&
                                state
                                        .resultOfSearchTextInChat
                                        ?.paginationStatus ==
                                    PaginationStatus.success &&
                                rebuildForScrollFirstWord) {
                              rebuildForScrollFirstWord = false;
                              scrollToIndex(
                                currentIndextForMessages[searchResults[indexForEveryTextInSearchResult]] ??
                                    -1,
                                currentId: currentIndextForMessages.keys.first,
                                forSearchText: true,
                                parentMessageId:
                                    searchResults[indexForEveryTextInSearchResult],
                              );
                            }
                            return SafeArea(
                              child: Material(
                                color: Colors.transparent,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // شيفرون الإغلاق عند 18.5، كترويسة
                                    // المحادثة تماماً — فلا يقفز موضعه حين
                                    // يُفتح البحث.
                                    Padding(
                                      padding: HWEdgeInsetsDirectional.only(
                                        start: 18.5,
                                        top: 13.5,
                                      ),
                                      child: GestureDetector(
                                        onTap: _closeSearch,
                                        behavior: HitTestBehavior.opaque,
                                        child: const XdIcon(
                                          'chatBackPurple',
                                          width: 11,
                                          height: 23,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: HWEdgeInsetsDirectional.only(
                                          // الحقل يبدأ عند x=40 في الملف.
                                          start: 40 - (18.5 + 11),
                                          end: 12,
                                          top: 6,
                                        ),
                                        child: AppTextField(
                                          filledColor: const Color(0xffF8F8F8),
                                          bordersColor: const Color(0xffF8F8F8),
                                          hintText: 'Search',
                                          // 12 في الملف لا 30.
                                          roundingCornersValue: 12,
                                          controller: controller,
                                          onChange: (String text) {
                                            _searchDebounce?.cancel();
                                            if (text.isEmpty) {
                                              // المسح فوري بلا تهدئة: إخفاء النتائج
                                              // ردُّ فعلٍ على فعل المستخدم لا طلب
                                              // شبكة، وتأخيره يُبقي نتائج ميّتة على
                                              // الشاشة.
                                              rebuildForScrollFirstWord = false;
                                              chatBloc.add(
                                                SearchTextInChatEvent(
                                                  channel_id: widget.chatId,
                                                  searchText: "",
                                                  clearSearch: true,
                                                ),
                                              );
                                              return;
                                            }
                                            rebuildForScrollFirstWord = true;
                                            indexForEveryTextInSearchResult = 0;
                                            _searchDebounce = Timer(
                                              const Duration(milliseconds: 400),
                                              () {
                                                if (!mounted) return;
                                                chatBloc.add(
                                                  SearchTextInChatEvent(
                                                    channel_id: widget.chatId,
                                                    searchText: text,
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          textStyle: context
                                              .textTheme
                                              .titleMedium
                                              ?.lq
                                              .copyWith(
                                                color: const Color(0xff8D8D8D),
                                              ),
                                          hintTextStyle: context
                                              .textTheme
                                              .bodySmall
                                              ?.lq
                                              .copyWith(
                                                color: const Color(0xff8D8D8D),
                                              ),
                                          // بدونها يحصر `AppTextField` أيقونة البادئة
                                          // في مربّع ٢×٢ بكسل (قيمته الافتراضية)،
                                          // فتُرسم العدسة مسحوقةً إلى ما لا يُرى.
                                          isPrefixIconConstraints: false,
                                          prefixIcon: Padding(
                                            padding:
                                                HWEdgeInsetsDirectional.only(
                                                  start: 14,
                                                  end: 12,
                                                ),
                                            // أيقونة Material لا ملفّ SVG.
                                            //
                                            // رسم العدسة داخل `search_outlined.svg`
                                            // لا يملأ مربّعه: حوله فراغٌ في الملف،
                                            // فتبدو أكبر من مقاسها المطلوب مهما
                                            // صغّرناه. و`Icons.search` يرسم بنفس
                                            // مقاييس السهمين و✕ المجاورين، فتتطابق
                                            // الأربع بدل أن تُضبط كلٌّ على حدة.
                                            child: Icon(
                                              Icons.search,
                                              size: 20.sp,
                                              color: const Color(0xff388CFF),
                                            ),
                                          ),
                                          suffix:
                                              (state
                                                              .resultOfSearchTextInChat
                                                              ?.paginationStatus ==
                                                          PaginationStatus
                                                              .loading &&
                                                      state
                                                          .resultOfSearchTextInChat!
                                                          .items
                                                          .isEmpty) ||
                                                  state.getMessagesBetweenStatus ==
                                                      GetMessagesBetweenStatus
                                                          .loading
                                              ? const LoadingIndicator()
                                              : const SizedBox.shrink(),
                                          // أيقونات اللاحقة ليست أصغر لأن `Container`
                                          // ارتفاعه 15: `IconButton` يفرض على نفسه
                                          // هدف لمسٍ أدناه 48×48 ومقاس أيقونةٍ 24
                                          // وحشواً 8 من كل جهة، فيتجاهل الارتفاع
                                          // المحيط ويتمدّد. ولا سبيل لتصغيره إلّا
                                          // بإلغاء قيوده الثلاثة صراحةً — وهو ما
                                          // تفعله `_SearchFieldIcon` أدناه.
                                          suffixIcon: Container(
                                            height: 20,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // سهما التنقّل بين النتائج
                                                // يختفيان أثناء التحميل — لا
                                                // نتائج بعدُ للتنقّل بينها.
                                                // أمّا ✕ فتبقى دائماً: إغلاق
                                                // البحث لا يتوقّف على حالته،
                                                // والتحميل هو أكثر لحظة قد
                                                // يريد المستخدم الخروج فيها.
                                                //
                                                // وفي التصميم الجديد لا سهمَ
                                                // هنا أصلاً: الملف يضعهما في
                                                // شريطٍ مكان حقل الكتابة
                                                // (`buildSearchNavBar`)،
                                                // والترويسة فيها الحقل و✕.
                                                if (!((state
                                                                .resultOfSearchTextInChat
                                                                ?.paginationStatus ==
                                                            PaginationStatus
                                                                .loading &&
                                                        state
                                                            .resultOfSearchTextInChat!
                                                            .items
                                                            .isEmpty) ||
                                                    state.getMessagesBetweenStatus ==
                                                        GetMessagesBetweenStatus
                                                            .loading)) ...[
                                                  _SearchFieldIcon(
                                                    icon: Icons.arrow_downward,
                                                    onTap: () {
                                                      if (indexForEveryTextInSearchResult >
                                                          0) {
                                                        indexForEveryTextInSearchResult =
                                                            indexForEveryTextInSearchResult -
                                                            1;
                                                      }

                                                      scrollToIndex(
                                                        currentIndextForMessages[searchResults[indexForEveryTextInSearchResult]] ??
                                                            -1,
                                                        currentId:
                                                            currentIndextForMessages
                                                                .keys
                                                                .first,
                                                        forSearchText: true,
                                                        parentMessageId:
                                                            searchResults[indexForEveryTextInSearchResult],
                                                      );
                                                    },
                                                  ),
                                                  _SearchFieldIcon(
                                                    icon: Icons.arrow_upward,
                                                    onTap: () {
                                                      MoveToUpToScrollSearch(
                                                        state
                                                            .resultOfSearchTextInChat!
                                                            .paginationStatus,
                                                        currentIndextForMessages,
                                                      );
                                                    },
                                                  ),
                                                ],
                                                _SearchFieldIcon(
                                                  icon: Icons.close,
                                                  onTap: _closeSearch,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  },
                ],
              ),
            ),
          ),
        ),
        body: BlocListener<ChatBloc, ChatState>(
          listenWhen: (p, c) =>
              (p.getMessagesBetweenStatus != c.getMessagesBetweenStatus &&
              c.getMessagesBetweenStatus == GetMessagesBetweenStatus.success &&
              p.resultOfSearchTextInChat?.paginationStatus !=
                  c.resultOfSearchTextInChat?.paginationStatus &&
              c.scrollToParentMessage),
          listener: (context, state) {
            searchResults = state.resultOfSearchTextInChat?.items ?? [];
            rebuildForScrollWhenGetAllMessage = true;
          },
          child: Column(
            children: [
              Flexible(
                child: BlocConsumer<ChatBloc, ChatState>(
                  listenWhen: (p, c) =>
                      p.sendMessageStatus != c.sendMessageStatus ||
                      (p.getMessagesBetweenStatus !=
                              c.getMessagesBetweenStatus &&
                          c.getMessagesBetweenStatus ==
                              GetMessagesBetweenStatus.success &&
                          c.scrollToParentMessage) ||
                      p.resendMessageStatus != c.resendMessageStatus ||
                      (p.receiveMessageStatus != c.receiveMessageStatus &&
                          c.receiveMessageStatus ==
                              ReceiveMessageStatus.success),
                  listener: (context, state) {
                    if (state.sendMessageStatus == SendMessageStatus.loading ||
                        state.receiveMessageStatus ==
                            ReceiveMessageStatus.success) {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        _scrollToBottom();
                      });
                    }
                    devLog(widget.chatId);
                    devLog(state.currentChannelReceivedMessage);
                    if (state.receiveMessageStatus ==
                            ReceiveMessageStatus.success &&
                        (widget.chatId == state.currentChannelReceivedMessage ||
                            chat.localId ==
                                state.currentChannelReceivedMessage)) {
                      chatBloc.add(ReadAllMessagesEvent(chat.id.toString()));
                    }
                  },
                  builder: (context, chatState) {
                    chat = chatState.chats.firstWhere(
                      (element) =>
                          element.id.toString() == widget.chatId ||
                          element.localId.toString() == widget.chatId,
                      orElse: () => chatState.pinnedChats.firstWhere(
                        (element) =>
                            element.id.toString() == widget.chatId ||
                            element.localId.toString() == widget.chatId,
                        orElse: () => Chat(),
                      ),
                    );

                    return GestureDetector(
                      onTap: () {
                        rebuildMessage.value = -1;
                      },
                      child: SafeArea(
                        // عدّاد الومضة: يُعيد بناء الصفوف فيرى الصفُّ المقصود
                        // رقمَه الجديد ويُشعل ومضته.
                        child: ValueListenableBuilder<int>(
                          valueListenable: flashSeq,
                          builder: (context, _, _) => ValueListenableBuilder<int>(
                            valueListenable: rebuildMessage,
                            builder: (context, currentIndex, _) {
                              currentFocusedIcon.value = -2;
                              return ValueListenableBuilder<int>(
                                valueListenable: currentFocusedIcon,
                                builder: (context, focusedIndex, _) {
                                  return Column(
                                    children: [
                                      // صفّ الصورتين عند y=104 — أعلى جسم
                                      // المحادثة لا داخل القائمة: القائمة
                                      // مقلوبة (`reverse: true`) فأعلاها آخرُها.
                                      buildSidePhotosRow(),
                                      chat.paginationStatus ==
                                              PaginationStatus.loading
                                          ? TrydosLoader()
                                          : const SizedBox.shrink(),
                                      chat.paginationStatus ==
                                              PaginationStatus.loading
                                          ? 8.verticalSpace
                                          : const SizedBox.shrink(),
                                      Flexible(
                                        child: ListView.builder(
                                          key: TestVariables.kTestMode
                                              ? const Key(
                                                  WidgetsKeys.messagesListKey,
                                                )
                                              : null,
                                          // المحادثة لا تتزحزح ما دامت قائمةٌ
                                          // مفتوحة، كما في الويب
                                          // (`preventDefault`): سحبةٌ حقيقية
                                          // تُغلق القائمة ولا تُمرّر.
                                          physics: currentIndex >= 0
                                              ? const NeverScrollableScrollPhysics()
                                              : const ClampingScrollPhysics(),
                                          // لا حشوَ هنا.
                                          //
                                          // كنتُ أضعه `top` ليتّسع لقائمة آخر
                                          // رسالة — والقائمة **مقلوبة**،
                                          // فأعلاها هو طرفُ أقدم الرسائل: أي
                                          // حيث يسحب المستخدم ليحمّل السابق.
                                          // فظهر فراغٌ كبير هناك وسحبٌ طويل
                                          // بلا داع.
                                          //
                                          // ولا حاجة إليه أصلاً: `shiftFor`
                                          // تُزيح الرسالة المضغوطة حتى تظهر
                                          // قائمتُها كاملةً — وهي ضمانةُ
                                          // الملف الأولى، والفراغ عنده
                                          // احتياطٌ ثانٍ لا أكثر.
                                          shrinkWrap: true,
                                          reverse: true,
                                          controller: autoScrollController,
                                          itemBuilder: (context, index) {
                                            List<Message>
                                            messages = removeDuplicateMessages(
                                              chatState
                                                  .newSortedChatsByDate![chat.id
                                                      .toString()]!
                                                  .reversed
                                                  .toList(),
                                            );
                                            if (messages[index]
                                                .isDateMessage!) {
                                              return AutoScrollTag(
                                                key: ValueKey(index),
                                                index: index,
                                                controller:
                                                    autoScrollController,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    // 12 فوق فاصل اليوم
                                                    // وتحته، كما في الملف.
                                                    SizedBox(height: 12.h),
                                                    ChatDayPill(
                                                      label: messages[index]
                                                          .dateValue!,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                            String? messageId =
                                                messages[index].id;
                                            messagesIndexes = {};
                                            for (
                                              int i = 0;
                                              i < messages.length;
                                              i++
                                            ) {
                                              messagesIndexes.addAll({
                                                messages[i].id.toString(): i,
                                              });
                                            }
                                            /*   messagesIndexes[messages[
                                                                    index]
                                                                .id
                                                                .toString()] =
                                                            index;*/
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                                  // الكود الذي تريد تنفيذه بعد انتهاء عملية إعادة البناء
                                                  currentIndextForEachMessage
                                                      .value = {
                                                    ...messagesIndexes,
                                                  };
                                                });
                                            if (rebuildForScrollWhenGetAllMessage) {
                                              WidgetsBinding.instance.addPostFrameCallback((
                                                timeStamp,
                                              ) {
                                                controller.text.length > 0
                                                    ? messages
                                                                  .firstWhere(
                                                                    (element) =>
                                                                        element
                                                                            .id ==
                                                                        (indexForEveryTextInSearchResult >=
                                                                                searchResults.length
                                                                            ? "null"
                                                                            : searchResults[indexForEveryTextInSearchResult]),
                                                                    orElse: () => Message(
                                                                      authMessageStatus:
                                                                          MessageStatus(
                                                                            isDeleted:
                                                                                1,
                                                                          ),
                                                                    ),
                                                                  )
                                                                  .authMessageStatus
                                                                  ?.isDeleted ==
                                                              1
                                                          ? MoveToUpToScrollSearch(
                                                              PaginationStatus
                                                                  .success,
                                                              currentIndextForEachMessage
                                                                  .value,
                                                            )
                                                          : scrollToIndex(
                                                              messagesIndexes[searchResults[indexForEveryTextInSearchResult]] ??
                                                                  messages.length -
                                                                      1,
                                                              currentId:
                                                                  currentIndextForEachMessage
                                                                      .value
                                                                      .keys
                                                                      .last,
                                                              forSearchText:
                                                                  true,
                                                              parentMessageId:
                                                                  searchResults[indexForEveryTextInSearchResult],
                                                            )
                                                    : scrollToIndex(
                                                        messages.length - 1,
                                                        forSearchText: false,
                                                      );
                                              });
                                              rebuildForScrollWhenGetAllMessage =
                                                  false;
                                            }
                                            return AutoScrollTag(
                                              key: ValueKey(messageId),
                                              index: index,
                                              controller: autoScrollController,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // فجوات الملف: 16 فوق
                                                  // الأولى، و2 بين نصّين من
                                                  // جهةٍ واحدة، و12 فيما
                                                  // عداهما. وكانت 30/10.
                                                  //
                                                  // والقائمة مقلوبة، فالرسالة
                                                  // التي **فوق** هذه على
                                                  // الشاشة هي `index + 1`.
                                                  SizedBox(
                                                    height:
                                                        (index + 1 >=
                                                                    messages
                                                                        .length
                                                                ? 16.0
                                                                : MessageAdapterV2.gapBetween(
                                                                    previous:
                                                                        messages[index +
                                                                            1],
                                                                    current:
                                                                        messages[index],
                                                                    myChatId:
                                                                        _prefsRepository
                                                                            .myChatId,
                                                                  ))
                                                            .h,
                                                  ),
                                                  ////////////////
                                                  GestureDetector(
                                                    key: TestVariables.kTestMode
                                                        ? Key(
                                                            '${WidgetsKeys.messagesListCardKey}$index',
                                                          )
                                                        : null,
                                                    onLongPress: () {
                                                      // التصميم الجديد يفتح
                                                      // القائمة من إيماءة
                                                      // `MessageRowV2` عند
                                                      // 360 كما في الملف.
                                                      // وبقاءُ هذه معه يجعل
                                                      // كاشفَين متداخلين
                                                      // يتنازعان الإيماءة.
                                                      return;
                                                    },
                                                    onTap: () {
                                                      if (messages[index]
                                                              .messageType
                                                              ?.name ==
                                                          'ShareProduct') {
                                                        BlocProvider.of<HomeBloc>(
                                                          context,
                                                        ).add(
                                                          GetFullProductDetailsEvent(
                                                            productSlug:
                                                                messages[index]
                                                                    .shareProductContent
                                                                    ?.productSlug
                                                                    .toString() ??
                                                                "",
                                                          ),
                                                        );
                                                        Navigator.of(
                                                          context,
                                                        ).push(
                                                          MaterialPageRoute(
                                                            builder: (ctx) => ProductDetailsPageNew(
                                                              productIdForOpeningChatDirectly:
                                                                  messages[index]
                                                                      .shareProductContent
                                                                      ?.productId
                                                                      .toString(),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                      rebuildMessage.value = -1;
                                                    },
                                                    child: Container(
                                                      color:
                                                          currentScrolledIndex ==
                                                              index
                                                          ? Colors
                                                                // ignore: deprecated_member_use
                                                                .black12
                                                                // ignore: deprecated_member_use
                                                                .withOpacity(
                                                                  0.05,
                                                                )
                                                          : null,
                                                      child: getTheMessageWidget(
                                                        listIndex: index,
                                                        menuIndex: currentIndex,
                                                        message:
                                                            messages[index],
                                                        senderName:
                                                            widget.senderName,
                                                        receiverName:
                                                            widget.receiverName,
                                                        receiverPhoto: widget
                                                            .receiverPhoto,
                                                        senderPhoto:
                                                            widget.senderPhoto,
                                                      ),
                                                    ),
                                                  ),
                                                  index == 0
                                                      ? 10.verticalSpace
                                                      : const SizedBox.shrink(),
                                                  const SizedBox.shrink(),
                                                ],
                                              ),
                                            );
                                          },
                                          itemCount:
                                              chatState
                                                      .newSortedChatsByDate![chat
                                                      .id] !=
                                                  null
                                              ? removeDuplicateMessages(
                                                  chatState
                                                      .newSortedChatsByDate![chat
                                                          .id
                                                          .toString()]!
                                                      .reversed
                                                      .toList(),
                                                ).length
                                              : 0,
                                        ),
                                      ),
                                      // فقاعة «يكتب الآن» أسفل المحادثة كما في
                                      // الويب. وسطر الحالة في الترويسة يبقى —
                                      // هو إضافةٌ عندنا لا يحويها الملف، ولا
                                      // يمنع الفقاعة التي يحويها.
                                      buildTypingBubble(),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              BlocBuilder<AppBloc, AppState>(
                buildWhen: (p, c) => p.thereIsReply != c.thereIsReply,
                builder: (context, state) {
                  //                flutterToast.s
                  return BlocBuilder<ChatBloc, ChatState>(
                    buildWhen: (p, c) =>
                        p.blockOrDeleteBlockUserStatus !=
                        c.blockOrDeleteBlockUserStatus,
                    builder: (context, chatState) {
                      // أثناء البحث يحلّ شريط التنقّل **مكان حقل الكتابة**،
                      // كما في الويب — لا في الترويسة. والترويسة فيها الحقل
                      // وحده.
                      if (_searchOpen) {
                        return buildSearchNavBar();
                      }
                      //                flutterToast.s
                      return (chatState.chats
                                  .firstWhere(
                                    (element) =>
                                        (element.id == widget.chatId ||
                                        element.localId == widget.chatId),
                                    orElse: () =>
                                        chatState.pinnedChats.firstWhere(
                                          (element) =>
                                              element.id == widget.chatId,
                                        ),
                                  )
                                  .channelMembers
                                  ?.any((element) => element.isBlocked == 1) ??
                              false)
                          ? Container(
                              alignment: Alignment.center,
                              color: const Color.fromARGB(255, 236, 227, 227),
                              width: 1.sw,
                              height: 40,
                              child: Text(
                                LocaleKeys
                                    .You_cannot_send_messages_or_calls_to_this_user.tr(),
                                style: context.textTheme.bodyLarge!.copyWith(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : ChatInputField(
                              channelId: chat.id ?? "",
                              senderName: widget.senderName,
                              receiverName: widget.fullReceiverName,
                              senderUserImage: widget.senderPhoto,
                              onSendFile: (File file, String customPathType) {
                                // صيغ فيديو لا يشغّلها النظام: تُمنع هنا قبل
                                // الرفع. وبلا هذا يُرسَل الملف بنجاح ويفشل
                                // تشغيله عند الطرفين معاً — وعدٌ كاذب أسوأ من
                                // المنع.
                                if (customPathType == 'video' &&
                                    !HelperFunctions.isSupportedVideoFile(
                                      file.path,
                                    )) {
                                  showWarningMessage(
                                    context,
                                    LocaleKeys.unsupported_video_format.tr(),
                                  );
                                  return;
                                }
                                String id = const Uuid().v4();
                                FileSaving().saveFileToSpecificDirectory(file);
                                ChannelMember? member =
                                    !chat.channelMembers.isNullOrEmpty
                                    ? chat.channelMembers!.firstWhere(
                                        (element) =>
                                            element.userId !=
                                            _prefsRepository.myChatId,
                                      )
                                    : null;
                                String mimeStr =
                                    lookupMimeType(file.absolute.path) ?? '';
                                bool isMediaFile =
                                    mimeStr.split('/')[0] != 'application';

                                chatBloc.add(
                                  UploadFileEvent(
                                    file: file,
                                    channelId: chat.id.toString(),
                                    filePath: customPathType == 'image'
                                        ? 'images/test'
                                        : customPathType == 'file'
                                        ? 'files/test'
                                        : customPathType == 'video'
                                        ? 'videos/test'
                                        : 'voices/test',
                                    useCloudinaryToUpload: isMediaFile,
                                    fileName: file.path,
                                    messageType: customPathType == 'image'
                                        ? 'ImageMessage'
                                        : customPathType == 'file'
                                        ? 'FileMessage'
                                        : customPathType == 'video'
                                        ? 'VideoMessage'
                                        : 'VoiceMessage',
                                    isForward: false,
                                    senderParentMessageId:
                                        state.senderParentMessageId,
                                    parentMessageId: state.thereIsReply
                                        ? state.messageId
                                        : null,
                                    messageId: id,
                                    parentMessageContent:
                                        customPathType == 'image'
                                        ? LocaleKeys.photo.tr()
                                        : customPathType == 'file'
                                        ? LocaleKeys.file.tr()
                                        : customPathType == 'video'
                                        ? LocaleKeys.vvideo.tr()
                                        : LocaleKeys.voice.tr(),
                                    receiverUserId: member?.userId,
                                  ),
                                );
                                BlocProvider.of<AppBloc>(
                                  context,
                                ).add(RefreshChatInputField(false, '', false));
                              },
                              onSendMessage: (String message) {
                                String id = const Uuid().v4();
                                ChannelMember? member =
                                    !chat.channelMembers.isNullOrEmpty
                                    ? chat.channelMembers?.firstWhere(
                                        (element) =>
                                            element.userId !=
                                            _prefsRepository.myChatId,
                                      )
                                    : null;

                                debugPrint('there : ${state.thereIsReply}');
                                chatBloc.add(
                                  SendMessageEvent(
                                    messageType: 'TextMessage',
                                    channelId: chat.id.toString(),
                                    isForward: false,
                                    parentMessageId: state.thereIsReply
                                        ? state.messageId
                                        : null,
                                    content: message,
                                    messageId: id,
                                    senderParentMessageId:
                                        state.senderParentMessageId,
                                    parentMessageContent: state.message,
                                    receiverUserId: member?.userId,
                                  ),
                                );
                                BlocProvider.of<AppBloc>(
                                  context,
                                ).add(RefreshChatInputField(false, '', false));
                                // rebuildMessage.value = data.length;
                              },
                            );
                    },
                  );
                },
              ),
              0.2.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  void dealWithMessageOptions(int index, String? messageId) {
    if (messageId == null) return;
    // بلا `orElse` كانت ترمي `StateError` حين لا تكون الرسالة في
    // `chat.messages` — وهو يقع مع رسالةٍ ظهرت من قائمةٍ أخرى.
    final Message? found = chat.messages?.firstWhere(
      (element) => element.id == messageId,
      orElse: Message.new,
    );
    if (found == null || found.id == null) return;
    final Message message = found;

    Locale locale = Localizations.localeOf(context);
    bool lan = !locale.languageCode.contains("ar");

    if (index == -1) {
      replayMessage(message, _prefsRepository.myChatId);
      return;
    }

    // Actions Mapping
    // English (lan=true):  0:Forward, 1:Copy, 2:Category, 3:Delete, 4:Edit, 5:Remind
    // Arabic (lan=false): 0:Remind, 1:Edit, 2:Delete, 3:Category, 4:Copy, 5:Forward

    bool isSent = message.senderUserId == _prefsRepository.myChatId;
    bool isText = message.messageType?.name == "TextMessage";
    int adjustedIndex = index;
    if (isText) {
      if (!isSent) {
        if (lan) {
          if (index >= 4) adjustedIndex = index + 1;
        } else {
          if (index >= 1) adjustedIndex = index + 1;
        }
      }
    } else {
      if (lan) {
        if (index >= 1) adjustedIndex = index + 1;
        if (adjustedIndex >= 4) adjustedIndex = adjustedIndex + 1;
      } else {
        if (index >= 1) adjustedIndex = index + 1;
        if (adjustedIndex >= 4) adjustedIndex = adjustedIndex + 1;
      }
    }

    if (lan) {
      switch (adjustedIndex) {
        case 0:
          forwardMessageMethod(message);
          break;
        case 1:
          _copyMessage(message);
          break;
        case 2:
          _tagDialog(message);
          break;
        case 3:
          _deleteMessageDialog(message);
          break;
        case 4:
          _editMessageDialog(message);
          break;
        case 5:
          _reminderDialog(message);
          break;
      }
    } else {
      switch (adjustedIndex) {
        case 0:
          _reminderDialog(message);
          break;
        case 1:
          _editMessageDialog(message);
          break;
        case 2:
          _deleteMessageDialog(message);
          break;
        case 3:
          _tagDialog(message);
          break;
        case 4:
          _copyMessage(message);
          break;
        case 5:
          forwardMessageMethod(message);
          break;
      }
    }
  }

  void _copyMessage(Message message) {
    final messageContent = message.messageContent?.content?.toString();
    if (messageContent == null ||
        (messageContent.trim().isEmpty) ||
        message.messageType?.name != "TextMessage") {
      return;
    }
    Clipboard.setData(ClipboardData(text: messageContent));
    // حبّةُ التصميم الداكنة بدل `SnackBar` العريض.
    ToastV2.show(context, LocaleKeys.copied.tr());
    return;
  }

  /// يفتح نافذة الوسم.
  ///
  /// الوسم يعمل على أي نوع رسالة وعلى المرسَلة والمستقبَلة سواء — يكفي أن
  /// أكون عضواً في القناة. لكنه يحتاج معرّفاً يعرفه الخادم، فرسالة لم تُؤكَّد
  /// بعد (معرّف محلي غير رقمي) لا وسم لها.
  void _tagDialog(Message message) {
    final String? id = message.id?.toString();
    if (id == null || int.tryParse(id) == null) return;
    showMessageTagDialog(context, messageId: id, channelId: widget.chatId);
  }

  /// يفتح نافذة التذكير.
  ///
  /// التذكير يعمل على أي نوع رسالة (بعكس التعديل)، لكنه يحتاج معرّفاً يعرفه
  /// الخادم — فرسالة لم تُؤكَّد بعد لا تذكير لها.
  void _reminderDialog(Message message) {
    final String? id = message.id?.toString();
    if (id == null || int.tryParse(id) == null) return;
    showMessageReminderDialog(context, messageId: id, channelId: widget.chatId);
  }

  /// يفتح نافذة تعديل النص.
  ///
  /// التعديل للنصّ فقط ولرسائلي أنا. الخادم يفرض الشرط الثاني، لكن فتح نافذة
  /// سترجع بخطأ حتماً سلوك سيّئ، فنمنعه هنا أيضاً. ورسالة لم يؤكّدها الخادم بعد
  /// (معرّف محلي غير رقمي) لا يعرفها الخادم أصلاً فلا تُعدَّل.
  void _editMessageDialog(Message message) {
    final bool isMine = message.senderUserId == _prefsRepository.myChatId;
    final bool isText = message.messageType?.name == "TextMessage";
    final String? id = message.id?.toString();
    final String? content = message.messageContent?.content?.toString();
    if (!isMine ||
        !isText ||
        id == null ||
        int.tryParse(id) == null ||
        content == null) {
      return;
    }
    showEditMessageDialog(
      context,
      messageId: id,
      channelId: widget.chatId,
      initialContent: content,
    );
  }

  void _deleteMessageDialog(Message message) {
    bool isSent = message.senderUserId == _prefsRepository.myChatId;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocaleKeys.delete_message.tr()),
        actions: [
          MaterialButton(
            onPressed: () {
              callsBloc.add(
                DeleteMessageEvent(
                  type: "message",
                  deleteFromBoth: 0,
                  messageId: message.id!,
                  channelId: widget.chatId,
                  deleteFromId: _prefsRepository.myChatId!,
                ),
              );
              Navigator.of(context).pop();
              rebuildMessage.value = -1;
              ToastV2.show(context, LocaleKeys.toast_deleted.tr());
            },
            child: Text(LocaleKeys.only_me.tr()),
          ),
          SizedBox(width: 20.w),
          (!isSent)
              ? MaterialButton(
                  child: Text(LocaleKeys.cancel.tr()),
                  onPressed: () {
                    Navigator.of(context).pop();
                    rebuildMessage.value = -1;
                  },
                )
              : MaterialButton(
                  onPressed: () {
                    callsBloc.add(
                      DeleteMessageEvent(
                        deleteFromId: _prefsRepository.myChatId!,
                        type: "message",
                        deleteFromBoth: 1,
                        messageId: message.id!,
                        channelId: widget.chatId,
                      ),
                    );
                    Navigator.of(context).pop();
                    rebuildMessage.value = -1;
                    ToastV2.show(context, LocaleKeys.toast_deleted.tr());
                  },
                  child: Text(LocaleKeys.everyone.tr()),
                ),
        ],
      ),
    );
  }

  void forwardMessageMethod(Message message) {
    String id = const Uuid().v4();

    // التصميم الجديد يختار المحادثة من نافذةٍ سفلية لا من صفحةٍ كاملة. وما
    // يُرسَل بعد الاختيار هو نفسه حرفاً بحرف — `sendForwardTo` أدناه هي جسم
    // `extra` القديم بلا تغيير.
    showForwardSheetV2(message, id);
    return;
  }

  /// يفتح نافذة «تحويل إلى» بالتصميم الجديد.
  ///
  /// محادثاتُ القائمة والمثبَّتة معاً، والأحدث أولاً كما يرتّبها الويب،
  /// والمحادثة الحالية مستثناة — لا معنى لتحويل رسالةٍ إلى مكانها.
  Future<void> showForwardSheetV2(Message message, String newId) async {
    final ChatState state = chatBloc.state;
    final List<Chat> all = [...state.pinnedChats, ...state.chats]
      ..sort((a, b) {
        final DateTime x = a.updatedAt ?? DateTime(1970);
        final DateTime y = b.updatedAt ?? DateTime(1970);
        return y.compareTo(x);
      });

    final List<SheetChatEntry> rows = [];
    final Map<String, ({int receiverId, String channelId})> targets = {};

    for (final Chat chat in all) {
      final String? id = chat.id;
      if (id == null || id == widget.chatId) continue;
      // المؤرشفة لا تُعرض: اختيارُها يُرسل إلى محادثةٍ أخرجها المستخدم من
      // قائمته.
      if ((chat.isArchived ?? 0) == 1) continue;

      final ChannelMember? other = chat.channelMembers?.firstWhere(
        (m) => m.userId != _prefsRepository.myChatId,
        orElse: () => ChannelMember(),
      );
      final int? receiverId = other?.userId;
      if (receiverId == null) continue;

      final String name =
          chat.channelName ??
          other?.user?.name ??
          LocaleKeys.no_channal_name.tr();
      targets[id] = (receiverId: receiverId, channelId: id);
      rows.add((
        id: id,
        name: name,
        secondLine: lastPreviewOf(chat),
        initials: initialsOf(name),
        photo: null,
      ));
    }

    final String? picked = await PickSheetV2.show<String>(
      context,
      title: LocaleKeys.forward_to.tr(),
      children: [
        Builder(
          builder: (sheetContext) => ForwardSheetV2(
            chats: rows,
            emptyLabel: LocaleKeys.no_chats.tr(),
            onPick: (id) => Navigator.of(sheetContext).pop(id),
          ),
        ),
      ],
    );

    final target = picked == null ? null : targets[picked];
    if (target == null) return;
    sendForwardTo(
      message: message,
      newId: newId,
      receiverId: target.receiverId,
      channelId: target.channelId,
    );
    rebuildMessage.value = -1;
    if (mounted) ToastV2.show(context, LocaleKeys.toast_forwarded.tr());
  }

  /// لمحةُ آخر رسالة في محادثة، كما يعرضها السطر الثاني.
  String lastPreviewOf(Chat chat) {
    final Message? last = (chat.messages?.isEmpty ?? true)
        ? null
        : chat.messages!.first;
    if (last == null) return '';
    final String? text = last.messageContent?.content?.toString();
    if (text != null && text.trim().isNotEmpty) return text;
    // رسالةٌ بلا نصّ: نوعُها مكان نصّها، كما تفعل القائمة.
    switch (last.messageType?.name) {
      case 'ImageMessage':
        return LocaleKeys.photo.tr();
      case 'VideoMessage':
        return LocaleKeys.vvideo.tr();
      case 'FileMessage':
        return LocaleKeys.file.tr();
      case 'VoiceMessage':
        return LocaleKeys.voice.tr();
      case 'ShareProduct':
        return LocaleKeys.product.tr();
      default:
        return '';
    }
  }

  /// الحرفان من اسمٍ — أوّل حرفٍ من أوّل كلمتين.
  String initialsOf(String name) {
    final List<String> words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    if (words.length == 1) {
      return words.first.characters.take(1).toString().toUpperCase();
    }
    return (words[0].characters.take(1).toString() +
            words[1].characters.take(1).toString())
        .toUpperCase();
  }

  /// يُرسل الرسالة المحوَّلة إلى محادثةٍ بعينها.
  ///
  /// جسم `extra` القديم كما كان، مستخرَجاً ليُستدعى من النافذة الجديدة ومن
  /// الصفحة القديمة معاً.
  void sendForwardTo({
    required Message message,
    required String newId,
    required int receiverId,
    required String channelId,
  }) {
    if (message.messageType!.name == 'TextMessage') {
      chatBloc.add(
        SendMessageEvent(
          messageType: message.messageType!.name,
          channelId: channelId,
          isForward: true,
          content: message.messageContent!.content,
          messageId: newId,
          receiverUserId: receiverId,
        ),
      );
    } else {
      chatBloc.add(
        SendMessageEvent(
          channelId: channelId,
          mediaContent: [
            {
              'file_path': message.mediaMessageContent?[0].filePath,
              'file_name': message.mediaMessageContent?[0].fileName,
            },
          ],
          messageType: message.messageType!.name,
          isForward: true,
          messageId: newId,
          receiverUserId: receiverId,
        ),
      );
    }
  }

  void replayMessage(Message message, int? myChatId) {
    BlocProvider.of<AppBloc>(context).add(
      RefreshChatInputField(
        true,
        message.messageType!.name == 'TextMessage'
            ? "Text"
            : message.messageType!.name == 'ImageMessage'
            ? "Photo"
            : message.messageType!.name == 'VoiceMessage'
            ? "Voice"
            : "video",
        message.senderUserId == myChatId,
        messageId: message.id,
        senderParentMessageId: message.senderUserId,
        message:
            message.messageContent?.content ??
            (message.messageType!.name == 'TextMessage'
                ? LocaleKeys.photo.tr()
                : LocaleKeys.voice.tr()),
        imageUrl:
            message.mediaMessageContent?.first.filePath ?? message.file?.path,
        time: message.createdAt,
      ),
    );
  }

  void scrollToIndex(
    int index, {
    String? currentId,
    String? parentMessageId,
    bool? forSearchText,
    bool? maxScrollExtent,
    Duration? duration,
    AutoScrollPosition? preferPosition,
  }) {
    if (index == -1) {
      chatBloc.add(
        GetAllMessagesBetweenEvent(
          firstMessageId: parentMessageId ?? "",
          scrollToParentMessage: true,
          secondMessageId: currentId!,
          channelId: widget.chatId,
        ),
      );
      return;
    }
    if (maxScrollExtent ?? false) {
      autoScrollController
          .animateTo(
            autoScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          )
          .then((value) => highlightAfterJump(index, forSearchText));
    } else {
      autoScrollController
          .scrollToIndex(
            index,
            duration: duration ?? const Duration(milliseconds: 50),
            preferPosition: preferPosition ?? AutoScrollPosition.middle,
          )
          .then((value) => highlightAfterJump(index, forSearchText));
    }
  }

  /// تُعلَّم الرسالة التي قُفز إليها.
  ///
  /// التصميم الجديد يُضيئها ومضةً بنفسجية تخبو، كما يفعل الويب بعد `jumpTo`.
  ///
  /// والقديم كان يضبط `rebuildMessage.value = index` ليُظلّلها — وهو **مِفصل
  /// فتح القائمة**: فالقفزة كانت تفتح قائمة الرسالة بغشاوتها لثانيتين بدل
  /// أن تُضيئها. الومضة تفصل الأمرين.
  void highlightAfterJump(int index, bool? forSearchText) {
    flashedIndex = index;
    flashSeq.value = flashSeq.value + 1;
    return;
  }

  void _loadMoreMessages() {
    chatBloc.add(GetMessagesForChatEvent(channelId: widget.chatId));
  }

  /// فهرس الرسالة التي قائمتها مفتوحة، أو `-1`.
  ///
  /// منه يعرف كل صفٍّ هل هو المرفوع أم أحد المعتَّمين. ويُحفظ حقلاً لأن
  /// `buildCallCardV2` و`buildPhotoMessageV2` تُبنى في موضعين آخرين، فتمريره
  /// إليهما وإلى الستّة كان سيكرّر المعامل سبع مرّات.
  int menuOpenIndex = -1;

  /// هذا الصفّ هو المضغوط: يكبر ويعلو فوق الغشاوة.
  bool isLifted(int listIndex) => menuOpenIndex == listIndex;

  /// عدّاد ومضة هذا الصفّ: رقمٌ جديد يُشعلها، والصفر لا يُشعل شيئاً.
  int flashOf(int listIndex) => flashedIndex == listIndex ? flashSeq.value : 0;

  getTheMessageWidget({
    required int listIndex,
    required int menuIndex,
    required Message message,
    required String senderName,
    required String receiverName,
    String? senderPhoto,
    String? receiverPhoto,

    /// الاقتباس رُسم بالفعل فوق هذه الرسالة: تُرسم الآن كأيّ رسالة.
    bool ignoreReply = false,
  }) {
    menuOpenIndex = menuIndex;
    bool isSentMessage =
        (message.senderUserId == _prefsRepository.myChatId &&
            message.senderUserId != null) ||
        (message.receiverUserId != _prefsRepository.myChatId &&
            message.receiverUserId != null);
    if (message.authMessageStatus?.isDeleted == 1 &&
        message.authMessageStatus?.deleteForAll == true) {
      Locale lan = Localizations.localeOf(context);
      return Row(
        mainAxisAlignment: !isSentMessage
            ? (lan.languageCode != "ar"
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end)
            : (lan.languageCode != "ar"
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start),
        children: [
          Container(
            margin: EdgeInsets.only(left: 10.w, right: 10.w),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 252, 243, 243),
              border: const Border(),
              borderRadius: BorderRadius.circular(20.w),
            ),
            width: 250.w,
            height: 32.h,
            child: Row(
              children: [
                const Spacer(),
                MyTextWidget(
                  message.deletedByUserId == _prefsRepository.myChatId
                      ? LocaleKeys.you_have_deleted_this_message.tr()
                      : LocaleKeys.this_message_has_been_deleted.tr(),
                  textAlign: TextAlign.center,
                  style: textTheme.titleSmall?.lq.copyWith(
                    fontSize: 12,
                    height: 1.1,
                    color: colorScheme.grey200,
                  ),
                ),
                const Spacer(),
                MyTextWidget(
                  !message.createdAt!.isUtc
                      ? HelperFunctions.getDateInFormat(message.createdAt!)
                      : HelperFunctions.getZonedDateInFormat(
                          message.createdAt!,
                        ),
                  textAlign: TextAlign.center,
                  style: textTheme.titleSmall?.lq.copyWith(
                    fontSize: 12,
                    height: 1.1,
                    color: colorScheme.grey200,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      );
    }
    int index;
    String? filePath = message.mediaMessageContent.isNullOrEmpty
        ? message.messageType?.name == 'ShareProduct'
              ? message.shareProductContent!.productImageUrl
              : null
        : message.mediaMessageContent?[0].filePath;
    if (message.file == null &&
        filePath != null &&
        _prefsRepository.isAFilePathExist(filePath, widget.chatId)) {
      String? path = _prefsRepository.getTheLocalPathForFile(
        filePath,
        widget.chatId,
      );
      if (path != null) {
        File? file = File(path);
        message = message.copyWith(file: file);
      }
    }

    index =
        message.messageStatus?.indexWhere(
          (e) => e.userId != _prefsRepository.myChatId,
        ) ??
        -1;
    MessageStatus? messageStatus = index == -1
        ? null
        : message.messageStatus![index];

    if (message.parentMessageId != null &&
        message.parentMessage != null &&
        !ignoreReply) {
      // الاقتباس في الملف **صفٌّ مستقلّ فوق الرسالة**، لا غلافٌ حولها: نفس
      // شكله دائماً (نقطةٌ بنفسجية وفقاعةٌ بزوايا الوارد في جهته) مهما كانت
      // جهة الردّ. والرسالة تحته تُرسم كأيّ رسالة.
      return buildReplyV2(
        message: message,
        listIndex: listIndex,
        menuIndex: menuIndex,
        senderName: senderName,
        receiverName: receiverName,
        senderPhoto: senderPhoto,
        receiverPhoto: receiverPhoto,
      );
    } else {
      switch (message.messageType?.name) {
        case 'TextMessage':
          return MessageRowV2(
            isMine: isSentMessage,
            onReply: () => replayMessage(message, _prefsRepository.myChatId),
            onHold: () => openMessageMenu(listIndex, message),
            menuCanEdit:
                isSentMessage && message.messageType?.name == 'TextMessage',
            isLifted: isLifted(listIndex),
            flash: flashOf(listIndex),
            menuBuilder: isLifted(listIndex)
                ? (hole, w) => buildMenuFor(message, isSentMessage, hole, w)
                : null,
            onCloseMenu: () => rebuildMessage.value = -1,
            // النقطة أختُ الفقاعة هنا، فتُقتطع مع هامشها من الثقب.
            holeInset: MessageMenuV2.edge,
            flags: buildMessageFlags(message),
            reaction: buildReactionChip(message, isSentMessage),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              textDirection: TextDirection.ltr,
              children: [
                if (!isSentMessage) const BubbleDot(isMine: false),
                Flexible(
                  child: MessageAdapterV2.textBubble(
                    message: message,
                    isMine: isSentMessage,
                    status: messageStatus,
                  ),
                ),
                if (isSentMessage) const BubbleDot(isMine: true),
              ],
            ),
          );
      }
    }
  }

  /// بطاقة مكالمة بالتصميم الجديد.
  ///
  /// النبرات الثلاث مشتقّةٌ من حقلين لا من حقلٍ خاصّ بالخادم:
  ///
  /// * ما أرسلتُه → **صادرة**.
  /// * ما وصلني ومدّته أكبر من صفر → **واردة**.
  /// * ما وصلني ومدّته **صفر** → **فائتة**، فلم تُجَب.
  ///
  /// والمرسَلة بمدّة صفر تبقى صادرة: هي مكالمةٌ لم يردّ عليها الطرف الآخر،
  /// لا مكالمةٌ فاتتني أنا.
  Widget buildCallCardV2({
    required int listIndex,
    required Message message,
    required bool isMine,
    required MessageStatus? status,
    required String title,
  }) {
    final int seconds = message.durationInSeconds ?? 0;
    return MessageRowV2(
      isMine: isMine,
      isWide: true,
      // بطاقة المكالمة لا يُردّ عليها ولا تُحوَّل — كما في الويب
      // (`canForwardOf = isOpenable`). لكنّ لها قائمةً كبقيّة الرسائل: الملف
      // يقول «كلُّ رسالةٍ إلّا فاصل اليوم لها القائمة — ومنها بطاقات
      // المكالمات والملاحظة».
      canReply: false,
      onHold: () => openMessageMenu(listIndex, message),
      // بطاقة المكالمة لا تُعدَّل ولا تُحوَّل، فقائمتها أقصر بصفّين — ومنه
      // تُحسب إزاحتها.
      menuCanForward: false,
      isLifted: isLifted(listIndex),
      flash: flashOf(listIndex),
      menuBuilder: isLifted(listIndex)
          ? (hole, w) => buildMenuFor(message, isMine, hole, w)
          : null,
      onCloseMenu: () => rebuildMessage.value = -1,
      flags: buildMessageFlags(message),
      reaction: buildReactionChip(message, isMine),
      child: Align(
        alignment: isMine
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: CallCardV2(
          tone: isMine
              ? CallCardTone.outgoing
              : (seconds > 0 ? CallCardTone.incoming : CallCardTone.missed),
          title: title,
          subtitle: seconds > 0
              ? MessageAdapterV2.minutesOf(seconds)
              : LocaleKeys.no_answer.tr(),
          time: MessageAdapterV2.timeOf(message.createdAt),
          isMine: isMine,
          status: MessageAdapterV2.statusOf(isMine: isMine, status: status),
        ),
      ),
    );
  }

  /// بطاقة المنتج المشارَك.
  ///
  /// مستخرَجةٌ كما هي ليستعملها الصفُّ الذي يلفّها — فالبطاقة واحدةٌ لا
  /// نسختان تتباعدان.
  Widget buildSharedProductCard({
    required Message message,
    required bool isSentMessage,
    required MessageStatus? messageStatus,
    required String senderName,
    required String receiverName,
    required String? senderPhoto,
    required String? receiverPhoto,
    bool insideRowV2 = false,
  }) {
    return SharedProductMessage(
      insideRowV2: insideRowV2,
      channelId: message.channelId!,
      imageUrl: addSuitableWidthAndHeightToImage(
        imageUrl: message.shareProductContent!.productImageUrl!,
        width: (((message.shareProductContent!.imageWidth ?? 0) > 0)
            ? message.shareProductContent!.imageWidth
            : 1.sw - 100.w)!,
        height: (((message.shareProductContent!.imageHeight ?? 0) > 0)
            ? message.shareProductContent!.imageHeight
            : 464.h)!,
      ),
      productName: message.shareProductContent!.productName ?? "",
      productDescription: message.shareProductContent!.productDescription ?? "",
      imageFile: message.file,
      receivedAt: messageStatus?.receivedAt,
      createAt: message.createdAt,
      key: ValueKey(message.id),
      isSent: isSentMessage,
      messageId: message.id.toString(),
      senderId: message.senderUserId!,
      userMessageName: message.receiverUserId != _prefsRepository.myChatId
          ? senderName
          : receiverName,
      userMessagePhoto: isSentMessage ? senderPhoto : receiverPhoto,
      isFirstMessage:
          message.isFirstMessage! || message.isFirstMessageForThisDay!,
      isRead: messageStatus?.isWatched ?? false,
      isReceived: (messageStatus?.isReceived ?? 0) == 1,
      isForwarded: message.isForward == 1,
      tags: message.tags,
      watchedAt: messageStatus?.watchedAt,
    );
  }

  /// رسالة صورة بالتصميم الجديد.
  ///
  /// الصورة من الملف المحلّي إن وُجد — وهي حالة ما أرسلتُه للتوّ قبل أن
  /// يؤكّده الخادم — وإلّا من الرابط.
  Widget buildPhotoMessageV2({
    required int listIndex,
    required Message message,
    required bool isMine,
    required MessageStatus? status,
  }) {
    final String? url = message.mediaMessageContent.isNullOrEmpty
        ? null
        : message.mediaMessageContent![0].filePath;

    final Widget image;
    if (message.file != null) {
      image = Image.file(message.file!, fit: BoxFit.cover);
    } else if (url != null) {
      image = MyCachedNetworkImage(
        imageUrl: addSuitableWidthAndHeightToImage(
          imageUrl: url,
          width: 300.w,
          height: 300.w,
        ),
        imageFit: BoxFit.cover,
        progressIndicatorBuilderWidget: TrydosLoader(),
        width: 300.w,
        height: 300.w,
        // بلا تدويرٍ داخليّ: [PhotoMessageV2] يقصّ بزوايا الفقاعة نفسها
        // (2/50/2/30) و`MyCachedNetworkImage` يدوّر صندوقه بـ12 دائريّة
        // افتراضاً — فيلتقي تدويران مختلفان وتظهر فجواتٌ بيضاء عند الأطراف.
        radius: 0,
      );
    } else {
      image = const SizedBox.shrink();
    }

    return MessageRowV2(
      isMine: isMine,
      onReply: () => replayMessage(message, _prefsRepository.myChatId),
      onHold: () => openMessageMenu(listIndex, message),
      isLifted: isLifted(listIndex),
      flash: flashOf(listIndex),
      menuBuilder: isLifted(listIndex)
          ? (hole, w) => buildMenuFor(message, isMine, hole, w)
          : null,
      onCloseMenu: () => rebuildMessage.value = -1,
      // النقطة أختُ الفقاعة هنا، فتُقتطع مع هامشها من الثقب.
      holeInset: MessageMenuV2.edge,
      flags: buildMessageFlags(message),
      reaction: buildReactionChip(message, isMine),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        textDirection: TextDirection.ltr,
        children: [
          if (!isMine) const BubbleDot(isMine: false),
          Flexible(
            child: PhotoMessageV2(
              image: image,
              time: MessageAdapterV2.timeOf(message.createdAt),
              isMine: isMine,
              status: MessageAdapterV2.statusOf(isMine: isMine, status: status),
            ),
          ),
          if (isMine) const BubbleDot(isMine: true),
        ],
      ),
    );
  }

  /// اسم فعل القائمة بلغة التطبيق — للتلميح.
  String menuLabelOf(MessageMenuAction action) => switch (action) {
    MessageMenuAction.reply => LocaleKeys.replay.tr(),
    MessageMenuAction.forward => LocaleKeys.forward.tr(),
    MessageMenuAction.copy => LocaleKeys.copy.tr(),
    MessageMenuAction.category => LocaleKeys.category.tr(),
    MessageMenuAction.delete => LocaleKeys.delete.tr(),
    MessageMenuAction.edit => LocaleKeys.edit.tr(),
    MessageMenuAction.remind => LocaleKeys.re_mind.tr(),
  };

  /// ينفّذ فعلاً من القائمة الجديدة.
  ///
  /// يستدعي نفس الدوالّ التي كان يستدعيها الشريط القديم عبر
  /// [dealWithMessageOptions] — فلا منطق جديد، بل طريقٌ أقصر إليه بلا
  /// حساب فهارس ولا إزاحة لغة.
  void onMenuAction(MessageMenuAction action, Message message) {
    switch (action) {
      case MessageMenuAction.reply:
        replayMessage(message, _prefsRepository.myChatId);
      case MessageMenuAction.forward:
        forwardMessageMethod(message);
      case MessageMenuAction.copy:
        _copyMessage(message);
      case MessageMenuAction.category:
        _tagDialog(message);
      case MessageMenuAction.delete:
        _deleteMessageDialog(message);
      case MessageMenuAction.edit:
        _editMessageDialog(message);
      case MessageMenuAction.remind:
        _reminderDialog(message);
    }
  }

  /// يفتح قائمة رسالةٍ بعد الضغط المطوّل.
  ///
  /// مسارٌ **واحد** للفتح. وكان مساران: إيماءةُ `MessageRowV2` عند 360 تنادي
  /// `dealWithMessageOptions(-2)` — وهي لا تفتح شيئاً — وضغطةٌ خارجية عند 500
  /// هي التي تفتح. فكان التوقيت توقيتَ Flutter لا توقيتَ الملف، ومتنازعاً
  /// بين كاشفَي إيماءةٍ متداخلين.
  void openMessageMenu(int listIndex, Message message) {
    // لوحة المفاتيح تُطوى قبل فتح القائمة: وإلّا ضاق ما تحت الرسالة فلم
    // تتّسع خياراتُها، وبقيت اللوحة فوق الغشاوة.
    FocusScope.of(context).unfocus();
    // رسالةٌ محذوفة لا قائمة لها.
    if (message.authMessageStatus?.isDeleted == 1) return;
    // ورسالةٌ لم يؤكّدها الخادم بعد: أفعالُ القائمة كلّها تحتاج معرّفه.
    final ChatState state = chatBloc.state;
    if (state.sendMessageStatus == SendMessageStatus.loading &&
        state.currentMessage.contains(message.id)) {
      return;
    }
    rebuildMessage.value = listIndex;
  }

  /// قائمة الضغط المطوّل لرسالةٍ بعينها.
  ///
  /// كانت تُبنى شقيقةً للصفّ في شجرة القائمة المُمرَّرة، فصارت تُمرَّر إلى
  /// `MessageRowV2` نفسه: هو من يرفعها — هي والصفّ — فوق الغشاوة في طبقةٍ
  /// واحدة، كما يفعل الملف.
  Widget buildMenuFor(
    Message message,
    bool isMine,
    Rect hole,
    double screenWidth,
  ) {
    final bool isCall = message.messageType?.name?.contains('Call') ?? false;
    // التفاعلات محليّةٌ على هذا الجهاز كما في ديمو الويب — `_reactions`.
    return MessageMenuV2(
      isMine: isMine,
      // صندوق الفقاعة: الشريط يعلوه والبطاقة تهبط تحته.
      hole: hole,
      screenWidth: screenWidth,
      canEdit: isMine && message.messageType?.name == 'TextMessage',
      // بطاقة المكالمة لا تُحوَّل، كما في `canForwardOf`.
      canForward: !isCall,
      labelOf: menuLabelOf,
      reaction: reactionOf(message),
      onReact: (emoji, from, size) => onReactPicked(message, emoji, from, size),
      onMore: () {
        rebuildMessage.value = -1;
        showReactionSheetV2(message);
      },
      onPick: (action) {
        rebuildMessage.value = -1;
        onMenuAction(action, message);
      },
    );
  }

  /// سطر الوسم والتذكير فوق فقاعة رسالة، أو `null` إن لم تحمل شيئاً منهما.
  ///
  /// يُمرَّر إلى `MessageRowV2` فيظهر على **كل** أنواع الرسائل: الصفّ يلفّها
  /// جميعاً. وهو يحلّ محلّ أيقونات الذيل في التصميم القديم.
  ///
  /// ووسمٌ واحد يُعرض وإن كانت الرسالة تحمل عدّة وسوم — التصميم يرسم حبّةً
  /// واحدة. والأوّل هو الأحدث كما يرتّبها الخادم.
  Widget? buildMessageFlags(Message message) {
    final String? tag = message.tags.isEmpty ? null : message.tags.first.tag;
    final DateTime? remindAt = message.reminder?.remindAt;
    if (tag == null && remindAt == null) return null;

    return MessageFlagsLine(
      isMine: message.senderUserId == _prefsRepository.myChatId,
      categoryName: tag,
      categoryColor: tag == null ? null : MessageCategoriesV2.colorOf(tag),
      reminderText: remindAt == null
          ? null
          : formatReminderMoment(context, remindAt),
    );
  }

  /// ترويسة المحادثة بالتصميم الجديد.
  ///
  /// الشكل كلّه من `ConversationHeader`، والأفعال من هذه الشاشة. وسطر
  /// الحالة يُمرَّر إليها لأنه ميزةٌ عندنا لا يحويها الويب.
  Widget buildHeaderV2() {
    return ValueListenableBuilder<int>(
      valueListenable: rebuildMessage,
      builder: (context, openIndex, _) => buildHeaderV2Inner(openIndex >= 0),
    );
  }

  /// الترويسة، ويُمرَّر إليها أنّ قائمةً مفتوحة لتُسقط ظلّها: الغشاوة تغطّيها
  /// أيضاً، وظلٌّ تحتها يرسم خطّاً فوق الغشاوة.
  Widget buildHeaderV2Inner(bool isMenuOpen) {
    return ConversationHeader(
      isMenuOpen: isMenuOpen,
      name: widget.fullReceiverName,
      photo: buildReceiverPhoto(),
      // عدّاد بقية المحادثات، كما في الويب.
      unreadCount: 0,
      statusLine: buildStatusLine(),
      onBack: () => Navigator.pop(context),
      onOpenProfile: () {
        if (widget.fromOrder == "true") return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProfilePage(
              receiverName: widget.receiverName,
              dataLength: widget.dataLength ?? 0,
              receiverPhoto: widget.receiverPhoto,
              senderName: widget.senderName,
              senderPhoto: widget.senderPhoto,
              fullReceiverName: widget.fullReceiverName,
              receiverPhone: widget.receiverPhone,
              chatId: widget.chatId,
            ),
          ),
        );
      },
      onVideoCall: () => startCall(isVideo: true),
      onVoiceCall: () => startCall(isVideo: false),
    );
  }

  /// صورة الطرف الآخر، أو أوّل حرفين من اسمه حين لا صورة له.
  Widget buildReceiverPhoto() {
    if (widget.receiverPhoto == null) {
      return NoImageWidget(
        height: 38,
        width: 38.w,
        textStyle: context.textTheme.bodyMedium?.bq.copyWith(
          color: const Color(0xff6638FF),
          letterSpacing: 0.18,
          height: 1.33,
        ),
        name: widget.receiverName,
      );
    }
    return MyCachedNetworkImage(
      imageUrl: widget.receiverPhoto.toString().contains("media_server")
          ? widget.receiverPhoto!
          : "${dotenv.env['Media_S3_Server']}${widget.receiverPhoto!}",
      imageFit: BoxFit.cover,
      progressIndicatorBuilderWidget: TrydosLoader(),
      height: 38,
      width: 38.w,
    );
  }

  /// ردٌّ بالتصميم الجديد: الاقتباس صفّاً، والرسالة تحته.
  ///
  /// والرسالة تُرسم بنفس المسار الذي ترسم به رسالةٌ بلا ردّ (`ignoreReply`)،
  /// فلا يُكرَّر تبديلُ الأنواع الستّة في موضعين.
  Widget buildReplyV2({
    required Message message,
    required int listIndex,
    required int menuIndex,
    required String senderName,
    required String receiverName,
    String? senderPhoto,
    String? receiverPhoto,
  }) {
    final Message parent = message.parentMessage!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        QuotedMessageV2(
          text: quoteTextOf(parent),
          time: MessageAdapterV2.timeOf(parent.createdAt),
          // نقرةٌ تقفز إلى الرسالة المقتبسة، كما تفعل واتساب.
          onOpen: () => scrollToIndex(
            currentIndextForEachMessage.value[parent.id.toString()] ?? -1,
            currentId: message.id ?? '',
            parentMessageId: message.parentMessageId!,
          ),
        ),
        getTheMessageWidget(
          listIndex: listIndex,
          menuIndex: menuIndex,
          message: message,
          senderName: senderName,
          receiverName: receiverName,
          senderPhoto: senderPhoto,
          receiverPhoto: receiverPhoto,
          ignoreReply: true,
        ),
      ],
    );
  }

  /// حروف الاقتباس: نصُّ الرسالة المقتبسة، أو نوعُها إن لم تكن نصّاً.
  String quoteTextOf(Message parent) {
    if (parent.messageType?.name == 'ShareProduct') {
      return LocaleKeys.product.tr();
    }
    final String? content = parent.messageContent?.content?.toString();
    if (content != null && content.trim().isNotEmpty) return content;
    switch (parent.messageType?.name) {
      case 'ImageMessage':
        return LocaleKeys.photo.tr();
      case 'FileMessage':
        return LocaleKeys.file.tr();
      case 'VideoMessage':
        return LocaleKeys.vvideo.tr();
      default:
        return LocaleKeys.voice.tr();
    }
  }

  /// شريط التنقّل بين نتائج البحث، مكان حقل الكتابة.
  ///
  /// منقولٌ من `searchBar` في `ConversationScreen.tsx`:
  ///
  /// > ارتفاعه 54 بحشو 12، أبيض بظلّ الترويسة؛ شيفرونان 38×38 بنفسجيّان —
  /// > يبهتان إلى 0.3 حين لا نتائج — و«n من m» 13 Medium في الطرف البعيد،
  /// > حبريةً مع النتائج ورماديةً بلاها.
  Widget buildSearchNavBar() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final List<String> results =
            state.resultOfSearchTextInChat?.items ?? [];
        searchResults = results;
        final bool hasResults = results.isNotEmpty;
        final bool typed = controller.text.trim().isNotEmpty;

        return Container(
          // 54 كارتفاع حقل الكتابة الذي يحلّ محلّه.
          height: 54.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: ChatDesign.headerShadow,
          ),
          child: Row(
            children: [
              _searchStepButton(
                isUp: true,
                enabled: hasResults,
                onTap: () {
                  final PaginationStatus? status =
                      state.resultOfSearchTextInChat?.paginationStatus;
                  if (status == null) return;
                  MoveToUpToScrollSearch(
                    status,
                    currentIndextForEachMessage.value,
                  );
                },
              ),
              _searchStepButton(
                isUp: false,
                enabled: hasResults,
                onTap: () {
                  if (indexForEveryTextInSearchResult > 0) {
                    indexForEveryTextInSearchResult--;
                  }
                  // بحثٌ جديد قد يُقصّر القائمة تحت فهرسٍ قديم، فيُحجَز
                  // الفهرس داخل حدودها قبل القراءة منها.
                  final Map<String, int> spots =
                      currentIndextForEachMessage.value;
                  if (spots.isEmpty) return;
                  final int at = indexForEveryTextInSearchResult.clamp(
                    0,
                    results.length - 1,
                  );
                  indexForEveryTextInSearchResult = at;
                  scrollToIndex(
                    spots[results[at]] ?? -1,
                    currentId: spots.keys.first,
                    forSearchText: true,
                    parentMessageId: results[at],
                  );
                },
              ),
              const Spacer(),
              DesignText(
                !typed
                    ? ''
                    : hasResults
                    ? LocaleKeys.n_of_m
                          .tr()
                          .replaceAll(
                            '{n}',
                            '${(indexForEveryTextInSearchResult < results.length ? indexForEveryTextInSearchResult : results.length - 1) + 1}',
                          )
                          .replaceAll('{m}', '${results.length}')
                    : LocaleKeys.no_results.tr(),
                size: 13,
                family: 'Quicksand-Medium',
                color: hasResults ? ContactDesign.ink : ContactDesign.grey,
              ),
            ],
          ),
        );
      },
    );
  }

  /// شيفرون 38×38 بنفسجي، يبهت إلى 0.3 حين لا نتائج.
  Widget _searchStepButton({
    required bool isUp,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.3,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 38.w,
          height: 38.h,
          child: Center(
            child: Icon(
              isUp ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 24.sp,
              color: ContactDesign.purple,
            ),
          ),
        ),
      ),
    );
  }

  /// فقاعة «يكتب الآن» أسفل المحادثة، أو فراغٌ إن لم يكن يكتب.
  ///
  /// إشارةُ الكتابة هي نفسها التي يقرؤها سطر الحالة: نشاطُ Pusher للقناة.
  Widget buildTypingBubble() {
    final int? id = int.tryParse(widget.chatId);
    if (id == null) return const SizedBox.shrink();

    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (p, c) => p.pusherActivityIds[id] != c.pusherActivityIds[id],
      builder: (context, state) {
        if (state.pusherActivityIds[id] == null) {
          return const SizedBox.shrink();
        }
        return const Align(
          // جهةٌ مطلقة: الفقاعة للطرف الآخر، ورسائله يساراً في كل اللغات.
          // و`AlignmentDirectional` كانت تقفز بها إلى اليمين في العربية.
          alignment: Alignment.centerLeft,
          child: TypingBubbleV2(),
        );
      },
    );
  }

  /// صفّ الصورتين أعلى جسم المحادثة.
  ///
  /// > صورة كل طرف 25×25 بنصف قطر 12، ومعها نقطة 6 على بعد 4 من حافّة
  /// > الشاشة: بنفسجية في جهة المحادث، و`#8D00E5` في جهتي.
  Widget buildSidePhotosRow() {
    return ChatSidePhotosRow(
      contactPhoto: buildSmallPhoto(widget.receiverPhoto, widget.receiverName),
      myPhoto: buildSmallPhoto(widget.senderPhoto, widget.senderName),
    );
  }

  /// صورةٌ صغيرة لصفّ الصورتين، أو حرفا الاسم حين لا صورة.
  Widget buildSmallPhoto(String? path, String name) {
    if (path == null) {
      return NoImageWidget(
        height: 25,
        width: 25.w,
        textStyle: context.textTheme.bodySmall?.bq.copyWith(
          color: ContactDesign.purple,
        ),
        name: name,
      );
    }
    return MyCachedNetworkImage(
      imageUrl: path.contains("media_server")
          ? path
          : "${dotenv.env['Media_S3_Server']}$path",
      imageFit: BoxFit.cover,
      progressIndicatorBuilderWidget: TrydosLoader(),
      height: 25,
      width: 25.w,
    );
  }

  /// يبدأ مكالمةً صوتيةً أو مرئية.
  ///
  /// مستخرَجٌ من زرَّي الترويسة القديمة حرفاً بحرف: نفس الأذونات ونفس
  /// التمييز بين محادثةٍ قائمة وأخرى لم تُنشأ بعد.
  Future<void> startCall({required bool isVideo}) async {
    try {
      final List<Map<String, dynamic>> info = callerInfo(
        channelId: widget.chatId,
      );
      final PermissionStatus microphone = await Permission.microphone.request();
      final status2 = await Permission.mediaLibrary.request();
      // الكاميرا للمرئية وحدها.
      final PermissionStatus? camera = isVideo
          ? await Permission.camera.request()
          : null;
      final bool granted =
          microphone.isGranted &&
          status2.isGranted &&
          (!isVideo || (camera?.isGranted ?? false));
      if (granted) {
        if (info[0].containsKey('currentReceiver')) {
          GetIt.I<CallsBloc>().add(
            MakeCallEvent(
              receiverUserId: info[0]['currentReceiver'].toString(),
              receiverCallName: widget.fullReceiverName,
              chatId: info[1]['channelId'],
              isVideo: isVideo,
              payload: info[1],
            ),
          );
        } else {
          GetIt.I<CallsBloc>().add(
            MakeCallEvent(
              isVideo: isVideo,
              receiverCallName: widget.fullReceiverName,
              chatId: info[0]['channelId'],
              payload: info[0],
            ),
          );
        }
      } else if (microphone.isDenied ||
          status2.isDenied ||
          (camera?.isDenied ?? false)) {
        if (!mounted) return;
        showWarningMessage(context, LocaleKeys.permission_denied.tr());
        openAppSettings();
      }
    } catch (e, st) {
      devLog(e);
      devLog(st);
    }
  }

  /// الترويسة القديمة — معلَّقة لا محذوفة.
  ///
  /// تبقى للرجوع إن احتاج التصميم الجديد تراجعاً: فيها زرّ الرجوع بمنطق
  /// `clickBackButton`، وصورة 40، وزرّا المكالمة بأيقوناتهما القديمة.
  Widget buildLegacyHeader() => const SizedBox.shrink();

  /// سطر حالة الطرف الآخر: «يكتب الآن» أو «متصل» أو آخر ظهور.
  ///
  /// ميزةٌ عندنا لا يحويها تصميم الويب، فأُبقيت كما هي وتُمرَّر إلى
  /// الترويسة الجديدة كما تُمرَّر إلى القديمة.
  Widget buildStatusLine() {
    // فارق التوقيت المخزَّن — كان متغيّراً محلّياً في `build`، ويقرؤه حساب
    // «آخر ظهور» أدناه.
    final int duration = GetIt.I<PrefsRepository>().getdurtion ?? 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (int.tryParse(widget.chatId) != null)
          BlocBuilder<AppBloc, AppState>(
            builder: (context, state) {
              if (state.pusherActivityIds[int.parse(widget.chatId)] != null) {
                return MyTextWidget(
                  state.pusherActivityDescription[int.parse(widget.chatId)]
                      .toString(),
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.mq.copyWith(
                    color: const Color(0xff007CFF),
                  ),
                );
              } else {
                return BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    return state.userConnectedStatuse != ' ' &&
                            DateTime.tryParse(state.userConnectedStatuse) !=
                                null
                        ? DateTime.parse(state.userConnectedStatuse)
                                      .subtract(Duration(minutes: duration))
                                      .difference(DateTime.now().toUtc())
                                      .inMinutes
                                      .abs() <=
                                  5
                              ? MyTextWidget(
                                  "Online",
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.titleMedium?.mq.copyWith(
                                    color: const Color(0xff007CFF),
                                  ),
                                )
                              : Row(
                                  children: [
                                    MyTextWidget(
                                      "أخر ظهور ",
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.titleMedium?.mq.copyWith(
                                        color: const Color(0xff007CFF),
                                      ),
                                    ),
                                    MyTextWidget(
                                      formatDate(
                                        DateTime.tryParse(
                                          state.userConnectedStatuse,
                                        )!.subtract(
                                          Duration(minutes: duration),
                                        ),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.titleMedium?.mq.copyWith(
                                        color: const Color(0xff007CFF),
                                      ),
                                    ),
                                    MyTextWidget(
                                      " الساعة ",
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.titleMedium?.mq.copyWith(
                                        color: const Color(0xff007CFF),
                                      ),
                                    ),
                                    MyTextWidget(
                                      HelperFunctions.gettimesInFormat(
                                        DateTime.tryParse(
                                          state.userConnectedStatuse,
                                        )!.subtract(
                                          Duration(minutes: duration),
                                        ),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.titleMedium?.mq.copyWith(
                                        color: const Color(0xff007CFF),
                                      ),
                                    ),
                                  ],
                                )
                        : const SizedBox.shrink();
                  },
                );
              }
            },
          ),
      ],
    );
  }
}

class MessagesDate extends StatelessWidget {
  const MessagesDate({Key? key, required this.date}) : super(key: key);
  final String date;

  String formatDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    DateTime now = DateTime.now();
    Duration difference = now.difference(date);

    if (difference.inDays == 0) {
      return LocaleKeys.today.tr();
    } else if (difference.inDays == 1) {
      return LocaleKeys.yesterday.tr();
    } else {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 78.w,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xff388cff),
            borderRadius: BorderRadius.circular(7.0),
          ),
          child: Center(
            child: MyTextWidget(
              formatDate(date),
              style: context.textTheme.titleMedium?.rq.copyWith(
                color: context.colorScheme.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// أيقونة صغيرة داخل حقل البحث في المحادثة.
///
/// `IconButton` لا يصغر بوضعه في حاوية قصيرة: له ثلاثة قيود تعمل معاً —
/// `iconSize` افتراضيّة 24، وحشوٌ 8 من كل جهة، و`constraints` بهدف لمسٍ أدناه
/// 48×48 يفرضه Material. فيتجاهل ارتفاع الصفّ المحيط ويتمدّد.
///
/// فنُلغي الثلاثة صراحةً، ونستعمل `InkResponse` بنصف قطرٍ محدود بدل حشو
/// `IconButton`: يبقى الهدف قابلاً للّمس دون أن يحجز 48 بكسلاً.
class _SearchFieldIcon extends StatelessWidget {
  const _SearchFieldIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 18,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Icon(icon, size: 16.sp, color: const Color(0xff388CFF)),
      ),
    );
  }
}

class MessageActionWidget extends StatelessWidget {
  const MessageActionWidget({
    Key? key,
    required this.onTap,
    required this.focusedIndex,
    required this.myIndex,
    required this.iconUrl,
  }) : super(key: key);
  final void Function() onTap;
  final int focusedIndex;
  final int myIndex;
  final String iconUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SvgPicture.asset(
        iconUrl,
        width: focusedIndex == myIndex ? 20.w : 15.w,
        height: focusedIndex == myIndex ? 20 : 15,
      ),
    );
  }
}

class MessageSubtitleWidget extends StatelessWidget {
  const MessageSubtitleWidget({
    Key? key,
    required this.focusedIndex,
    required this.isSent,
    required this.isText,
  }) : super(key: key);
  final int focusedIndex;
  final bool isSent;
  final bool isText;

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    bool lan = locale.languageCode != "ar";

    String hoverText = '';
    int adjustedIndex = focusedIndex;
    if (isText) {
      if (!isSent) {
        if (lan) {
          if (focusedIndex >= 4) adjustedIndex = focusedIndex + 1;
        } else {
          if (focusedIndex >= 1) adjustedIndex = focusedIndex + 1;
        }
      }
    } else {
      if (lan) {
        if (focusedIndex >= 1) adjustedIndex = focusedIndex + 1;
        if (adjustedIndex >= 4) adjustedIndex = adjustedIndex + 1;
      } else {
        if (focusedIndex >= 1) adjustedIndex = focusedIndex + 1;
        if (adjustedIndex >= 4) adjustedIndex = adjustedIndex + 1;
      }
    }

    switch (adjustedIndex) {
      case 5:
        hoverText = lan ? LocaleKeys.re_mind.tr() : LocaleKeys.forward.tr();
        break;
      case 4:
        hoverText = lan ? LocaleKeys.edit.tr() : LocaleKeys.copy.tr();
        break;
      case 3:
        hoverText = lan ? LocaleKeys.delete.tr() : LocaleKeys.category.tr();
        break;
      case 2:
        hoverText = lan ? LocaleKeys.category.tr() : LocaleKeys.delete.tr();
        break;
      case 1:
        hoverText = lan ? LocaleKeys.copy.tr() : LocaleKeys.edit.tr();
        break;
      case 0:
        hoverText = lan ? LocaleKeys.forward.tr() : LocaleKeys.re_mind.tr();
        break;
    }
    return Container(
      width: 50.w,
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0xff404040),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x34000000),
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Center(
        child: MyTextWidget(
          hoverText,
          style: context.textTheme.titleSmall?.rq.copyWith(
            color: context.colorScheme.white,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

String formatDate(DateTime dateStr) {
  DateTime now = DateTime.now();
  Duration difference = now.difference(dateStr);

  if (difference.inDays == 0) {
    return LocaleKeys.today.tr();
  } else if (difference.inDays == 1) {
    return LocaleKeys.yesterday.tr();
  } else {
    return DateFormat.yMd().format(dateStr);
  }
}
