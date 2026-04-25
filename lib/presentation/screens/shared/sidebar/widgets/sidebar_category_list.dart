import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../data/database/app_database.dart';
import '../../../../providers/category_provider.dart';
import '../../../../providers/timer_provider.dart';
import 'sidebar_category_item.dart';

class SidebarCategoryList extends ConsumerStatefulWidget {
  const SidebarCategoryList({
    super.key,
    required this.categories,
    required this.activeCategoryId,
    required this.timerStatus,
  });

  final List<Category> categories;
  final int? activeCategoryId;
  final TimerStatus timerStatus;

  @override
  ConsumerState<SidebarCategoryList> createState() =>
      SidebarCategoryListState();
}

class SidebarCategoryListState extends ConsumerState<SidebarCategoryList> {
  bool _isDragging = false;
  List<Category>? _localOrder;

  List<Category> get _display => _localOrder ?? widget.categories;

  @override
  void didUpdateWidget(SidebarCategoryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_localOrder != null &&
        _sameOrder(widget.categories, _localOrder!)) {
      _localOrder = null;
    }
  }

  bool _sameOrder(List<Category> a, List<Category> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cats = _display;

    if (cats.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '카테고리를 추가하세요',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      buildDefaultDragHandles: false,
      proxyDecorator: (child, _, animation) => Material(
        color: Colors.transparent,
        elevation: 4,
        shadowColor: Colors.black26,
        child: child,
      ),
      itemCount: cats.length,
      itemBuilder: (context, index) {
        final cat = cats[index];
        final isActive = cat.id == widget.activeCategoryId;
        return RepaintBoundary(
          key: ValueKey(cat.id),
          child: SidebarCategoryItem(
            category: cat,
            isActive: isActive,
            timerStatus: widget.timerStatus,
            index: index,
            isDragging: _isDragging,
          ),
        );
      },
      onReorderStart: (_) => setState(() => _isDragging = true),
      onReorder: (oldIndex, newIndex) async {
        if (newIndex > oldIndex) newIndex--;
        final reordered = [...cats];
        final item = reordered.removeAt(oldIndex);
        reordered.insert(newIndex, item);

        setState(() {
          _isDragging = false;
          _localOrder = reordered;
        });

        final orders = reordered
            .asMap()
            .entries
            .map((e) => (id: e.value.id, sortOrder: e.key))
            .toList();
        await ref.read(categoryRepositoryProvider).updateSortOrders(orders);
      },
    );
  }
}
