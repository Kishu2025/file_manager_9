import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/file_system_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/breadcrumb_navigation.dart';
import '../widgets/file_list_view.dart';
import '../widgets/category_tabs.dart';
import '../widgets/dialogs/create_folder_dialog.dart';
import '../../core/theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      drawer: isDesktop ? null : const Drawer(child: Sidebar()),
      appBar: AppBar(
        title: const Text('KFILE EXPLORER'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.moreVertical),
            onPressed: () {},
          ),
        ],
      ),
      body: Row(
        children: [
          if (isDesktop)
            const SizedBox(
              width: 240,
              child: Sidebar(),
            ),
          if (isDesktop)
            const VerticalDivider(width: 1, color: Colors.white12),
          Expanded(
            child: isDesktop 
              ? Row(
                  children: [
                    const Expanded(
                      child: FilePane(paneId: 'left'),
                    ),
                    const VerticalDivider(width: 1, color: Colors.white10),
                    const Expanded(
                      child: FilePane(paneId: 'right'),
                    ),
                  ],
                )
              : const FilePane(paneId: 'left'),
          ),
        ],
      ),
    );
  }
}

class FilePane extends ConsumerStatefulWidget {
  final String paneId;
  const FilePane({super.key, required this.paneId});

  @override
  ConsumerState<FilePane> createState() => _FilePaneState();
}

class _FilePaneState extends ConsumerState<FilePane> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fileSystemProvider(widget.paneId));

    return Stack(
      children: [
        Column(
          children: [
            _PaneHeader(
              paneId: widget.paneId,
              isSearching: _isSearching,
              searchController: _searchController,
              onToggleSearch: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    ref.read(fileSystemProvider(widget.paneId).notifier).setSearchQuery(null);
                  }
                });
              },
            ),
            CategoryTabs(paneId: widget.paneId),
            BreadcrumbNavigation(paneId: widget.paneId),
            Expanded(
              child: state.isLoading 
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                  ? Center(child: Text('Error: ${state.error}'))
                  : FileListView(paneId: widget.paneId),
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.small(
            backgroundColor: NeonTheme.neonBlue,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => CreateFolderDialog(paneId: widget.paneId),
              );
            },
            child: const Icon(Icons.add, color: Colors.black),
          ),
        ),
      ],
    );
  }
}

class _PaneHeader extends ConsumerWidget {
  final String paneId;
  final bool isSearching;
  final TextEditingController searchController;
  final VoidCallback onToggleSearch;

  const _PaneHeader({
    required this.paneId,
    required this.isSearching,
    required this.searchController,
    required this.onToggleSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          if (isSearching)
            Expanded(
              child: TextField(
                controller: searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white24),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
                onChanged: (value) {
                  ref.read(fileSystemProvider(paneId).notifier).setSearchQuery(value);
                },
              ),
            )
          else
            const Expanded(
              child: Text(
                'EXPLORER',
                style: TextStyle(
                  color: NeonTheme.neonBlue,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 11,
                ),
              ),
            ),
          IconButton(
            icon: Icon(isSearching ? LucideIcons.x : LucideIcons.search, size: 16),
            onPressed: onToggleSearch,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 16),
            onPressed: () => ref.read(fileSystemProvider(paneId).notifier).refresh(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
