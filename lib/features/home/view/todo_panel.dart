import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/core/database/app_database.dart';
import 'package:worktimer/core/utils/color_utils.dart';
import 'package:worktimer/features/manage/data/category_provider.dart';
import 'package:worktimer/features/timer/data/timer_provider.dart';
import 'package:worktimer/features/timer/data/timer_service.dart';
import 'package:worktimer/features/todo/data/todo_provider.dart';

class TodoPanel extends ConsumerStatefulWidget {
  const TodoPanel({super.key, required this.isWeekly});
  final bool isWeekly;

  @override
  ConsumerState<TodoPanel> createState() => _TodoPanelState();
}

class _TodoPanelState extends ConsumerState<TodoPanel> {
  final _inputController = TextEditingController();
  final _focusNode = FocusNode();
  Category? _selectedCategory;
  bool _showInput = false;

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openInput() {
    setState(() => _showInput = true);
    Future.microtask(() => _focusNode.requestFocus());
  }

  void _submit() {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      setState(() => _showInput = false);
      return;
    }
    final estimated = _parseEstimatedMinutes(text);
    final cleanTitle = _stripEstimate(text);
    ref.read(todoRepositoryProvider).insert(
          title: cleanTitle,
          categoryId: _selectedCategory?.id,
          estimatedMinutes: estimated,
        );
    _inputController.clear();
    setState(() {
      _selectedCategory = null;
      _showInput = false;
    });
  }

  void _cancel() {
    _inputController.clear();
    setState(() {
      _selectedCategory = null;
      _showInput = false;
    });
  }

  /// "~1h", "30m", "2h30m" 등을 분으로 파싱
  int? _parseEstimatedMinutes(String text) {
    final pattern = RegExp(r'~?(\d+)h\s*(\d+)?m?|~?(\d+)m(?![\d])',
        caseSensitive: false);
    final match = pattern.firstMatch(text);
    if (match == null) return null;
    if (match.group(1) != null) {
      final h = int.tryParse(match.group(1) ?? '') ?? 0;
      final m = int.tryParse(match.group(2) ?? '') ?? 0;
      return h * 60 + m;
    }
    if (match.group(3) != null) {
      return int.tryParse(match.group(3) ?? '');
    }
    return null;
  }

  String _stripEstimate(String text) {
    return text
        .replaceAll(
            RegExp(r'\s*~?\d+h\s*\d*m?\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*~?\d+m\s*', caseSensitive: false), '')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final todosAsync = ref.watch(todosProvider);
    final timerState = ref.watch(timerServiceProvider);
    final categoriesAsync = ref.watch(visibleCategoriesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final label = widget.isWeekly ? '이번 주 할 일' : '오늘의 할 일';

    return todosAsync.when(
      data: (todos) {
        final pending = todos.where((t) => !t.isCompleted).toList();
        final done = todos.where((t) => t.isCompleted).toList();
        final running = pending
            .where((t) =>
                t.categoryId != null &&
                timerState.activeCategoryId == t.categoryId &&
                timerState.isRunning)
            .length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 헤더 ──
            Row(
              children: [
                Icon(Icons.check_box_outlined,
                    size: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.4)),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${done.length} / ${todos.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _openInput,
                  child: Text(
                    '+ 추가',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── 입력 폼 ──
            if (_showInput)
              categoriesAsync.when(
                data: (categories) => _InputRow(
                  controller: _inputController,
                  focusNode: _focusNode,
                  categories: categories,
                  selectedCategory: _selectedCategory,
                  onCategoryChanged: (cat) =>
                      setState(() => _selectedCategory = cat),
                  onSubmit: _submit,
                  onCancel: _cancel,
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              )
            else
              _PlaceholderInput(onTap: _openInput),

            const SizedBox(height: 8),

            // ── 미완료 목록 ──
            ...pending.map((todo) => _TodoRow(
                  todo: todo,
                  timerState: timerState,
                  catMap: categoriesAsync.valueOrNull != null
                      ? {for (final c in categoriesAsync.value!) c.id: c}
                      : {},
                )),

            // ── 완료 목록 (접힘) ──
            if (done.isNotEmpty) ...[
              const SizedBox(height: 4),
              Divider(
                  height: 1,
                  color: colorScheme.outline.withValues(alpha: 0.1)),
              const SizedBox(height: 4),
              ...done.map((todo) => _TodoRow(
                    todo: todo,
                    timerState: timerState,
                    catMap: categoriesAsync.valueOrNull != null
                        ? {for (final c in categoriesAsync.value!) c.id: c}
                        : {},
                  )),
            ],

            // ── 푸터 ──
            const SizedBox(height: 10),
            Divider(
                height: 1,
                color: colorScheme.outline.withValues(alpha: 0.12)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '완료 ${done.length} · 진행 $running · 남음 ${pending.length - running}',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) =>
          Center(child: Text('$e', style: const TextStyle(color: Colors.red))),
    );
  }
}

// ── 입력 행 ───────────────────────────────────────────────────

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.controller,
    required this.focusNode,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onSubmit,
    required this.onCancel,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final List<Category> categories;
  final Category? selectedCategory;
  final ValueChanged<Category?> onCategoryChanged;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.escape) {
                onCancel();
              }
            },
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: '할 일 입력… (~1h, 30m 형식으로 예상 시간 포함 가능)',
                hintStyle: TextStyle(
                    fontSize: 12.5,
                    color: colorScheme.onSurface.withValues(alpha: 0.3)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 13),
              onSubmitted: (_) => onSubmit(),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              // 카테고리 선택
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _CatChip(
                        label: '없음',
                        color: colorScheme.onSurface.withValues(alpha: 0.2),
                        selected: selectedCategory == null,
                        onTap: () => onCategoryChanged(null),
                      ),
                      ...categories.map((cat) => Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: _CatChip(
                              label: cat.name,
                              color: parseHexColor(cat.color),
                              selected: selectedCategory?.id == cat.id,
                              onTap: () => onCategoryChanged(cat),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 취소/추가 버튼
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    minimumSize: Size.zero),
                child: const Text('취소', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    textStyle: const TextStyle(fontSize: 12)),
                child: const Text('추가'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  const _CatChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 6, height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: selected ? color : color.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderInput extends StatelessWidget {
  const _PlaceholderInput({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.25),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.add,
                size: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(width: 8),
            Text(
              '할 일을 입력하고 카테고리를 지정…',
              style: TextStyle(
                fontSize: 12.5,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text('Enter',
                  style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color:
                          colorScheme.onSurface.withValues(alpha: 0.3))),
            ),
          ],
        ),
      ),
    );
  }
}

// ── TODO 행 ───────────────────────────────────────────────────

class _TodoRow extends ConsumerWidget {
  const _TodoRow({
    required this.todo,
    required this.timerState,
    required this.catMap,
  });

  final Todo todo;
  final TimerState timerState;
  final Map<int, Category> catMap;

  bool get _isRunning =>
      !todo.isCompleted &&
      todo.categoryId != null &&
      timerState.activeCategoryId == todo.categoryId &&
      timerState.isRunning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final cat = todo.categoryId != null ? catMap[todo.categoryId!] : null;
    final catColor = cat != null ? parseHexColor(cat.color) : null;
    final repo = ref.read(todoRepositoryProvider);
    final timerNotifier = ref.read(timerServiceProvider.notifier);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: _isRunning
              ? colorScheme.primary.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            // 체크박스
            GestureDetector(
              onTap: () {
                if (todo.isCompleted) {
                  repo.uncomplete(todo.id);
                } else {
                  repo.complete(todo.id);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: todo.isCompleted
                      ? colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: todo.isCompleted
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: todo.isCompleted
                    ? const Icon(Icons.check, size: 10, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 10),

            // 카테고리 색상 점
            if (catColor != null) ...[
              Container(
                width: 7,
                height: 7,
                decoration:
                    BoxDecoration(color: catColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ],

            // 제목
            Expanded(
              child: Text(
                todo.title,
                style: TextStyle(
                  fontSize: 12.5,
                  color: todo.isCompleted
                      ? colorScheme.onSurface.withValues(alpha: 0.35)
                      : colorScheme.onSurface.withValues(alpha: 0.88),
                  decoration: todo.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 예상 시간
            if (todo.estimatedMinutes != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  _fmtEst(todo.estimatedMinutes!),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontFamily: 'monospace',
                    color: colorScheme.onSurface.withValues(alpha: 0.35),
                  ),
                ),
              ),

            // 재생/일시정지 버튼 (카테고리 있고, 미완료인 경우만)
            if (!todo.isCompleted && todo.categoryId != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (_isRunning) {
                    timerNotifier.pause();
                  } else {
                    timerNotifier.start(todo.categoryId!);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _isRunning
                        ? colorScheme.primary
                        : colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 11,
                    color: _isRunning
                        ? Colors.white
                        : colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _fmtEst(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0 && m > 0) return '~${h}h${m}m';
    if (h > 0) return '~${h}h';
    return '~${m}m';
  }
}
