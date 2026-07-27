import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/common/helper/camera_screen_story.dart';
import 'package:trydos/common/helper/show_message.dart';

import 'package:trydos/features/app/app_widgets/app_text_field.dart';
import 'package:trydos/features/app/app_widgets/crop_image_screen.dart';

import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'package:wechat_assets_picker/wechat_assets_picker.dart';

// ignore: must_be_immutable
class AddLinkToStory extends StatefulWidget {
  File? imageFile;
  void Function(AssetEntity? assetEntity) onChooseFileFromGalleryAction;
  File? vedioFile;
  AssetEntity? assetEntity;
  AddLinkToStory(this.imageFile, this.assetEntity, this.vedioFile,
      this.onChooseFileFromGalleryAction,
      {super.key});

  @override
  _AddLinkToStory createState() => _AddLinkToStory();
}

class _AddLinkToStory extends State<AddLinkToStory> {
  late StoryBloc storyBloc;
  String? link;

  /// ناتج القص — يبقى null ما لم يقصّ المستخدم الصورة.
  File? croppedFile;

  @override
  void initState() {
    storyBloc = BlocProvider.of<StoryBloc>(context);
    storyBloc.add(const SetStoryLinkEvent(""));

    super.initState();
  }

  Future<void> cropImage() async {
    final File? result = await Navigator.of(context).push<File>(
      MaterialPageRoute(
        builder: (_) =>
            CropImageScreen(imageFile: croppedFile ?? widget.imageFile!),
      ),
    );
    if (result != null && mounted) {
      setState(() => croppedFile = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          widget.vedioFile != null
              ? Container(
                  width: double.infinity,
                  height: MediaQuery.sizeOf(context).height * 0.76,
                  child: VideoPlayerWidget(widget.vedioFile!),
                )
              : Stack(
                  children: [
                    Container(
                      width: 1.sw,
                      height: MediaQuery.sizeOf(context).height * 0.78,
                      // خلفية سوداء: مع contain تظهر مساحة فارغة حول الصورة
                      // حين تختلف نسبتها عن نسبة الحاوية.
                      color: Colors.black,
                      child: Image.file(
                        // مسار الملف المقصوص جديد في كل قصّة، والمفتاح يمنع
                        // إعادة استخدام الصورة القديمة من الكاش.
                        key: ValueKey((croppedFile ?? widget.imageFile!).path),
                        croppedFile ?? widget.imageFile!,
                        // كان cover: يملأ الحاوية بقصّ الصورة وتكبيرها، فلا
                        // يرى المستخدم ما سيرفعه فعلاً.
                        fit: BoxFit.contain,
                      ),
                    ),
                    PositionedDirectional(
                      // الحاوية تبدأ من أعلى الشاشة (لا SafeArea)، فبدون إزاحة
                      // شريط الحالة يقع الزر خلفه.
                      top: MediaQuery.paddingOf(context).top + 16,
                      end: 16,
                      child: FloatingActionButton(
                        heroTag: 'cropStoryImage',
                        mini: true,
                        backgroundColor: Colors.blue,
                        tooltip: LocaleKeys.crop_image.tr(),
                        onPressed: cropImage,
                        child: const Icon(Icons.crop, color: Colors.white),
                      ),
                    ),
                  ],
                ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: AppTextField(
              onChange: (val) {
                link = val;
                storyBloc.add(SetStoryLinkEvent(val));
              },
              textInputAction: TextInputAction.done,
              onEditingComplete: () {
                Future.delayed(const Duration(milliseconds: 300),
                    () => FocusScope.of(context).unfocus());
              },
              onFieldSubmitted: (val) {
                Future.delayed(const Duration(milliseconds: 300),
                    () => FocusScope.of(context).unfocus());
              },
              hintText: '${LocaleKeys.add_link_to_story.tr()}',
            ),
          ),
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.green, borderRadius: BorderRadius.circular(40)),
            width: 70,
            height: 70,
            child: InkWell(
                onTap: () {
                  if (link?.contains("coupon") ?? false) {
                    showWarningMessage(context, "Coupon link is not allowed");
                    return;
                  }
                  // المسار الافتراضي يمرّر assetEntity، ومستهلكه يعيد قراءة
                  // originFile — أي الأصل قبل القص. لذا نرفع الملف المقصوص
                  // مباشرةً عبر البلوك عند وجوده.
                  if (croppedFile != null) {
                    storyBloc.add(UploadStoryCloudinaryEvent(croppedFile!));
                  } else {
                    widget.onChooseFileFromGalleryAction
                        .call(widget.assetEntity);
                  }
                  Navigator.of(context).pop();
                },
                child: Text("${LocaleKeys.send.tr()}")),
          ),
        ],
      ),
    ));
  }
}
