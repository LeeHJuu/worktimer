import 'package:flutter/material.dart';
import '../../../../../domain/services/installed_apps_service.dart';

class AppPickerDialog extends StatefulWidget {
  const AppPickerDialog({super.key});

  @override
  State<AppPickerDialog> createState() => _AppPickerDialogState();
}

class _AppPickerDialogState extends State<AppPickerDialog> {
  final _searchCtrl = TextEditingController();
  List<InstalledApp> _allApps = const [];
  List<InstalledApp> _filtered = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_applyFilter);
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final apps = await InstalledAppsService().fetchInstalledApps();
      if (!mounted) return;
      setState(() {
        _allApps = apps;
        _filtered = apps;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    final query = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? _allApps
          : _allApps
              .where((a) =>
                  a.name.toLowerCase().contains(query) ||
                  a.path.toLowerCase().contains(query))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('앱 선택'),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      content: SizedBox(
        width: 480,
        height: 480,
        child: Column(
          children: [
            if (!_loading)
              TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '앱 이름 또는 경로 검색',
                  prefixIcon: Icon(Icons.search, size: 18),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: _buildBody(context),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('설치된 앱 불러오는 중...', style: TextStyle(fontSize: 13)),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(
          '앱 목록을 불러오지 못했습니다.\n$_error',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }
    if (_filtered.isEmpty) {
      return const Center(
        child: Text('검색 결과 없음', style: TextStyle(fontSize: 13)),
      );
    }
    return ListView.builder(
      itemCount: _filtered.length,
      itemBuilder: (_, i) {
        final app = _filtered[i];
        return ListTile(
          dense: true,
          leading: const Icon(Icons.apps_outlined, size: 18),
          title: Text(app.name, style: const TextStyle(fontSize: 13)),
          subtitle: Text(
            app.path,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.55),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => Navigator.pop(context, app),
        );
      },
    );
  }
}
