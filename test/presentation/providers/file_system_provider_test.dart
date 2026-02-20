import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kfile_manager/domain/entities/file_entity.dart';
import 'package:kfile_manager/domain/repositories/file_system_repository.dart';
import 'package:kfile_manager/presentation/providers/file_system_provider.dart';

@GenerateNiceMocks([MockSpec<FileSystemRepository>()])
import 'file_system_provider_test.mocks.dart';

void main() {
  late MockFileSystemRepository mockRepository;
  late ProviderContainer container;

  final testFiles = [
    FileEntity(
      path: '/test/b.txt',
      name: 'b.txt',
      size: 100,
      modified: DateTime(2023, 1, 1),
      type: FileType.other,
    ),
    FileEntity(
      path: '/test/a.txt',
      name: 'a.txt',
      size: 200,
      modified: DateTime(2023, 1, 2),
      type: FileType.other,
    ),
    FileEntity(
      path: '/test/dir',
      name: 'dir',
      size: 0,
      modified: DateTime(2023, 1, 3),
      type: FileType.directory,
    ),
  ];

  setUp(() {
    mockRepository = MockFileSystemRepository();
    when(mockRepository.getRootPath()).thenAnswer((_) async => '/test');
    when(mockRepository.getFiles('/test')).thenAnswer((_) async => testFiles);
    
    container = ProviderContainer(
      overrides: [
        fileSystemRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state is loaded correctly and sorted by name with directories first', () async {
    final state = container.read(fileSystemProvider('left'));
    // Initial state before init() microtask completes
    expect(state.currentPath, '');
    
    // Wait for init() to complete
    await Future.delayed(const Duration(milliseconds: 500));
    final loadedState = container.read(fileSystemProvider('left'));
    
    expect(loadedState.currentPath, '/test');
    expect(loadedState.allFiles.length, 3);
    expect(loadedState.allFiles[0].name, 'dir'); // Directory first
    expect(loadedState.allFiles[1].name, 'a.txt'); // Then sorted by name
    expect(loadedState.allFiles[2].name, 'b.txt');
  });

  test('sorting by size works correctly', () async {
    container.read(fileSystemProvider('left')); // Trigger build and init
    await Future.delayed(const Duration(milliseconds: 500));
    container.read(fileSystemProvider('left').notifier).setSortBy(SortBy.size);
    final state = container.read(fileSystemProvider('left'));
    
    expect(state.allFiles[0].name, 'dir'); // Directory still first
    expect(state.allFiles[1].name, 'b.txt'); // 100 bytes
    expect(state.allFiles[2].name, 'a.txt'); // 200 bytes
  });

  test('category filtering works correctly', () async {
    container.read(fileSystemProvider('left')); // Trigger build and init
    await Future.delayed(const Duration(milliseconds: 500));
    container.read(fileSystemProvider('left').notifier).setCategory(FileCategory.photos);
    final state = container.read(fileSystemProvider('left'));
    
    expect(state.filteredFiles.length, 1);
    expect(state.filteredFiles[0].name, 'dir');
  });
}
