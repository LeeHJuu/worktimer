import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/core/database/app_database.dart';
import 'package:worktimer/core/database/database_provider.dart';
import 'package:worktimer/features/todo/data/todo_repository.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository(ref.watch(appDatabaseProvider));
});

final todosProvider = StreamProvider<List<Todo>>((ref) {
  return ref.watch(todoRepositoryProvider).watchAll();
});
