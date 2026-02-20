import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/file_system_provider.dart';
import '../../../core/theme.dart';
import '../../../domain/entities/file_entity.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final FileEntity file;
  final String paneId;

  const DeleteConfirmationDialog({super.key, required this.file, required this.paneId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text('Delete', style: TextStyle(color: NeonTheme.accentRed)),
      content: Text(
        'Are you sure you want to delete "${file.name}"? This action cannot be undone.',
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        Consumer(
          builder: (context, ref, child) {
            return TextButton(
              onPressed: () async {
                await ref.read(fileSystemProvider(paneId).notifier).delete(file.path);
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: NeonTheme.accentRed)),
            );
          },
        ),
      ],
    );
  }
}
