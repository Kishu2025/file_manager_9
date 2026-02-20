enum FileType {
  file,
  directory,
  image,
  video,
  audio,
  archive,
  pdf,
  apk,
  other,
}

class FileEntity {
  final String path;
  final String name;
  final int size;
  final DateTime modified;
  final FileType type;
  final String? extension;

  FileEntity({
    required this.path,
    required this.name,
    required this.size,
    required this.modified,
    required this.type,
    this.extension,
  });

  bool get isDirectory => type == FileType.directory;
}
