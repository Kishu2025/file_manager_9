import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../domain/entities/file_entity.dart';
import '../../domain/repositories/file_system_repository.dart';
import '../../data/repositories/local_file_system_repository.dart';

final fileSystemRepositoryProvider = Provider<FileSystemRepository>((ref) {
  return LocalFileSystemRepository();
});

enum SortBy { name, size, date }
enum SortOrder { ascending, descending }
enum FileCategory { all, photos, videos, music, documents, apks }

class FileSystemState {
  final String currentPath;
  final List<FileEntity> allFiles;
  final List<FileEntity> filteredFiles;
  final bool isLoading;
  final String? error;
  final SortBy sortBy;
  final SortOrder sortOrder;
  final FileCategory category;
  final String? searchQuery;

  FileSystemState({
    required this.currentPath,
    required this.allFiles,
    required this.filteredFiles,
    this.isLoading = false,
    this.error,
    this.sortBy = SortBy.name,
    this.sortOrder = SortOrder.ascending,
    this.category = FileCategory.all,
    this.searchQuery,
  });

  FileSystemState copyWith({
    String? currentPath,
    List<FileEntity>? allFiles,
    List<FileEntity>? filteredFiles,
    bool? isLoading,
    String? error,
    SortBy? sortBy,
    SortOrder? sortOrder,
    FileCategory? category,
    String? searchQuery,
  }) {
    return FileSystemState(
      currentPath: currentPath ?? this.currentPath,
      allFiles: allFiles ?? this.allFiles,
      filteredFiles: filteredFiles ?? this.filteredFiles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      category: category ?? this.category,
      searchQuery: searchQuery,
    );
  }
}

class FileSystemNotifier extends StateNotifier<FileSystemState> {
  final FileSystemRepository _repository;
  final String paneId;

  FileSystemNotifier(this._repository, this.paneId) : super(FileSystemState(currentPath: '', allFiles: [], filteredFiles: [])) {
    init();
  }

  Future<void> init() async {
    state = state.copyWith(isLoading: true);
    try {
      final rootPath = await _repository.getRootPath();
      await loadDirectory(rootPath);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadDirectory(String path) async {
    state = state.copyWith(isLoading: true, currentPath: path, searchQuery: null);
    try {
      final files = await _repository.getFiles(path);
      final sortedFiles = _sortFiles(files, state.sortBy, state.sortOrder);
      state = state.copyWith(
        allFiles: sortedFiles,
        filteredFiles: _filterFiles(sortedFiles, state.category, null),
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(
      searchQuery: query,
      filteredFiles: _filterFiles(state.allFiles, state.category, query),
    );
  }

  void setSortBy(SortBy sortBy) {
    final sorted = _sortFiles(state.allFiles, sortBy, state.sortOrder);
    state = state.copyWith(
      sortBy: sortBy,
      allFiles: sorted,
      filteredFiles: _filterFiles(sorted, state.category, state.searchQuery),
    );
  }

  void toggleSortOrder() {
    final newOrder = state.sortOrder == SortOrder.ascending ? SortOrder.descending : SortOrder.ascending;
    final sorted = _sortFiles(state.allFiles, state.sortBy, newOrder);
    state = state.copyWith(
      sortOrder: newOrder,
      allFiles: sorted,
      filteredFiles: _filterFiles(sorted, state.category, state.searchQuery),
    );
  }

  void setCategory(FileCategory category) {
    state = state.copyWith(
      category: category,
      filteredFiles: _filterFiles(state.allFiles, category, state.searchQuery),
    );
  }

  List<FileEntity> _filterFiles(List<FileEntity> files, FileCategory category, String? query) {
    return files.where((file) {
      bool matchesCategory = true;
      if (category != FileCategory.all && !file.isDirectory) {
        switch (category) {
          case FileCategory.photos:
            matchesCategory = file.type == FileType.image;
            break;
          case FileCategory.videos:
            matchesCategory = file.type == FileType.video;
            break;
          case FileCategory.music:
            matchesCategory = file.type == FileType.audio;
            break;
          case FileCategory.documents:
            matchesCategory = file.type == FileType.pdf || file.extension == '.docx' || file.extension == '.txt';
            break;
          case FileCategory.apks:
            matchesCategory = file.type == FileType.apk;
            break;
          default:
            matchesCategory = true;
        }
      }

      bool matchesQuery = true;
      if (query != null && query.isNotEmpty) {
        matchesQuery = file.name.toLowerCase().contains(query.toLowerCase());
      }

      return matchesCategory && matchesQuery;
    }).toList();
  }

  List<FileEntity> _sortFiles(List<FileEntity> files, SortBy sortBy, SortOrder sortOrder) {
    final sorted = List<FileEntity>.from(files);
    sorted.sort((a, b) {
      if (a.isDirectory && !b.isDirectory) return -1;
      if (!a.isDirectory && b.isDirectory) return 1;

      int comparison;
      switch (sortBy) {
        case SortBy.name:
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case SortBy.size:
          comparison = a.size.compareTo(b.size);
          break;
        case SortBy.date:
          comparison = a.modified.compareTo(b.modified);
          break;
      }
      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    });
    return sorted;
  }

  Future<void> refresh() async {
    await loadDirectory(state.currentPath);
  }

  Future<void> navigateUp() async {
    if (state.currentPath.isEmpty) return;
    final parentPath = Uri.file(state.currentPath).resolve('..').toFilePath();
    if (parentPath != state.currentPath) {
      await loadDirectory(parentPath);
    }
  }

  Future<void> createDirectory(String path) async {
    try {
      await _repository.createDirectory(path);
      await refresh();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> rename(String oldPath, String newPath) async {
    try {
      await _repository.rename(oldPath, newPath);
      await refresh();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> delete(String path) async {
    try {
      await _repository.delete(path);
      await refresh();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> openFile(String path) async {
    try {
      await _repository.openFile(path);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> compressToZip(List<String> paths, String zipPath) async {
    try {
      await _repository.compressToZip(paths, zipPath);
      await refresh();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> decompressZip(String zipPath, String destinationPath) async {
    try {
      await _repository.decompressZip(zipPath, destinationPath);
      await refresh();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> copyTo(String sourcePath, String destinationDir) async {
    try {
      final destPath = p.join(destinationDir, p.basename(sourcePath));
      await _repository.copy(sourcePath, destPath);
      if (state.currentPath == destinationDir) {
        await refresh();
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final fileSystemProvider = StateNotifierProvider.family<FileSystemNotifier, FileSystemState, String>((ref, paneId) {
  final repository = ref.watch(fileSystemRepositoryProvider);
  return FileSystemNotifier(repository, paneId);
});
