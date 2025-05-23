class TaskTableColumnData {
  final String id;
  final String label;
  double width;
  final String tooltip;
  final bool sortable;

  TaskTableColumnData({
    required this.id,
    required this.label,
    required this.width,
    required this.tooltip,
    required this.sortable,
  });
}
