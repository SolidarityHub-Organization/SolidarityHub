import 'package:flutter/material.dart';
import 'package:solidarityhub/controllers/task_table_controller.dart';
import 'package:solidarityhub/models/task_table.dart';
import 'package:solidarityhub/widgets/task_table/task_table_cell.dart';

class TaskTable extends StatelessWidget {
  final TaskTableController controller;
  final VoidCallback onTaskChanged;

  const TaskTable({super.key, required this.controller, required this.onTaskChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 32,
      child: ReorderableListView(
        scrollDirection: Axis.horizontal,
        onReorder: controller.reorderColumn,
        header: SizedBox(
          height: 500,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Row(
              children: List.generate(controller.columns.length, (columnIndex) {
                return ReorderableDragStartListener(index: columnIndex, child: _buildColumn(context, columnIndex));
              }),
            ),
          ),
        ),
        children: <Widget>[],
      ),
    );
  }

  Widget _buildColumn(BuildContext context, int columnIndex) {
    final column = controller.columns[columnIndex];
    final width = (MediaQuery.of(context).size.width - 32) * column.width;

    return SizedBox(
      key: ValueKey(column.id),
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildColumnHeader(context, column, columnIndex), _buildColumnData(context, column)],
      ),
    );
  }

  Widget _buildColumnHeader(BuildContext context, TaskTableColumnData column, int columnIndex) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              column.label,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (column.sortable)
            IconButton(
              icon: Icon(
                controller.sortField == column.id
                    ? (controller.sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                    : Icons.unfold_more,
                size: 16,
              ),
              onPressed: () {
                if (controller.sortField == column.id) {
                  controller.sortAscending = !controller.sortAscending;
                } else {
                  controller.sortField = column.id;
                  controller.sortAscending = true;
                }
                controller.applyFilters();
                onTaskChanged();
              },
              tooltip: 'Ordenar por ${column.label}',
              constraints: const BoxConstraints(maxWidth: 24, maxHeight: 24),
              padding: EdgeInsets.zero,
            ),
          if (columnIndex < controller.columns.length - 1)
            MouseRegion(
              cursor: SystemMouseCursors.resizeLeftRight,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  final totalWidth = MediaQuery.of(context).size.width - 32;
                  final delta = details.delta.dx / totalWidth;
                  final minWidth = 0.05;
                  final maxWidth = 0.5;

                  final newWidth = controller.columns[columnIndex].width + delta;
                  final nextWidth = controller.columns[columnIndex + 1].width - delta;

                  if (newWidth >= minWidth && newWidth <= maxWidth && nextWidth >= minWidth && nextWidth <= maxWidth) {
                    controller.columns[columnIndex].width = newWidth;
                    controller.columns[columnIndex + 1].width = nextWidth;
                    onTaskChanged();
                  }
                },
                child: Container(
                  width: 8,
                  height: 24,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border(right: BorderSide(color: Colors.grey[400]!, width: 2)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildColumnData(BuildContext context, TaskTableColumnData column) {
    return SizedBox(
      height: 450,
      child: ListView.builder(
        itemCount: controller.filteredTasks.isEmpty ? 1 : controller.filteredTasks.length,
        itemBuilder: (context, rowIndex) {
          if (controller.filteredTasks.isEmpty) {
            return Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
              alignment: Alignment.centerLeft,
              child: column.id == 'name' ? const Text('No se encontraron resultados') : const Text(''),
            );
          }

          final task = controller.filteredTasks[rowIndex];
          return Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
            child: TaskTableCell(columnId: column.id, task: task, controller: controller, onTaskChanged: onTaskChanged),
          );
        },
      ),
    );
  }
}
