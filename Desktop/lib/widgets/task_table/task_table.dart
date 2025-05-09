import 'package:flutter/material.dart';
import 'package:solidarityhub/controllers/tasks/task_table_controller.dart';
import 'package:solidarityhub/widgets/task_table/task_table_cell.dart';

class TaskTable extends StatefulWidget {
  final TaskTableController controller;
  final VoidCallback onTaskChanged;

  const TaskTable({super.key, required this.controller, required this.onTaskChanged});

  @override
  State<TaskTable> createState() => _TaskTableState();
}

class _TaskTableState extends State<TaskTable> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.addressesNotifier.addListener(_onAddressesChanged);
    widget.controller.filteredTasksNotifier.addListener(_onFilteredTasksChanged);
  }

  @override
  void dispose() {
    widget.controller.addressesNotifier.removeListener(_onAddressesChanged);
    widget.controller.filteredTasksNotifier.removeListener(_onFilteredTasksChanged);
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  void _onAddressesChanged() {
    setState(() {});
  }

  void _onFilteredTasksChanged() {
    setState(() {});
    // Cargar direcciones para las tareas filtradas cuando cambian
    widget.controller.fetchAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: MediaQuery.of(context).size.width - 32,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Column(children: [_buildTableHeader(), Expanded(child: _buildTableContent())]),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
      ),
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(widget.controller.columns.length, (columnIndex) {
            final column = widget.controller.columns[columnIndex];
            final width = (MediaQuery.of(context).size.width - 32) * column.width;

            return Container(
              width: width,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  right:
                      columnIndex < widget.controller.columns.length - 1
                          ? BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.3), width: 1)
                          : BorderSide.none,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      column.label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (column.sortable)
                    Tooltip(
                      message: 'Ordenar por ${column.label}',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            widget.controller.sortField == column.id
                                ? (widget.controller.sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                                : Icons.unfold_more,
                            size: 18,
                            color:
                                widget.controller.sortField == column.id
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        onTap: () {
                          if (widget.controller.sortField == column.id) {
                            widget.controller.sortAscending = !widget.controller.sortAscending;
                          } else {
                            widget.controller.sortField = column.id;
                            widget.controller.sortAscending = true;
                          }
                          widget.controller.applyFilters();
                          widget.onTaskChanged();
                        },
                      ),
                    ),
                  if (columnIndex < widget.controller.columns.length - 1)
                    MouseRegion(
                      cursor: SystemMouseCursors.resizeLeftRight,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          final totalWidth = MediaQuery.of(context).size.width - 32;
                          final delta = details.delta.dx / totalWidth;
                          final minWidth = 0.05;
                          final maxWidth = 0.5;

                          final newWidth = widget.controller.columns[columnIndex].width + delta;
                          final nextWidth = widget.controller.columns[columnIndex + 1].width - delta;
                          if (newWidth >= minWidth &&
                              newWidth <= maxWidth &&
                              nextWidth >= minWidth &&
                              nextWidth <= maxWidth) {
                            widget.controller.updateColumnWidths(columnIndex, newWidth, columnIndex + 1, nextWidth);
                            setState(() {});
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
          }),
        ),
      ),
    );
  }

  Widget _buildTableContent() {
    if (widget.controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.controller.filteredTasks.isEmpty) {
      return Center(
        child: Text(
          'No se encontraron resultados',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic),
        ),
      );
    }

    return SingleChildScrollView(
      controller: _verticalScrollController,
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: Column(
          children: List.generate(widget.controller.filteredTasks.length, (rowIndex) {
            final task = widget.controller.filteredTasks[rowIndex];
            return Container(
              color:
                  rowIndex % 2 == 0
                      ? Theme.of(context).colorScheme.surface
                      : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              child: Row(
                children: List.generate(widget.controller.columns.length, (columnIndex) {
                  final column = widget.controller.columns[columnIndex];
                  final width = (MediaQuery.of(context).size.width - 32) * column.width;

                  return Container(
                    width: width,
                    decoration: BoxDecoration(
                      border: Border(
                        right:
                            columnIndex < widget.controller.columns.length - 1
                                ? BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.3), width: 1)
                                : BorderSide.none,
                        bottom: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TaskTableCell(
                        columnId: column.id,
                        task: task,
                        controller: widget.controller,
                        onTaskChanged: widget.onTaskChanged,
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}
