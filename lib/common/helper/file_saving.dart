
import 'dart:developer';
import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:get_it/get_it.dart';

import '../../core/domin/repositories/prefs_repository.dart';
final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
class FileSaving {
  getFilePath(String fileName )  {
    return savePath+fileName;
  }
static String savePath='/storage/emulated/0/Android/data/com.example.trydos/files/';
   downloadFileToLocalStorage(String fileUrl , {void Function(File file)? action}) async {
    String fileName = fileUrl.split('/').last;
await FileSaver.instance.saveFile(name: fileName,link: LinkDetails(link: fileUrl)).then((value) {
      _prefsRepository.setAFilePathExist(fileUrl);
      File file=File(value);
      action?.call(file);
      return value;
    });
  }

  Future<File?> checkExistence(String? fileUrl , String fileName,  {bool download=true ,void Function(File? file)? action}) async {
    if(fileUrl==null){
      return null;
    }
    String fileName=fileUrl.split('/').last;
    String path = await getFilePath(fileName);
    print('check path : $path');
    File file = File(path);
    bool exist = await file.exists();
    print('exist? : $exist');
    if(exist){
      return file;
    }
    else if(download){
      print('go to download');
      await downloadFileToLocalStorage(fileUrl , action : action);
      return null;
    }
    return null;
  }
  saveFileToSpecificDirectory(File file) async{
    String fileName = file.path.split('/').last;
    String val = await FileSaver.instance.saveFile(name: fileName,file: file);
    log('name : $fileName');
    log('val : $val');
  }
}