import 'package:flutter/material.dart';

class Itemcard extends StatelessWidget {
  final String title;
  final String content;
  final String type;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const Itemcard({
    Key? key,
    required this.title,
    required this.content,
    required this.type,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  Color _getBGColor(String type) {
    switch (type.trim().toLowerCase()) {
      case 'personal':
        return Colors.lightBlue.shade100;
      case 'work':
        return Colors.yellow.shade100;
      case 'study':
        return Colors.pink.shade100;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getBGColor(type),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(type, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                ),
                Row(
                  mainAxisSize:
                      MainAxisSize.min, // Add this to minimize the row's width
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero, // Remove default padding
                      constraints:
                          const BoxConstraints(), // Remove minimum size constraints
                      icon: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.black,
                      ),
                      onPressed: onEdit,
                    ),
                    const SizedBox(width: 4), // Reduce spacing between icons
                    IconButton(
                      padding: EdgeInsets.zero, // Remove default padding
                      constraints:
                          const BoxConstraints(), // Remove minimum size constraints
                      icon: const Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.black,
                      ),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
