import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

/// Stores relative paths so photos also survive a change in the iOS sandbox path.
class UserPhotoStorage {
  UserPhotoStorage({Future<Directory> Function()? documentsDirectory})
    : _documentsDirectory =
          documentsDirectory ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _documentsDirectory;

  Future<String> save(String sourcePath) async {
    final root = await _documentsDirectory();
    final directory = Directory('${root.path}/assets/images');
    await directory.create(recursive: true);
    final extension = sourcePath.split('.').last.toLowerCase();
    final suffix = RegExp(r'^[a-z0-9]{1,5}$').hasMatch(extension)
        ? '.$extension'
        : '.jpg';
    final name =
        'user_${DateTime.now().microsecondsSinceEpoch}_'
        '${Random.secure().nextInt(1 << 32)}$suffix';
    final relativePath = 'assets/images/$name';
    final target = File('${root.path}/$relativePath');
    try {
      final bytes = await File(sourcePath).readAsBytes();
      if (bytes.isEmpty) throw const FileSystemException('Foto vazia');
      await target.writeAsBytes(bytes, flush: true);
      return relativePath;
    } catch (_) {
      if (await target.exists()) await target.delete();
      rethrow;
    }
  }

  Future<File> resolve(String relativePath) async {
    if (!RegExp(
      r'^assets/images/user_[a-zA-Z0-9_.]+$',
    ).hasMatch(relativePath)) {
      throw ArgumentError.value(relativePath, 'relativePath');
    }
    final root = await _documentsDirectory();
    return File('${root.path}/$relativePath');
  }

  Future<void> delete(String relativePath) async {
    final file = await resolve(relativePath);
    if (await file.exists()) await file.delete();
  }
}
