import '../entities/file_entity.dart';

abstract class FileSystemRepository {
  Future<List<FileEntity>> getFiles(String path);
  Future<void> createDirectory(String path);
  Future<void> rename(String oldPath, String newPath);
  Future<void> delete(String path);
  Future<String> getRootPath();
  Future<bool> exists(String path);
  Future<void> openFile(String path);
  Future<void> compressToZip(List<String> paths, String zipPath);
  Future<void> decompressZip(String zipPath, String destinationPath);
  Future<void> copy(String sourcePath, String destinationPath);
}
