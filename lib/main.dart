import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox<String>('todoBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter To-Do App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false, // Remove the debug banner
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final Box<String> todoBox = Hive.box<String>('todoBox');
  final TextEditingController _textController = TextEditingController();

  void _addOrUpdateTodoItem(String task, [int? index]) {
    setState(() {
      if (index == null) {
        todoBox.add(task);
      } else {
        todoBox.putAt(index, task);
      }
    });
  }

  void _pushAddOrUpdateTodoScreen([String? task, int? index]) {
    if (task != null) {
      _textController.text = task;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Make background transparent
      builder: (context) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material(
              borderRadius: BorderRadius.circular(10.0), // Rounded corners
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        index == null ? 'Add a new task' : 'Update task',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _textController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Enter something to do...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_textController.text.isNotEmpty) {
                            _addOrUpdateTodoItem(_textController.text, index);
                            Navigator.pop(context);
                          }
                        },
                        child: Text(index == null ? 'Add' : 'Update'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      _textController.clear();
    });
  }

  Widget _buildTodoList() {
    return ValueListenableBuilder(
      valueListenable: todoBox.listenable(),
      builder: (context, Box<String> box, _) {
        if (box.values.isEmpty) {
          return Center(
            child: Text('No tasks yet', style: TextStyle(fontSize: 18)),
          );
        }
        return ListView.builder(
          itemCount: box.length,
          itemBuilder: (context, index) {
            return _buildTodoItem(box.getAt(index), index);
          },
        );
      },
    );
  }

  Widget _buildTodoItem(String? task, int index) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(task!, style: TextStyle(fontSize: 18)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                _pushAddOrUpdateTodoScreen(task, index);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  todoBox.deleteAt(index);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List App'),
      ),
      body: _buildTodoList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pushAddOrUpdateTodoScreen(),
        tooltip: 'Add task',
        child: Icon(Icons.add),
      ),
    );
  }
}
