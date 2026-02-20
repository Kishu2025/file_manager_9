import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:math' as math;
import '../../../domain/entities/file_entity.dart';
import '../../../core/theme.dart';

class FilePropertiesDialog extends StatelessWidget {
  final FileEntity file;

  const FilePropertiesDialog({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text('Properties', style: TextStyle(color: NeonTheme.neonBlue)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _PropertyItem(label: 'Name', value: file.name),
            _PropertyItem(label: 'Type', value: file.isDirectory ? 'Folder' : (file.extension?.toUpperCase() ?? 'File')),
            _PropertyItem(label: 'Location', value: file.path),
            _PropertyItem(label: 'Size', value: _formatSize(file.size)),
            _PropertyItem(label: 'Modified', value: DateFormat('yyyy-MM-dd HH:mm:ss').format(file.modified)),
            if (!file.isDirectory && !kIsWeb) ...[
               FutureBuilder<FileStat>(
                future: File(file.path).stat(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return _PropertyItem(label: 'Permissions', value: snapshot.data!.modeString());
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: NeonTheme.neonBlue)),
        ),
      ],
    );
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (math.log(bytes) / math.log(1024)).floor();
    return '${(bytes / math.pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }
}

class _PropertyItem extends StatelessWidget {
  final String label;
  final String value;

  const _PropertyItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          SelectableText(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}
