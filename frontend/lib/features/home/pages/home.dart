import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/home/cubit/add_new_task_cubit.dart';
import 'package:frontend/features/home/pages/add_new_task.dart';
import 'package:frontend/features/home/widgets/date_selector.dart';
import 'package:frontend/features/home/widgets/task_card.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const Home());

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final user = context.read<AuthCubit>().state as AuthLoggedIn;
    context.read<AddNewTaskCubit>().getTasks(token: user.user.token);
    Connectivity().onConnectivityChanged.listen((data) async {
      if (data.contains(ConnectivityResult.wifi)) {
        await context.read<AddNewTaskCubit>().syncTasks(user.user.token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("My Tasks"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, AddNewTask.route());
            },
            icon: const Icon(CupertinoIcons.add),
          )
        ],
      ),
      body: BlocBuilder<AddNewTaskCubit, AddNewTaskState>(
        builder: (context, state) {
          if (state is AddNewTaskLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is AddNewTaskError) {
            return Center(
              child: Text(state.error),
            );
          }
          if (state is GetTasksSuccess) {
            final tasks = state.tasks
                .where((elem) =>
                    DateFormat('d').format(elem.due_at) ==
                        DateFormat('d').format(selectedDate) &&
                    selectedDate.month == elem.due_at.month &&
                    selectedDate.year == elem.due_at.year)
                .toList();

            return Column(
              children: [
                DateSelector(
                  selectedDate: selectedDate,
                  onTap: (date) {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Row(
                        children: [
                          Expanded(
                            child: TaskCard(
                              color: task.color,
                              header: task.title,
                              description: task.description,
                            ),
                          ),
                          Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: strengthenColor(
                                  const Color.fromRGBO(246, 222, 194, 1), 0.69),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              DateFormat.jm().format(task.due_at),
                              style: const TextStyle(fontSize: 17),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                )
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
