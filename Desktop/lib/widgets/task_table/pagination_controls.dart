import 'package:flutter/material.dart';
import 'package:solidarityhub/controllers/tasks/task_table_controller.dart';

class PaginationControls extends StatefulWidget {
  final TaskTableController controller;

  const PaginationControls({super.key, required this.controller});

  @override
  State<PaginationControls> createState() => _PaginationControlsState();
}

class _PaginationControlsState extends State<PaginationControls> {
  @override
  void initState() {
    super.initState();
    widget.controller.currentPageNotifier.addListener(_onPaginationChanged);
    widget.controller.totalPagesNotifier.addListener(_onPaginationChanged);
    widget.controller.itemsPerPageNotifier.addListener(_onPaginationChanged);
  }

  @override
  void dispose() {
    widget.controller.currentPageNotifier.removeListener(_onPaginationChanged);
    widget.controller.totalPagesNotifier.removeListener(_onPaginationChanged);
    widget.controller.itemsPerPageNotifier.removeListener(_onPaginationChanged);
    super.dispose();
  }

  void _onPaginationChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentPage = widget.controller.currentPage;
    final totalPages = widget.controller.totalPages;
    final totalItems = widget.controller.totalItems;
    final itemsPerPage = widget.controller.itemsPerPage;

    final startItem = totalItems == 0 ? 0 : (currentPage - 1) * itemsPerPage + 1;
    final endItem = (currentPage * itemsPerPage).clamp(0, totalItems);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Mostrando $startItem-$endItem de $totalItems elementos',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Text(
                    'Elementos por página:',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: itemsPerPage,
                    onChanged: (value) {
                      if (value != null) {
                        widget.controller.itemsPerPage = value;
                      }
                    },
                    items:
                        [5, 10, 25, 50, 100].map((value) {
                          return DropdownMenuItem<int>(value: value, child: Text(value.toString()));
                        }).toList(),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: widget.controller.canGoToPrevious ? widget.controller.goToFirstPage : null,
                icon: const Icon(Icons.first_page),
                tooltip: 'Primera página',
              ),
              IconButton(
                onPressed: widget.controller.canGoToPrevious ? widget.controller.goToPreviousPage : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Página anterior',
              ),
              _buildPageSelector(theme, currentPage, totalPages),
              IconButton(
                onPressed: widget.controller.canGoToNext ? widget.controller.goToNextPage : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Página siguiente',
              ),
              IconButton(
                onPressed: widget.controller.canGoToNext ? widget.controller.goToLastPage : null,
                icon: const Icon(Icons.last_page),
                tooltip: 'Última página',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageSelector(ThemeData theme, int currentPage, int totalPages) {
    if (totalPages <= 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'Página 1 de 1',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    return Row(
      children: [
        if (totalPages <= 7)
          ..._buildDirectPageButtons(theme, currentPage, totalPages)
        else
          ..._buildEllipsisPageButtons(theme, currentPage, totalPages),
      ],
    );
  }

  List<Widget> _buildDirectPageButtons(ThemeData theme, int currentPage, int totalPages) {
    List<Widget> buttons = [];

    for (int i = 1; i <= totalPages; i++) {
      buttons.add(_buildPageButton(theme, i, currentPage == i));
    }

    return buttons;
  }

  List<Widget> _buildEllipsisPageButtons(ThemeData theme, int currentPage, int totalPages) {
    List<Widget> buttons = [];

    buttons.add(_buildPageButton(theme, 1, currentPage == 1));

    if (currentPage > 4) {
      buttons.add(_buildEllipsis(theme));
    }

    int start = (currentPage - 2).clamp(2, totalPages - 1);
    int end = (currentPage + 2).clamp(2, totalPages - 1);

    for (int i = start; i <= end; i++) {
      buttons.add(_buildPageButton(theme, i, currentPage == i));
    }

    if (currentPage < totalPages - 3) {
      buttons.add(_buildEllipsis(theme));
    }

    if (totalPages > 1) {
      buttons.add(_buildPageButton(theme, totalPages, currentPage == totalPages));
    }

    return buttons;
  }

  Widget _buildPageButton(ThemeData theme, int page, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: isSelected ? null : () => widget.controller.goToPage(page),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.dividerColor),
          ),
          child: Text(
            page.toString(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text('...', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
    );
  }
}
