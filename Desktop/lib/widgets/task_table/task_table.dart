import 'package:flutter/material.dart';
import 'package:solidarityhub/controllers/tasks/task_table_controller.dart';
import 'package:solidarityhub/widgets/task_table/task_table_cell.dart';
import 'package:solidarityhub/widgets/task_table/pagination_controls.dart';
import 'package:solidarityhub/models/task_table.dart';

class TaskTableHeader extends StatefulWidget {
  final TaskTableController controller;
  final VoidCallback onTaskChanged;
  final double tableWidth;

  const TaskTableHeader({super.key, required this.controller, required this.onTaskChanged, required this.tableWidth});
  @override
  State<TaskTableHeader> createState() => _TaskTableHeaderState();
}

class _TaskTableHeaderState extends State<TaskTableHeader> {
  int? _draggedColumnIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
      ),
      child: Row(
        children: List.generate(widget.controller.columns.length, (columnIndex) {
          final column = widget.controller.columns[columnIndex];
          final width = widget.tableWidth * column.width;

          return DragTarget<int>(
            onAccept: (draggedIndex) {
              if (draggedIndex != columnIndex) {
                widget.controller.reorderColumn(draggedIndex, columnIndex);
                widget.onTaskChanged();
              }
              setState(() {
                _draggedColumnIndex = null;
              });
            },
            onWillAccept: (draggedIndex) {
              return draggedIndex != null && draggedIndex != columnIndex;
            },
            builder: (context, candidateData, rejectedData) {
              return Draggable<int>(
                data: columnIndex,
                onDragStarted: () {
                  setState(() {
                    _draggedColumnIndex = columnIndex;
                  });
                },
                onDragEnd: (details) {
                  setState(() {
                    _draggedColumnIndex = null;
                  });
                },
                feedback: Material(
                  elevation: 8,
                  child: Container(
                    width: width,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                    ),
                    child: Text(
                      column.label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                childWhenDragging: Container(
                  width: width,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    border: Border(
                      right:
                          columnIndex < widget.controller.columns.length - 1
                              ? BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.3), width: 1)
                              : BorderSide.none,
                    ),
                  ),
                  child: Text(
                    column.label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                child: Container(
                  width: width,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color:
                        candidateData.isNotEmpty
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: Border(
                      right:
                          columnIndex < widget.controller.columns.length - 1
                              ? BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.3), width: 1)
                              : BorderSide.none,
                      bottom:
                          candidateData.isNotEmpty
                              ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
                              : BorderSide.none,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.drag_handle,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(width: 8),
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
                              final totalWidth = widget.tableWidth;
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
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

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
    widget.controller.filteredTasksNotifier.addListener(_onFilteredTasksChanged);
    widget.controller.columnsNotifier.addListener(_onColumnsChanged);
    widget.controller.paginatedTasksNotifier.addListener(_onPaginatedTasksChanged);
  }

  @override
  void dispose() {
    widget.controller.filteredTasksNotifier.removeListener(_onFilteredTasksChanged);
    widget.controller.columnsNotifier.removeListener(_onColumnsChanged);
    widget.controller.paginatedTasksNotifier.removeListener(_onPaginatedTasksChanged);
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  void _onFilteredTasksChanged() {
    setState(() {});
  }

  void _onColumnsChanged() {
    setState(() {});
  }

  void _onPaginatedTasksChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tableWidth = MediaQuery.of(context).size.width - 32;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: tableWidth,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
                controller: _horizontalScrollController,
                thumbVisibility: true,
                notificationPredicate: (notification) => notification.depth == 0,
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: [
                      ValueListenableBuilder<List<TaskTableColumnData>>(
                        valueListenable: widget.controller.columnsNotifier,
                        builder: (context, columns, child) {
                          return TaskTableHeader(
                            controller: widget.controller,
                            onTaskChanged: widget.onTaskChanged,
                            tableWidth: tableWidth,
                          );
                        },
                      ),
                      Expanded(child: _buildTableContent(tableWidth)),
                    ],
                  ),
                ),
              ),
            ),
            PaginationControls(controller: widget.controller),
          ],
        ),
      ),
    );
  }

  Widget _buildTableContent(double tableWidth) {
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

    final tasksToShow = widget.controller.paginatedTasks;

    return SingleChildScrollView(
      controller: _verticalScrollController,
      child: Column(
        children: List.generate(tasksToShow.length, (rowIndex) {
          final task = tasksToShow[rowIndex];
          return Container(
            color:
                rowIndex % 2 == 0
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            child: Row(
              children: List.generate(widget.controller.columns.length, (columnIndex) {
                final column = widget.controller.columns[columnIndex];
                final width = tableWidth * column.width;

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
    );
  }
}
