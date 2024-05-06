import 'dart:io';

String readJson(String name) {
  var dir = Directory.current.path;
  print(dir);
  if (dir.endsWith('/test')) {
    dir = dir.replaceAll('/test', '');
  }
  return File('$dir/test/$name').readAsStringSync();
}