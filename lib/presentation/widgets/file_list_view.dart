import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../providers/file_system_provider.dart';
import '../../domain/entities/file_entity.dart';
import '../../core/theme.dart';
import 'dialogs/rename_dialog.dart';
import 'dialogs/delete_confirmation_dialog.dart';
import 'dialogs/file_properties_dialog.dart';

class FileListView extends ConsumerWidget {
  final String paneId;
  const FileListView({super.key, required this.paneId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fileSystemProvider(paneId));
    final files = state.filteredFiles;

    if (files.isEmpty) {
      return const Center(child: Text('No files found', style: TextStyle(color: Colors.white24)));
    }

    return Column(
      children: [
        if (state.searchQuery != null)
          _SearchIndicator(paneId: paneId, query: state.searchQuery!),
        Expanded(
          child: ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              return ListTile(
                dense: true,
                leading: _getFileIcon(file),
                title: Text(file.name, style: const TextStyle(color: Colors.white, fontSize: 13), overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  '${_formatSize(file.size)} • ${DateFormat('MM/dd/yy').format(file.modified)}',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
                onTap: () {
                  if (file.isDirectory) {
                    ref.read(fileSystemProvider(paneId).notifier).loadDirectory(file.path);
                  } else {
                    ref.read(fileSystemProvider(paneId).notifier).openFile(file.path);
                  }
                },
                trailing: PopupMenuButton<String>(
                  icon: const Icon(LucideIcons.moreVertical, size: 16, color: Colors.white38),
                  color: const Color(0xFF1A1A1A),
                  onSelected: (value) async {
                    if (value == 'rename') {
                      showDialog(
                        context: context,
                        builder: (context) => RenameDialog(file: file, paneId: paneId),
                      );
                    } else if (value == 'delete') {
                      showDialog(
                        context: context,
                        builder: (context) => DeleteConfirmationDialog(file: file, paneId: paneId),
                      );
                    } else if (value == 'zip') {
                      final zipPath = '${file.path}.zip';
                      await ref.read(fileSystemProvider(paneId).notifier).compressToZip([file.path], zipPath);
                    } else if (value == 'extract') {
                      final dest = file.path.replaceAll('.zip', '');
                      await ref.read(fileSystemProvider(paneId).notifier).decompressZip(file.path, dest);
                    } else if (value == 'properties') {
                      showDialog(
                        context: context,
                        builder: (context) => FilePropertiesDialog(file: file),
                      );
                    } else if (value == 'copy_other') {
                      final otherPaneId = paneId == 'left' ? 'right' : 'left';
                      final otherState = ref.read(fileSystemProvider(otherPaneId));
                      await ref.read(fileSystemProvider(paneId).notifier).copyTo(file.path, otherState.currentPath);
                      ref.read(fileSystemProvider(otherPaneId).notifier).refresh();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'rename', child: Text('Rename', style: TextStyle(fontSize: 13))),
                    const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(fontSize: 13, color: NeonTheme.accentRed))),
                    if (file.type == FileType.archive)
                      const PopupMenuItem(value: 'extract', child: Text('Extract (ZIP)', style: TextStyle(fontSize: 13)))
                    else
                      const PopupMenuItem(value: 'zip', child: Text('Compress (ZIP)', style: TextStyle(fontSize: 13))),
                    if (MediaQuery.of(context).size.width > 900)
                      const PopupMenuItem(value: 'copy_other', child: Text('Copy to other pane', style: TextStyle(fontSize: 13))),
                    const PopupMenuItem(value: 'properties', child: Text('Properties', style: TextStyle(fontSize: 13))),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _getFileIcon(FileEntity file) {
    IconData icon;
    Color color;

    if (file.isDirectory) {
      icon = LucideIcons.folder;
      color = NeonTheme.neonBlue;
    } else {
      switch (file.type) {
        case FileType.image:
          icon = LucideIcons.image;
          color = NeonTheme.accentGreen;
          break;
        case FileType.video:
          icon = LucideIcons.video;
          color = Colors.orange;
          break;
        case FileType.audio:
          icon = LucideIcons.music;
          color = NeonTheme.neonViolet;
          break;
        case FileType.archive:
          icon = LucideIcons.archive;
          color = Colors.yellow;
          break;
        case FileType.pdf:
          icon = LucideIcons.fileText;
          color = NeonTheme.accentRed;
          break;
        case FileType.apk:
          icon = LucideIcons.package;
          color = Colors.green;
          break;
        default:
          icon = LucideIcons.file;
          color = Colors.white70;
      }
    }

    return Icon(icon, color: color, size: 20);
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (math.log(bytes) / math.log(1024)).floor();
    return '${(bytes / math.pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }
}

class _SearchIndicator extends ConsumerWidget {
  final String paneId;
  final String query;
  const _SearchIndicator({required this.paneId, required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: NeonTheme.neonBlue.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(LucideIcons.search, size: 12, color: NeonTheme.neonBlue),
          const SizedBox(width: 8),
          Expanded(child: Text('Searching for "$query"', style: const TextStyle(fontSize: 11, color: NeonTheme.neonBlue))),
          IconButton(
            icon: const Icon(LucideIcons.x, size: 12, color: NeonTheme.neonBlue),
            onPressed: () => ref.read(fileSystemProvider(paneId).notifier).setSearchQuery(null),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
