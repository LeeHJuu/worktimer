import 'package:flutter/material.dart';
import '../../../../data/database/app_database.dart';

class ShortcutListTile extends StatelessWidget {
  const ShortcutListTile({
    super.key,
    required this.shortcut,
    required this.onEdit,
    required this.onDelete,
    required this.onLaunch,
  });

  final Shortcut shortcut;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onLaunch;

  @override
  Widget build(BuildContext context) {
    final isWeb = shortcut.type == 'web';
    final colorScheme = Theme.of(context).colorScheme;
    final onSurface = colorScheme.onSurface;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: (isWeb ? Colors.blue : Colors.orange)
              .withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          isWeb ? Icons.language_outlined : Icons.apps_outlined,
          size: 16,
          color: isWeb ? Colors.blue : Colors.orange,
        ),
      ),
      title: Text(
        shortcut.name,
        style: TextStyle(fontSize: 13, color: onSurface),
      ),
      subtitle: Text(
        shortcut.target,
        style: TextStyle(
            fontSize: 11, color: onSurface.withValues(alpha: 0.5)),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isWeb
                  ? Icons.open_in_browser_outlined
                  : Icons.play_circle_outline,
              size: 18,
              color: onSurface.withValues(alpha: 0.55),
            ),
            tooltip: isWeb ? '브라우저 열기' : '프로그램 실행',
            onPressed: onLaunch,
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined,
                size: 18, color: onSurface.withValues(alpha: 0.55)),
            tooltip: '편집',
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline,
                size: 18, color: Colors.red.shade300),
            tooltip: '삭제',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
