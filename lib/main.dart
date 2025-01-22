import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), // লাইট মোড
      darkTheme: ThemeData.dark(), // ডার্ক মোড
      themeMode: ThemeMode.system, // সিস্টেম মোড অনুসারে থিম পরিবর্তন
      home: TodoHomePage(),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  @override
  _TodoHomePageState createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final List<String> _tasks = [];
  final List<bool> _taskCompletion = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // টাস্ক লোড করার ফাংশন (SharedPreferences থেকে)
  void _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tasks.addAll(prefs.getStringList('tasks') ?? []);
      _taskCompletion.addAll(prefs.getStringList('completion')?.map((e) => e == 'true') ?? []);
    });
  }

  // টাস্ক সেভ করার ফাংশন (SharedPreferences-এ সংরক্ষণ)
  void _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('tasks', _tasks);
    prefs.setStringList('completion', _taskCompletion.map((e) => e.toString()).toList());
  }

  void _addTask() {
    setState(() {
      if (_taskController.text.isNotEmpty) {
        _tasks.add(_taskController.text + " - ${DateTime.now().toLocal()}");
        _taskCompletion.add(false);
        _taskController.clear();
        _saveTasks();
      }
    });
  }

  void _deleteTask(int index) {
    final removedTask = _tasks[index];
    final removedStatus = _taskCompletion[index];

    setState(() {
      _tasks.removeAt(index);
      _taskCompletion.removeAt(index);
      _saveTasks();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Task deleted"),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            setState(() {
              _tasks.insert(index, removedTask);
              _taskCompletion.insert(index, removedStatus);
              _saveTasks();
            });
          },
        ),
      ),
    );
  }

  void _toggleComplete(int index) {
    setState(() {
      _taskCompletion[index] = !_taskCompletion[index];
      _saveTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Updated To-Do List'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              setState(() {
                _tasks.clear();
                _taskCompletion.clear();
                _saveTasks();
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      hintText: 'Enter a task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.blue),
                  onPressed: _addTask,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(
                      _tasks[index],
                      style: TextStyle(
                        decoration: _taskCompletion[index]
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: _taskCompletion[index] ? Colors.green : Colors.black,
                      ),
                    ),
                    onTap: () => _toggleComplete(index),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTask(index),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
