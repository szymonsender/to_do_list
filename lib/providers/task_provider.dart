import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';

class TaskProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Task> _tasks = [];
  List<Task> _completedTasks = [];

  List<Task> get tasks => _tasks;
  List<Task> get completedTasks => _completedTasks;

  int get completedTasksCount => _completedTasks.length;

  String get mostProductiveDay => _calculateMostProductiveDay();

  Future<void> loadTasks() async {
    _tasks = await _databaseHelper.getTasksByStatus(false);
    _completedTasks = await _databaseHelper.getTasksByStatus(true);
    
    // Sortowanie według deadline'u
    _tasks.sort((a, b) => a.deadline.compareTo(b.deadline));
    
    notifyListeners();
  }

  // Dodawanie nowego zadania
  Future<void> addTask(String title, String? description, DateTime deadline) async {
    final task = Task(
      title: title,
      description: description,
      deadline: deadline,
    );

    final id = await _databaseHelper.insertTask(task);
    final taskWithId = task.copyWith(id: id);
    
    _tasks.add(taskWithId);
    _tasks.sort((a, b) => a.deadline.compareTo(b.deadline));
    
    // Zaplanowanie przypomnienia
    await NotificationService.scheduleTaskReminder(taskWithId);
    
    notifyListeners();
  }

  // Edycja zadania
  Future<void> updateTask(Task task) async {
    await _databaseHelper.updateTask(task);
    
    // Aktualizacja w lokalnej liście
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      _tasks.sort((a, b) => a.deadline.compareTo(b.deadline));
    } else {
      final completedIndex = _completedTasks.indexWhere((t) => t.id == task.id);
      if (completedIndex != -1) {
        _completedTasks[completedIndex] = task;
      }
    }
    
    // Aktualizacja powiadomienia
    if (task.id != null) {
      await NotificationService.cancelTaskReminder(task.id!);
      if (!task.isCompleted) {
        await NotificationService.scheduleTaskReminder(task);
      }
    }
    
    notifyListeners();
  }

  // Oznaczanie zadania jako wykonane/niewykonane
  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await _databaseHelper.updateTask(updatedTask);
    
    if (updatedTask.isCompleted) {
      // Przenieś do wykonanych
      _tasks.removeWhere((t) => t.id == task.id);
      _completedTasks.add(updatedTask);
      
      // Anuluj przypomnienie
      if (task.id != null) {
        await NotificationService.cancelTaskReminder(task.id!);
      }
    } else {
      // Przenieś do niewykonanych
      _completedTasks.removeWhere((t) => t.id == task.id);
      _tasks.add(updatedTask);
      _tasks.sort((a, b) => a.deadline.compareTo(b.deadline));
      
      // Zaplanuj przypomnienie
      await NotificationService.scheduleTaskReminder(updatedTask);
    }
    
    notifyListeners();
  }

  // Usuwanie zadania
  Future<void> deleteTask(Task task) async {
    if (task.id != null) {
      await _databaseHelper.deleteTask(task.id!);
      await NotificationService.cancelTaskReminder(task.id!);
    }
    
    _tasks.removeWhere((t) => t.id == task.id);
    _completedTasks.removeWhere((t) => t.id == task.id);
    
    notifyListeners();
  }

  // Obliczanie najbardziej produktywnego dnia tygodnia
  String _calculateMostProductiveDay() {
    if (_completedTasks.isEmpty) return 'Brak danych';

    final dayNames = [
      'Niedziela', 'Poniedziałek', 'Wtorek', 'Środa', 
      'Czwartek', 'Piątek', 'Sobota'
    ];
    
    final Map<int, int> dayCounts = {};
    
    for (final task in _completedTasks) {
      final dayOfWeek = task.createdAt.weekday % 7;
      dayCounts[dayOfWeek] = (dayCounts[dayOfWeek] ?? 0) + 1;
    }
    
    if (dayCounts.isEmpty) return 'Brak danych';
    
    final mostProductiveDayIndex = dayCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    return dayNames[mostProductiveDayIndex];
  }

  // Pobieranie zadań z nadchodzącymi terminami (następne 7 dni)
  List<Task> get upcomingTasks {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    
    return _tasks.where((task) => 
        task.deadline.isAfter(now) && 
        task.deadline.isBefore(nextWeek)
    ).toList();
  }

  // Pobieranie przeterminowanych zadań
  List<Task> get overdueTasks {
    final now = DateTime.now();
    return _tasks.where((task) => task.deadline.isBefore(now)).toList();
  }
}
