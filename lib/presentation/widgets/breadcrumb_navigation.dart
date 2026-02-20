import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/file_system_provider.dart';
import '../../core/theme.dart';

class BreadcrumbNavigation extends ConsumerWidget {
  final String paneId;
  const BreadcrumbNavigation({super.key, required this.paneId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fileSystemProvider(paneId));
    final parts = state.currentPath.split('/').where((p) => p.isNotEmpty).toList();

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: parts.length + 1,
        separatorBuilder: (context, index) => const Icon(LucideIcons.chevronRight, size: 14, color: Colors.white24),
        itemBuilder: (context, index) {
          if (index == 0) {
            return IconButton(
              icon: const Icon(LucideIcons.home, size: 16, color: NeonTheme.neonBlue),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () async {
                final root = await ref.read(fileSystemRepositoryProvider).getRootPath();
                ref.read(fileSystemProvider(paneId).notifier).loadDirectory(root);
              },
            );
          }
          
          final path = '/${parts.sublist(0, index).join('/')}';
          return TextButton(
            onPressed: () => ref.read(fileSystemProvider(paneId).notifier).loadDirectory(path),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              parts[index - 1],
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          );
        },
      ),
    );
  }
}
