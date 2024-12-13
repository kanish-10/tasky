import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:frontend/features/home/repository/task_local_repository.dart';
import 'package:frontend/features/home/repository/task_remote_repository.dart';
import 'package:frontend/models/task_model.dart';

part 'add_new_task_state.dart';

class AddNewTaskCubit extends Cubit<AddNewTaskState> {
  AddNewTaskCubit() : super(AddNewTaskInitial());
  final taskRemoteRepository = TaskRemoteRepository();
  final taskLocalRepository = TaskLocalRepository();

  Future<void> createNewTask(
      {required String title,
      required String description,
      required Color color,
      required String token,
      required String uid,
      required DateTime due_at}) async {
    try {
      emit(AddNewTaskLoading());
      final taskModel = await taskRemoteRepository.createTask(
          uid: uid,
          title: title,
          description: description,
          color: rgbToHex(color),
          token: token,
          due_at: due_at);
      emit(AddNewTaskSuccess(taskModel));
    } catch (e) {
      emit(AddNewTaskError(e.toString()));
    }
  }

  Future<void> getTasks({
    required String token,
  }) async {
    try {
      emit(AddNewTaskLoading());
      final tasks = await taskRemoteRepository.getTasks(token: token);
      emit(GetTasksSuccess(tasks));
    } catch (e) {
      emit(AddNewTaskError(e.toString()));
    }
  }

  Future<void> syncTasks(String token) async {
    final unSyncedTasks = await taskLocalRepository.getUnsyncedTasks();
    final isSynced = await taskRemoteRepository.syncTasks(
        token: token, tasks: unSyncedTasks);
    if (isSynced) {
      for (final task in unSyncedTasks) {
        taskLocalRepository.updateRowValue(task.id, 1);
      }
    }
  }
}
