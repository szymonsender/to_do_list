import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statystyki'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final completedCount = taskProvider.completedTasksCount;
          final totalTasks = taskProvider.tasks.length + completedCount;
          final activeTasksCount = taskProvider.tasks.length;
          final overdueTasksCount = taskProvider.overdueTasks.length;
          final upcomingTasksCount = taskProvider.upcomingTasks.length;
          
          final completionRate = totalTasks > 0 
              ? (completedCount / totalTasks * 100).round()
              : 0;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ogólne statystyki
                _buildStatCard(
                  title: 'Podsumowanie zadań',
                  icon: Icons.analytics,
                  color: Colors.blue,
                  children: [
                    _buildStatRow('Wszystkich zadań', '$totalTasks'),
                    _buildStatRow('Wykonanych', '$completedCount'),
                    _buildStatRow('Aktywnych', '$activeTasksCount'),
                    _buildStatRow('Przeterminowanych', '$overdueTasksCount'),
                    const Divider(),
                    _buildStatRow(
                      'Wskaźnik ukończenia', 
                      '$completionRate%',
                      highlight: true,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Najbardziej produktywny dzień
                _buildStatCard(
                  title: 'Produktywność',
                  icon: Icons.trending_up,
                  color: Colors.green,
                  children: [
                    _buildStatRow(
                      'Najbardziej produktywny dzień', 
                      taskProvider.mostProductiveDay,
                      highlight: true,
                    ),
                    _buildStatRow('Nadchodzące zadania (7 dni)', '$upcomingTasksCount'),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Wizualizacja postępu
                if (totalTasks > 0) 
                  _buildProgressCard(completedCount, totalTasks, completionRate),
                
                const SizedBox(height: 16),
                
                // Motywujące cytaty
                _buildMotivationCard(completionRate),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: highlight ? Colors.purple : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(int completed, int total, int percentage) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.show_chart,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Postęp realizacji',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Pasek postępu
            LinearProgressIndicator(
              value: completed / total,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage >= 80 ? Colors.green : 
                percentage >= 50 ? Colors.orange : Colors.red,
              ),
              minHeight: 8,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              '$completed z $total zadań wykonanych ($percentage%)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationCard(int completionRate) {
    String message;
    IconData icon;
    Color color;
    
    if (completionRate >= 80) {
      message = 'Świetna robota! Jesteś bardzo produktywny! 🎉';
      icon = Icons.celebration;
      color = Colors.green;
    } else if (completionRate >= 50) {
      message = 'Dobra robota! Kontynuuj tak dalej! 💪';
      icon = Icons.thumb_up;
      color = Colors.orange;
    } else if (completionRate > 0) {
      message = 'Każdy krok to postęp. Nie poddawaj się! 🌟';
      icon = Icons.star;
      color = Colors.blue;
    } else {
      message = 'Czas zacząć! Pierwszy krok to podstawa. 🚀';
      icon = Icons.rocket_launch;
      color = Colors.purple;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
