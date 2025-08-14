import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter & To-Do',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [CounterPage(), TodoPage()];

  void _onTap(int idx) => setState(() => _selectedIndex = idx);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.exposure_plus_1), label: 'Counter'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'To-Do'),
        ],
      ),
    );
  }
}

/* ------------------ Counter Page ------------------ */
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});
  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  static const String _counterKey = 'counter_value';
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt(_counterKey) ?? 0;
    });
  }

  Future<void> _saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_counterKey, _counter);
  }

  void _increment() {
    setState(() => _counter++);
    _saveCounter();
  }

  void _decrement() {
    setState(() => _counter--);
    _saveCounter();
  }

  void _reset() {
    setState(() => _counter = 0);
    _saveCounter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Current value', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('$_counter',
                  style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.indigo)),
              const SizedBox(height: 20),
              Row(mainAxisSize: MainAxisSize.min, children: [
                ElevatedButton.icon(
                    onPressed: _decrement, icon: const Icon(Icons.remove), label: const Text('Decrease')),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                    onPressed: _increment, icon: const Icon(Icons.add), label: const Text('Increase')),
              ]),
              const SizedBox(height: 12),
              TextButton(onPressed: _reset, child: const Text('Reset to 0')),
            ]),
          ),
        ),
      ),
    );
  }
}

/* ------------------ To-Do Page ------------------ */
class TodoPage extends StatefulWidget {
  const TodoPage({super.key});
  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  static const String _tasksKey = 'todo_tasks';
  final TextEditingController _controller = TextEditingController();
  List<String> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_tasksKey) ?? [];
    setState(() => _tasks = saved);
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_tasksKey, _tasks);
  }

  void _addTask() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _tasks.add(text);
      _controller.clear();
    });
    _saveTasks();
  }

  void _removeTask(int index) {
    final removed = _tasks[index];
    setState(() => _tasks.removeAt(index));
    _saveTasks();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Removed: $removed')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _addTask(),
                decoration: const InputDecoration(
                    hintText: 'Add a task',
                    prefixIcon: Icon(Icons.edit_note)),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _addTask, child: const Text('Add')),
          ]),
          const SizedBox(height: 16),
          Expanded(
            child: _tasks.isEmpty
                ? const Center(
                    child: Text('No tasks yet — add one above.',
                        style: TextStyle(fontSize: 16, color: Colors.grey)))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return Dismissible(
                        key: Key(task + index.toString()),
                        background: Container(
                          decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(8)),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (_) => _removeTask(index),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(task),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              onPressed: () => _removeTask(index),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}
