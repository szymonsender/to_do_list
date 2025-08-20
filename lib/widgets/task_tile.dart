import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  const TaskTile({
    Key? key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOverdue = !task.isCompleted && task.deadline.isBefore(DateTime.now());
    final daysUntilDeadline = task.deadline.difference(DateTime.now()).inDays;
    
    return Dismissible(
      key: Key('task_${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Usuń zadanie'),
            content: Text('Czy na pewno chcesz usunąć zadanie "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Anuluj'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Usuń'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: task.isCompleted ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOverdue 
                ? Colors.red.shade300 
                : task.isCompleted 
                    ? Colors.green.shade300 
                    : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: GestureDetector(
            onTap: onToggleComplete,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isCompleted ? Colors.green : Colors.grey,
                  width: 2,
                ),
                color: task.isCompleted ? Colors.green : Colors.transparent,
              ),
              child: task.isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted ? Colors.grey.shade600 : Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  task.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: task.isCompleted ? Colors.grey.shade500 : Colors.grey.shade700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: isOverdue 
                        ? Colors.red.shade600 
                        : task.isCompleted 
                            ? Colors.grey.shade500 
                            : Colors.grey.shade600,
                  ),
                  Text(
                    DateFormat('dd.MM.yyyy HH:mm').format(task.deadline),
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue 
                          ? Colors.red.shade600 
                          : task.isCompleted 
                              ? Colors.grey.shade500 
                              : Colors.grey.shade600,
                      fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (!task.isCompleted && daysUntilDeadline >= 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: daysUntilDeadline == 0 
                            ? Colors.orange.shade100 
                            : daysUntilDeadline == 1 
                                ? Colors.yellow.shade100 
                                : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        daysUntilDeadline == 0 
                            ? 'Dziś' 
                            : daysUntilDeadline == 1 
                                ? 'Jutro' 
                                : '${daysUntilDeadline}d',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: daysUntilDeadline == 0 
                              ? Colors.orange.shade700 
                              : daysUntilDeadline == 1 
                                  ? Colors.yellow.shade700 
                                  : Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                  if (isOverdue) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Przeterminowane',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: IconButton(
            onPressed: onTap,
            icon: Icon(
              Icons.edit,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
