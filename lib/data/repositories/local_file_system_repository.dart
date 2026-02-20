import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:archive/archive_io.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/repositories/file_system_repository.dart';

class LocalFileSystemRepository implements FileSystemRepository {
  @override
  Future<List<FileEntity>> getFiles(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      throw Exception('Directory does not exist');
    }

    final List<FileEntity> files = [];
    await for (final entity in directory.list()) {
      final stat = await entity.stat();
      final name = p.basename(entity.path);
      final extension = p.extension(entity.path).toLowerCase();
      
      files.add(FileEntity(
        path: entity.path,
        name: name,
        size: stat.size,
        modified: stat.modified,
        type: _mapFileType(entity, extension),
        extension: extension,
      ));
    }
    return files;
  }

  @override
  Future<void> createDirectory(String path) async {
    final directory = Directory(path);
    if (await directory.exists()) {
      throw Exception('Directory already exists');
    }
    await directory.create(recursive: true);
  }

  @override
  Future<void> rename(String oldPath, String newPath) async {
    final entity = FileSystemEntity.isFileSync(oldPath) ? File(oldPath) : Directory(oldPath);
    await entity.rename(newPath);
  }

  @override
  Future<void> delete(String path) async {
    final entity = FileSystemEntity.isFileSync(path) ? File(path) : Directory(path);
    await entity.delete(recursive: true);
  }

  @override
  Future<String> getRootPath() async {
    if (kIsWeb) return '/';
    if (Platform.isAndroid) {
      return '/storage/emulated/0';
    } else {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  @override
  Future<bool> exists(String path) async {
    return await FileSystemEntity.type(path) != FileSystemEntityType.notFound;
  }

  @override
  Future<void> openFile(String path) async {
    await OpenFilex.open(path);
  }

  @override
  Future<void> compressToZip(List<String> paths, String zipPath) async {
    final encoder = ZipFileEncoder();
    encoder.create(zipPath);
    for (final path in paths) {
      if (FileSystemEntity.isFileSync(path)) {
        encoder.addFile(File(path));
      } else if (FileSystemEntity.isDirectorySync(path)) {
        encoder.addDirectory(Directory(path));
      }
    }
    encoder.close();
  }

  @override
  Future<void> copy(String sourcePath, String destinationPath) async {
    if (FileSystemEntity.isFileSync(sourcePath)) {
      await File(sourcePath).copy(destinationPath);
    } else if (FileSystemEntity.isDirectorySync(sourcePath)) {
      await _copyDirectory(Directory(sourcePath), Directory(destinationPath));
    }
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create(recursive: true);
    await for (final entity in source.list(recursive: false)) {
      if (entity is Directory) {
        final newDirectory = Directory(p.join(destination.absolute.path, p.basename(entity.path)));
        await _copyDirectory(entity, newDirectory);
      } else if (entity is File) {
        await entity.copy(p.join(destination.path, p.basename(entity.path)));
      }
    }
  }

  @override
  Future<void> decompressZip(String zipPath, String destinationPath) async {
    final bytes = await File(zipPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File(p.join(destinationPath, filename))
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(p.join(destinationPath, filename)).createSync(recursive: true);
      }
    }
  }

  FileType _mapFileType(FileSystemEntity entity, String extension) {
    if (entity is Directory) {
      return FileType.directory;
    }
    
    switch (extension) {
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.webp':
        return FileType.image;
      case '.mp4':
      case '.mov':
      case '.avi':
      case '.mkv':
        return FileType.video;
      case '.mp3':
      case '.wav':
      case '.flac':
      case '.m4a':
        return FileType.audio;
      case '.zip':
      case '.rar':
      case '.7z':
      case '.tar':
      case '.gz':
        return FileType.archive;
      case '.pdf':
        return FileType.pdf;
      case '.apk':
        return FileType.apk;
      default:
        return FileType.other;
    }
  }
}
