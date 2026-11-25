import 'package:flutter/foundation.dart' hide Category;
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/common/helper/show_message.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/core/utils/extensions/list.dart';
import 'package:trydos/core/utils/responsive_padding.dart';
import 'package:trydos/core/utils/theme_state.dart';
import 'package:trydos/features/chat/presentation/manager/chat_bloc.dart';
import 'package:trydos/features/chat/presentation/pages/chat_list_design.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/chat_row_v2.dart';
import 'package:trydos/features/chat/presentation/widgets/chat_v2/chat_swipe_row_v2.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import '../../../../common/helper/helper_functions.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../routes/router.dart';
import '../../../app/my_cached_network_image.dart';
import '../../../app/my_text_widget.dart';
import '../../data/models/my_chats_response_model.dart';
import '../manager/chat_event.dart';
import '../manager/chat_state.dart';
import 'package:trydos/common/helper/dev_log.dart';

class ChatCard extends StatefulWidget {
  const ChatCard({
    Key? key,
    this.index = 0,
    this.activityDescription,
    required this.chat,
    required this.thereActivity,
    this.onSendForwardMessage,
    required this.messageId,
  }) : super(key: key);
  final int index;
  final Chat chat;
  final String messageId;
  final bool thereActivity;
  final String? activityDescription;
  final Function(int receiverId, String channelId)? onSendForwardMessage;

  /// آخر محادثةٍ فُتحت — إطارُها بنفسجيّ وشريطٌ على حافّتها.
  ///
  /// مُبلِّغٌ خاصٌّ بنا لا `state.currentOpenedChatId`: ذاك يضبطه حدثُ حضورٍ
  /// من Firebase (`AddUserConntctSatuseEvent`) لا فتحُ المحادثة، فيتبدّل
  /// بتبدّل اتصال الطرف الآخر. وما نريده هنا **ما ضغط عليه المستخدم**.
  ///
  /// و`null` تعني أنه لم يفتح شيئاً بعد، فتُعلَّم الأولى افتراضاً.
  static final ValueNotifier<String?> lastOpenedV2 = ValueNotifier<String?>(
    null,
  );

  /// الصفّ المفتوحة خاناتُه الآن، أو `null`.
  ///
  /// **القائمة تملك هذا لا الصفّ**، كما في الملف: سحبُ صفٍّ يُغلق ما قبله.
  /// و`static` لأن القائمة شاشةٌ واحدة، فتمريرُ مُبلِّغٍ عبر كل بانٍ بينها
  /// وبين البطاقة لا يزيد شيئاً.
  static final ValueNotifier<String?> openRowV2 = ValueNotifier<String?>(null);

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends ThemeState<ChatCard> {
  ValueNotifier<int> typingIndicator = ValueNotifier(0);
  Timer? timer;
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  DateTime? chatTime;
  late ChatBloc chatBloc;

  @override
  void initState() {
    chatBloc = BlocProvider.of<ChatBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    typingIndicator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    chatTime = null;
    devLog('dwwdw ${widget.chat.messages}');
    if (!(widget.chat.messages.isNullOrEmpty)) {
      chatTime = widget.chat.messages!
          .firstWhere(
            (element) =>
                element.authMessageStatus!.isDeleted == 0 ||
                element.authMessageStatus!.deleteForAll!,
          )
          .createdAt!;
    }

    User? receiver = !widget.chat.channelMembers.isNullOrEmpty
        ? widget.chat.channelMembers!
              .firstWhere(
                (element) => element.userId != _prefsRepository.myChatId,
              )
              .user
        : null;

    String receiverName = HelperFunctions.getTheFirstTwoLettersOfName(
          widget.chat.channelName ?? LocaleKeys.no_channal_name.tr(),
        ),
        fullReceiverName =
            widget.chat.channelName ?? LocaleKeys.no_channal_name.tr();
    // if (receiver == null) {
    //   receiverName = 'UK';
    //   fullReceiverName = 'Unknown User';
    // } else {
    //   receiverName = receiver.contactUser == null
    //       ? receiver.name == null
    //           ? 'UK'
    //           : HelperFunctions.getTheFirstTwoLettersOfName(receiver.name!)
    //       : receiver.contactUser!.name == null
    //           ? 'UK'
    //           : HelperFunctions.getTheFirstTwoLettersOfName(
    //               receiver.contactUser!.name!);
    //   fullReceiverName = receiver.contactUser?.name ??
    //       receiver.name ??
    //       receiver.mobilePhone ??
    //       'Unknown User';
    // }
    String senderName = HelperFunctions.getTheFirstTwoLettersOfName(
      _prefsRepository.myChatName ?? LocaleKeys.no_channal_name.tr(),
    );
    devLog('meesges ${widget.chat.messages?.length}');
    devLog('meesges ${widget.chat.channelMembers?.length}');
    devLog('meesges ${widget.chat.channelName}');
    if (kDebugMode)
      devLog('_prefsRepository.myChatId ${_prefsRepository.myChatId}');

    ChannelMember? me = !widget.chat.channelMembers.isNullOrEmpty
        ? widget.chat.channelMembers?.firstWhere(
            (element) => element.userId == _prefsRepository.myChatId,
            orElse: () => ChannelMember(),
          )
        : null;
    if (me?.userId == null) {
      me = null;
    }
    // User? sender = me.user;
    // String senderName;
    // if (sender == null) {
    //   senderName = 'UK';
    // } else {
    //   senderName = sender.name == null
    //       ? 'UK'
    //       : HelperFunctions.getTheFirstTwoLettersOfName(sender.name!);
    // }
    if (widget.thereActivity && timer == null) {
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (typingIndicator.value == 5) {
          typingIndicator.value = 0;
        } else {
          typingIndicator.value++;
        }
      });
    }
    String messageType = '';
    bool isDeleteForAll = false;
    bool deleteFromMyId = false;
    if (widget.chat.messages?.length != 0) {
      messageType = (widget.chat.messages!.first.messageType?.name).toString();
      if (widget.chat.messages!.first.authMessageStatus!.isDeleted == 1) {
        deleteFromMyId =
            !(widget.chat.messages!.first.authMessageStatus!.deleteForAll ??
                false);
        isDeleteForAll =
            (widget.chat.messages!.first.authMessageStatus!.deleteForAll ??
            false);
      }
    }
    // الصفّ بالتصميم الجديد — [ChatRowFaceV2] فوق [ChatSwipeRowV2].
    //
    // الأفعال الخمسة هي أفعال `Slidable` القديمة نفسها بأحداثها نفسها، ولم
    // يتغيّر منها شيء: الترتيب والكلمات والأرقام وحدها من الملف.
    return ValueListenableBuilder<String?>(
      valueListenable: ChatCard.openRowV2,
      builder: (context, openId, _) => ValueListenableBuilder<String?>(
        valueListenable: ChatCard.lastOpenedV2,
        builder: (context, openedId, _) {
          final String id = widget.chat.id.toString();
          return ChatSwipeRowV2(
            active: openId == id,
            onActivate: () => ChatCard.openRowV2.value = id,
            onRelease: () {},
            onRest: () {
              if (ChatCard.openRowV2.value == id) {
                ChatCard.openRowV2.value = null;
              }
            },
            onOpen: () => _openChatV2(
              receiverName: receiverName,
              fullReceiverName: fullReceiverName,
              senderName: senderName,
              receiver: receiver,
            ),
            onAct: (a) => _actV2(a, me),
            labelOf: (a) => _labelV2(a, me),
            child: ChatRowFaceV2(
              name: fullReceiverName,
              time: chatTime == null
                  ? ''
                  : (!chatTime!.isUtc
                        ? HelperFunctions.getDateInFormat(chatTime!)
                        : HelperFunctions.getZonedDateInFormat(chatTime!)),
              preview: _previewTextV2(
                messageType: messageType,
                isDeleteForAll: isDeleteForAll,
                deleteFromMyId: deleteFromMyId,
              ),
              photo: _photoV2(receiver),
              initials: receiver?.photoPath == null ? receiverName : null,
              selected: (openedId ?? _defaultSelectedIdV2()) == id,
              pinned: me?.pin == 1,
              muted: me?.mute == 1,
              typing: widget.thereActivity,
              typingLabel: widget.activityDescription ?? '',
              unread: widget.chat.totalUnreadMessageCount ?? 0,
              mark: _markV2(),
              sendLines: _sendLinesV2(),
              previewIcon: _previewIconV2(messageType, isDeleteForAll),
            ),
          );
        },
      ),
    );
  }

  /// علامةُ التسليم أوّلَ المعاينة — وهي **لآخر رسالةٍ أرسلتُها أنا** وحدها.
  ///
  /// > المعاينة تبدأ بـ`|` ثخينة (أُرسلت، والمعاينة رمادية)، أو `||` (وصلت)،
  /// > أو `||` زرقاء (قُرئت).
  ///
  /// وآخرُ رسالةٍ من المحادث لا علامةَ لها: لستُ أنا من ينتظر تسليمها.
  ChatRowMarkV2? _markV2() {
    final Message? last = widget.chat.messages
        ?.where((e) => e.authMessageStatus?.isDeleted == 0)
        .firstOrNull;
    if (last == null) return null;
    if (last.senderUserId != _prefsRepository.myChatId) return null;

    final MessageStatus? st = last.authMessageStatus;
    if (st?.isWatched ?? false) return ChatRowMarkV2.read;
    if ((st?.isReceived ?? 0) == 1) return ChatRowMarkV2.delivered;
    return ChatRowMarkV2.sent;
  }

  /// أسطر «أرسِل …» — لمحادثةٍ لا رسالة فيها بعد.
  ///
  /// > «Send Photo» بعلامتها 15 عند (90، 36)، ومن x=227 أسطرُ الصوت والفيديو
  /// > والملفّ والموقع — **حتى تصير للمحادثة رسالةٌ تُعايَن**.
  ///
  /// فمتى وصلت أوّل رسالة حلّت معاينتُها محلَّها، وهو ما يفعله الملف بشرطه
  /// `row.attachments && row.preview === undefined`.
  List<ChatSendLineV2> _sendLinesV2() {
    final bool hasMessage =
        widget.chat.messages?.any((e) => e.authMessageStatus?.isDeleted == 0) ??
        false;
    if (hasMessage) return const [];
    return [
      (icon: 'chatSendPhoto', label: LocaleKeys.send_photo.tr()),
      (icon: 'chatSendVoice', label: LocaleKeys.send_voice.tr()),
      (icon: 'chatSendVideo', label: LocaleKeys.send_video.tr()),
      (icon: 'chatSendFile', label: LocaleKeys.send_file.tr()),
      (icon: 'chatSendLocation', label: LocaleKeys.send_location.tr()),
    ];
  }

  /// علامةُ نوع المعاينة حين تكون آخرُ رسالةٍ وسيطاً.
  ///
  /// هي علامات أسطر «أرسِل …» نفسها — فنوعُ الرسالة واحدٌ في الحالين، ولا
  /// معنى لعلامتين لشيءٍ واحد. ونصٌّ أو منتجٌ أو رسالةٌ محذوفة: لا علامة.
  String? _previewIconV2(String messageType, bool isDeleteForAll) {
    if (isDeleteForAll) return null;
    return switch (messageType) {
      'ImageMessage' => 'chatSendPhoto',
      'VideoMessage' => 'chatSendVideo',
      'FileMessage' => 'chatSendFile',
      'VoiceMessage' => 'chatSendVoice',
      'LocationMessage' => 'chatSendLocation',
      _ => null,
    };
  }

  /// المحادثة المعلَّمة حين لم يفتح المستخدم شيئاً بعد: **الأولى**.
  ///
  /// المثبَّتة أوّلاً إن وُجدت، وإلّا أوّل المحادثات — أي أوّل صفٍّ يراه
  /// المستخدم على الشاشة. ومعرّفٌ واحد لا `index == 0`: القائمتان منفصلتان
  /// وكلتاهما تبدأ بصفرٍ، فيُعلَّم صفّان.
  String? _defaultSelectedIdV2() {
    final ChatState s = chatBloc.state;
    final List<Chat> first = s.pinnedChats.isNotEmpty ? s.pinnedChats : s.chats;
    return first.isEmpty ? null : first.first.id?.toString();
  }

  /// صورة المحادث في الصفّ. وبلا صورةٍ يرسم [RowPhotoV2] حرفَي اسمه.
  Widget _photoV2(User? receiver) {
    final String? path = receiver?.photoPath;
    if (path == null) return const SizedBox.shrink();
    return MyCachedNetworkImage(
      imageUrl: path.contains('media_server')
          ? path
          : '${dotenv.env['Media_S3_Server']}$path',
      imageFit: BoxFit.cover,
      width: ChatListDesign.photoW.w,
      height: ChatListDesign.photoH.h,
      // بلا تدويرٍ داخليّ: [RowPhotoV2] يقصّ بنصف قطر 15، وتدويران مختلفان
      // يتركان فجواتٍ بيضاء عند الأطراف.
      radius: 0,
    );
  }

  /// كلمات المعاينة — نفس سلسلة شروط الصفّ القديم، مستخرجةً لأن
  /// [ChatRowFaceV2] يأخذ نصّاً لا شجرة ودجات.
  String _previewTextV2({
    required String messageType,
    required bool isDeleteForAll,
    required bool deleteFromMyId,
  }) {
    if (isDeleteForAll) {
      return deleteFromMyId
          ? LocaleKeys.you_have_deleted_this_message.tr()
          : LocaleKeys.this_message_has_been_deleted.tr();
    }
    final Message? last = widget.chat.messages
        ?.where((e) => e.authMessageStatus?.isDeleted == 0)
        .firstOrNull;
    if (messageType == 'TextMessage') {
      return last?.messageContent?.content?.toString() ?? '';
    }
    if (messageType == 'ShareProduct') {
      return last?.shareProductContent?.productName ?? '';
    }
    return switch (messageType) {
      'ImageMessage' => LocaleKeys.photo.tr(),
      'VideoMessage' => LocaleKeys.vvideo.tr(),
      'FileMessage' => LocaleKeys.file.tr(),
      'VoiceCall' => LocaleKeys.voice_call.tr(),
      'VideoCall' => LocaleKeys.video_call.tr(),
      _ => LocaleKeys.voice.tr(),
    };
  }

  /// كلمة الخانة — تنقلب بحالة المحادثة كما في الصفّ القديم.
  String _labelV2(ChatSwipeActionV2 a, ChannelMember? me) => switch (a) {
    ChatSwipeActionV2.mute =>
      me?.mute == 0 ? LocaleKeys.mute.tr() : LocaleKeys.un_mute.tr(),
    ChatSwipeActionV2.delete => LocaleKeys.delete.tr(),
    ChatSwipeActionV2.archive =>
      widget.chat.isArchivedForMe(_prefsRepository.myChatId)
          ? LocaleKeys.un_archive.tr()
          : LocaleKeys.archive.tr(),
    ChatSwipeActionV2.unread =>
      (widget.chat.totalUnreadMessageCount ?? 0) > 0
          ? LocaleKeys.read.tr()
          : LocaleKeys.mark_as_unread.tr(),
    ChatSwipeActionV2.pin =>
      me?.pin == 0 ? LocaleKeys.pin.tr() : LocaleKeys.un_pin.tr(),
  };

  /// الأفعال الخمسة بأحداثها — هي أحداث `Slidable` القديمة بلا تغيير.
  void _actV2(ChatSwipeActionV2 a, ChannelMember? me) {
    switch (a) {
      case ChatSwipeActionV2.archive:
        chatBloc.add(
          ArchiveChatEvent(
            channelId: widget.chat.id!,
            archived: !widget.chat.isArchivedForMe(_prefsRepository.myChatId),
          ),
        );
      case ChatSwipeActionV2.delete:
        chatBloc.add(DeleteChatEvent(channelId: widget.chat.id!));
      case ChatSwipeActionV2.mute:
        if (me?.id == null) return;
        chatBloc.add(
          ChangeChatPropertyEvent(
            channelId: widget.chat.id!,
            memberId: me!.id!,
            userId: _prefsRepository.myChatId!,
            mute: 1 - (me.mute ?? 0),
          ),
        );
      case ChatSwipeActionV2.unread:
        // فيها غير مقروء تُقرأ، ومقروءة تُعلَّم كغير مقروءة — حدثان لا واحد.
        final String channelId = widget.chat.id.toString();
        if ((widget.chat.totalUnreadMessageCount ?? 0) > 0) {
          chatBloc.add(ReadAllMessagesEvent(channelId));
        } else {
          chatBloc.add(MarkChatUnreadEvent(channelId: channelId));
        }
      case ChatSwipeActionV2.pin:
        // ثلاثُ مثبَّتاتٍ على الأكثر — الحدّ نفسه الذي يحرسه الصفّ القديم.
        if (chatBloc.state.pinnedChats.length == 3 && me?.pin == 0) {
          showWarningMessage(
            context,
            LocaleKeys.you_can_have_at_most_3_pinned.tr(),
          );
          return;
        }
        if (me?.id == null) return;
        chatBloc.add(
          ChangeChatPropertyEvent(
            channelId: widget.chat.id!,
            memberId: me!.id!,
            userId: _prefsRepository.myChatId!,
            pin: 1 - (me.pin ?? 0),
          ),
        );
    }
  }

  /// فتح المحادثة — نفس مسار النقر القديم حرفاً بحرف.
  void _openChatV2({
    required String receiverName,
    required String fullReceiverName,
    required String senderName,
    required User? receiver,
  }) {
    ChatCard.lastOpenedV2.value = widget.chat.id.toString();
    chatBloc.add(
      ChangeGlobalUsedVariablesInBloc(currentOpenedChatId: widget.chat.id),
    );
    widget.onSendForwardMessage?.call(
      widget.chat.channelMembers!
          .firstWhere((e) => e.userId != GetIt.I<PrefsRepository>().myChatId)
          .userId!,
      widget.chat.id.toString(),
    );
    context.go(
      '${GRouter.config.applicationRoutes.kSinglePageChatPagePath}'
      '?chatId=${widget.chat.id}'
      '&data_length=${widget.chat.messages?.length ?? 0}'
      '&receiverName=$receiverName'
      '&fullReceiverName=$fullReceiverName'
      '&receiverPhone=${receiver?.mobilePhone ?? 'Uo Number'}'
      '&senderName=$senderName'
      '&receiverPhoto=${receiver?.photoPath}'
      '&senderPhoto=${_prefsRepository.myChatPhoto}',
    );
  }
}

class SlidableActionWidget extends StatelessWidget {
  const SlidableActionWidget({
    Key? key,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.iconUrl,
    required this.onTap,
    required this.text,
  }) : super(key: key);
  final Color backgroundColor;
  final Color foregroundColor;
  final String iconUrl;
  final String text;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap.call();
        Slidable.of(context)?.close();
      },
      child: Container(
        width: 85.w,
        height: 92.h,
        margin: HWEdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(width: 0.5, color: const Color(0xffd3d3d3)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(iconUrl, width: 25.h, height: 25.h),
              8.verticalSpace,
              MyTextWidget(
                text,
                style: context.textTheme.titleMedium?.rq.copyWith(
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
