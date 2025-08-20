import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';
import '../widgets/weather_widget.dart';
import 'add_edit_task_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToAddTask() async {
    final result = await _navigateToTaskScreen(null);
    
    if (result != null && mounted) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      await taskProvider.addTask(
        result['title'],
        result['description'],
        result['deadline'],
      );
    }
  }

  void _navigateToEditTask(Task task) async {
    final result = await _navigateToTaskScreen(task);
    
    if (result != null && mounted) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final updatedTask = Task(
        id: task.id,
        title: result['title'],
        description: result['description'],
        deadline: result['deadline'],
        isCompleted: task.isCompleted,
      );
      await taskProvider.updateTask(updatedTask);
    }
  }

  Future<Map<String, dynamic>?> _navigateToTaskScreen(Task? task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTaskScreen(task: task),
      ),
    );
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista Zadań',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatisticsScreen()),
              );
            },
            icon: const Icon(Icons.analytics),
            tooltip: 'Statystyki',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.list),
              text: 'Do zrobienia',
            ),
            Tab(
              icon: Icon(Icons.done_all),
              text: 'Wykonane',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Widget pogodowy (tylko na pierwszej zakładce)
          const WeatherWidget(),
          
          // Zakładki z zadaniami
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Zakładka "Do zrobienia"
                _buildTasksList(false),
                // Zakładka "Wykonane"
                _buildTasksList(true),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTask(),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTasksList(bool showCompleted) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = showCompleted ? taskProvider.completedTasks : taskProvider.tasks;
        
        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  showCompleted ? Icons.check_circle_outline : Icons.task_alt,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  showCompleted 
                      ? 'Brak wykonanych zadań'
                      : 'Brak zadań do wykonania',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  showCompleted 
                      ? 'Wykonane zadania pojawią się tutaj'
                      : 'Dodaj pierwsze zadanie używając przycisku +',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await taskProvider.loadTasks();
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              
              return TaskTile(
                task: task,
                onTap: () => _navigateToEditTask(task),
                onToggleComplete: () async {
                  await taskProvider.toggleTaskCompletion(task);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          task.isCompleted 
                              ? 'Zadanie oznaczone jako niewykonane'
                              : 'Zadanie wykonane! 🎉',
                        ),
                        backgroundColor: task.isCompleted ? Colors.orange : Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                onDelete: () async {
                  await taskProvider.deleteTask(task);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Zadanie zostało usunięte'),
                        backgroundColor: Colors.red,
                        action: SnackBarAction(
                          label: 'Cofnij',
                          textColor: Colors.white,
                          onPressed: () {
                            // W przyszłości można dodać funkcję cofnięcia usunięcia
                          },
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
