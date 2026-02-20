import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../widgets/neon_glow_container.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'STORAGE',
              style: TextStyle(
                color: NeonTheme.neonBlue,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          _SidebarItem(
            icon: LucideIcons.home,
            label: 'Home',
            onTap: () {},
          ),
          _SidebarItem(
            icon: LucideIcons.star,
            label: 'Favorites',
            onTap: () {},
          ),
          _SidebarItem(
            icon: LucideIcons.clock,
            label: 'Recent',
            onTap: () {},
          ),
          _SidebarItem(
            icon: LucideIcons.trash2,
            label: 'Trash',
            onTap: () {},
          ),
          const Divider(color: Colors.white12, indent: 20, endIndent: 20),
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'TOOLS',
              style: TextStyle(
                color: NeonTheme.neonViolet,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          _SidebarItem(
            icon: LucideIcons.pieChart,
            label: 'Analyzer',
            onTap: () {},
          ),
          _SidebarItem(
            icon: LucideIcons.files,
            label: 'Duplicates',
            onTap: () {},
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: NeonGlowContainer(
              color: NeonTheme.neonViolet,
              padding: const EdgeInsets.all(12),
              child: const Row(
                children: [
                  Icon(LucideIcons.hardDrive, color: NeonTheme.neonViolet),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Local Storage', style: TextStyle(fontSize: 12)),
                        SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: 0.7,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation(NeonTheme.neonViolet),
                        ),
                        SizedBox(height: 4),
                        Text('70% Used - 12GB Free', style: TextStyle(fontSize: 10, color: Colors.white54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 20),
      title: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      onTap: onTap,
      hoverColor: NeonTheme.neonBlue.withOpacity(0.1),
    );
  }
}
