import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../providers/file_system_provider.dart';
import '../../../core/theme.dart';
import '../../../domain/entities/file_entity.dart';

class RenameDialog extends StatefulWidget {
  final FileEntity file;
  final String paneId;

  const RenameDialog({super.key, required this.file, required this.paneId});

  @override
  State<RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<RenameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.file.name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text('Rename', style: TextStyle(color: NeonTheme.neonBlue)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'New name',
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
                final newName = _controller.text.trim();
                if (newName.isNotEmpty && newName != widget.file.name) {
                  final newPath = p.join(p.dirname(widget.file.path), newName);
                  await ref.read(fileSystemProvider(widget.paneId).notifier).rename(widget.file.path, newPath);
                }
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Rename', style: TextStyle(color: NeonTheme.neonBlue)),
            );
          },
        ),
      ],
    );
  }
}
