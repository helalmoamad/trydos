import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trydos/common/helper/camera_screen_story.dart';

import 'package:trydos/features/app/app_widgets/app_text_field.dart';

import 'package:trydos/features/story/presentation/bloc/story_bloc.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class AddLinkToStory extends StatefulWidget {
  File? imageFile;
  void Function(AssetEntity? assetEntity) onChooseFileFromGalleryAction;
  File? vedioFile;
  AssetEntity? assetEntity;
  AddLinkToStory(
    this.imageFile,
    this.assetEntity,
    this.vedioFile,
    this.onChooseFileFromGalleryAction,
  );

  @override
  _AddLinkToStory createState() => _AddLinkToStory();
}

class _AddLinkToStory extends State<AddLinkToStory> {
  late StoryBloc storyBloc;

  @override
  void initState() {
    storyBloc = BlocProvider.of<StoryBloc>(context);
    storyBloc.add(SetStoryLinkEvent(""));

    super.initState();
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
              : Container(
                  width: 1.sw,
                  height: MediaQuery.sizeOf(context).height * 0.78,
                  child: Image.file(
                    widget.imageFile!,
                    fit: BoxFit.cover,
                  ),
                ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: AppTextField(
              onChange: (val) {
                storyBloc.add(SetStoryLinkEvent(val));
              },
              textInputAction: TextInputAction.done,
              onEditingComplete: () {
                Future.delayed(Duration(milliseconds: 300),
                    () => FocusScope.of(context).unfocus());
              },
              onFieldSubmitted: (val) {
                Future.delayed(Duration(milliseconds: 300),
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
                  widget.onChooseFileFromGalleryAction.call(widget.assetEntity);
                  Navigator.of(context).pop();
                },
                child: Text("${LocaleKeys.send.tr()}")),
          ),
        ],
      ),
    ));
  }
}
