import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../providers/file_system_provider.dart';
import '../../../core/theme.dart';

class CreateFolderDialog extends StatefulWidget {
  final String paneId;
  const CreateFolderDialog({super.key, required this.paneId});

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text('New Folder', style: TextStyle(color: NeonTheme.neonBlue)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Folder name',
          hintStyle: TextStyle(color: Colors.white24),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: NeonTheme.neonBlue)),
        ),
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
                final name = _controller.text.trim();
                if (name.isNotEmpty) {
                  final state = ref.read(fileSystemProvider(widget.paneId));
                  final path = p.join(state.currentPath, name);
                  await ref.read(fileSystemProvider(widget.paneId).notifier).createDirectory(path);
                }
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Create', style: TextStyle(color: NeonTheme.neonBlue)),
            );
          },
        ),
      ],
    );
  }
}
