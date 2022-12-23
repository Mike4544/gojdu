//  Import material
import "package:flutter/material.dart";
// Import colors
import "../others/colors.dart";

// Create a stateless widget that implements the chip widget with a label,
// color, delete icon and on delete function
class mFilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onDelete;

  const mFilterChip({
    Key? key,
    required this.label,
    required this.color,
    this.onDelete,
  }) : super(key: key);

  mFilterChip copyWith({String? label, Color? color, VoidCallback? onDelete}) {
    return mFilterChip(
      label: label ?? this.label,
      color: color ?? this.color,
      onDelete: onDelete,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
      deleteIcon: onDelete != null
          ? const Icon(
              Icons.close,
              color: Colors.white,
            )
          : null,
      onDeleted: onDelete,
    );
  }
}
