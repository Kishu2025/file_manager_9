import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../providers/file_system_provider.dart';

class CategoryTabs extends ConsumerWidget {
  final String paneId;
  const CategoryTabs({super.key, required this.paneId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCategory = ref.watch(fileSystemProvider(paneId).select((s) => s.category));

    return Container(
      height: 44,
      color: Colors.black,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: [
          _CategoryTab(
            label: 'All',
            isSelected: currentCategory == FileCategory.all,
            onTap: () => ref.read(fileSystemProvider(paneId).notifier).setCategory(FileCategory.all),
          ),
          _CategoryTab(
            label: 'Photos',
            isSelected: currentCategory == FileCategory.photos,
            onTap: () => ref.read(fileSystemProvider(paneId).notifier).setCategory(FileCategory.photos),
          ),
          _CategoryTab(
            label: 'Videos',
            isSelected: currentCategory == FileCategory.videos,
            onTap: () => ref.read(fileSystemProvider(paneId).notifier).setCategory(FileCategory.videos),
          ),
          _CategoryTab(
            label: 'Music',
            isSelected: currentCategory == FileCategory.music,
            onTap: () => ref.read(fileSystemProvider(paneId).notifier).setCategory(FileCategory.music),
          ),
          _CategoryTab(
            label: 'Docs',
            isSelected: currentCategory == FileCategory.documents,
            onTap: () => ref.read(fileSystemProvider(paneId).notifier).setCategory(FileCategory.documents),
          ),
          _CategoryTab(
            label: 'APKs',
            isSelected: currentCategory == FileCategory.apks,
            onTap: () => ref.read(fileSystemProvider(paneId).notifier).setCategory(FileCategory.apks),
          ),
        ],
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? NeonTheme.neonBlue.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? NeonTheme.neonBlue : Colors.white10,
              width: 0.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? NeonTheme.neonBlue : Colors.white60,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
