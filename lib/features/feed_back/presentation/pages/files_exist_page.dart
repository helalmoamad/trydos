import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/config/theme/typography.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';

import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../app/my_text_widget.dart';

class FilesExistPage extends StatelessWidget {
  FilesExistPage({super.key});

  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  @override
  Widget build(BuildContext context) {
    final List<String> files = prefsRepository.getExistenceFiles();
    return Scaffold(
      backgroundColor: context.colorScheme.background,
      body: files.length == 0
          ? Center(
              child: MyTextWidget('No Files'),
            )
          : ListView.builder(
              itemBuilder: (context, index) {
                Map file = jsonDecode(files[index]);
                return Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: Colors.black, blurRadius: 5)
                      ]),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyTextWidget(file.values.toString(),
                            style: context.textTheme.bodyMedium?.rr
                                .copyWith(color: Colors.black)),
                      ],
                    ),
                  ),
                );
              },
              itemCount: files.length,
            ),
    );
  }
}
