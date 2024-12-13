import "dart:convert";

import "package:frontend/core/constants/constants.dart";
import "package:frontend/features/home/repository/task_local_repository.dart";
import "package:http/http.dart" as http;
import "package:uuid/uuid.dart";

import "../../../core/constants/utils.dart";
import "../../../models/task_model.dart";

class TaskRemoteRepository {
  final taskLocalRepository = TaskLocalRepository();

  Future<TaskModel> createTask(
      {required String title,
      required String description,
      required String color,
      required String token,
      required String uid,
      required DateTime due_at}) async {
    try {
      final res = await http.post(Uri.parse("${Constants.backendUri}/task"),
          headers: {'Content-Type': 'application/json', "Authorization": token},
          body: jsonEncode({
            "title": title,
            "description": description,
            "color": color,
            "due_at": due_at.toIso8601String()
          }));

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)["error"];
      }
      return TaskModel.fromJson(res.body);
    } catch (e) {
      try {
        final taskModel = TaskModel(
          id: const Uuid().v6(),
          uid: uid,
          title: title,
          description: description,
          created_at: DateTime.now(),
          updated_at: DateTime.now(),
          due_at: due_at,
          color: hexToRgb(color),
          isSynced: 0,
        );
        await taskLocalRepository.insertTask(taskModel);
        return taskModel;
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<List<TaskModel>> getTasks({required String token}) async {
    try {
      final res = await http.get(
        Uri.parse("${Constants.backendUri}/task"),
        headers: {'Content-Type': 'application/json', "Authorization": token},
      );

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)["error"];
      }

      final listOfTask = jsonDecode(res.body);
      List<TaskModel> taskList = [];
      for (var elem in listOfTask) {
        taskList.add(TaskModel.fromMap(elem));
      }

      await taskLocalRepository.insertTasks(taskList);

      return taskList;
    } catch (e) {
      final tasks = await taskLocalRepository.getTasks();
      if (tasks.isNotEmpty) return tasks;
      rethrow;
    }
  }

  Future<bool> syncTasks({
    required String token,
    required List<TaskModel> tasks,
  }) async {
    try {
      final taskListInMap = [];
      for (final task in tasks) {
        taskListInMap.add(task.toMap());
      }
      final res = await http.post(
        Uri.parse("${Constants.backendUri}/task/sync"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode(taskListInMap),
      );

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['error'];
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
