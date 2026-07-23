import 'package:flutter/material.dart';

enum AdminActiveStatusFilter { all, active, hidden }

class AdminFilterSortHeader<T> extends StatelessWidget {
  const AdminFilterSortHeader({
    super.key,
    required this.activeStatus,
    required this.onActiveStatusChanged,
    required this.sortValue,
    required this.sortItems,
    required this.onSortChanged,
    this.activeLabel = 'Đang hoạt động',
    this.hiddenLabel = 'Tạm ẩn',
    this.extraFilterWidget,
  });

  final AdminActiveStatusFilter activeStatus;
  final ValueChanged<AdminActiveStatusFilter> onActiveStatusChanged;
  final T sortValue;
  final List<DropdownMenuItem<T>> sortItems;
  final ValueChanged<T?> onSortChanged;
  final String activeLabel;
  final String hiddenLabel;
  final Widget? extraFilterWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Tất cả'),
                        selected: activeStatus == AdminActiveStatusFilter.all,
                        selectedColor: const Color(0xFFD7262D),
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF2C2C2C)
                                : const Color(0xFFEEEEEE),
                        labelStyle: TextStyle(
                          color: activeStatus == AdminActiveStatusFilter.all
                              ? Colors.white
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF212121)),
                          fontWeight:
                              activeStatus == AdminActiveStatusFilter.all
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                          fontSize: 12,
                        ),
                        onSelected: (_) =>
                            onActiveStatusChanged(AdminActiveStatusFilter.all),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(activeLabel),
                        selected:
                            activeStatus == AdminActiveStatusFilter.active,
                        selectedColor: const Color(0xFFD7262D),
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF2C2C2C)
                                : const Color(0xFFEEEEEE),
                        labelStyle: TextStyle(
                          color: activeStatus == AdminActiveStatusFilter.active
                              ? Colors.white
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF212121)),
                          fontWeight:
                              activeStatus == AdminActiveStatusFilter.active
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                          fontSize: 12,
                        ),
                        onSelected: (_) => onActiveStatusChanged(
                          AdminActiveStatusFilter.active,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(hiddenLabel),
                        selected:
                            activeStatus == AdminActiveStatusFilter.hidden,
                        selectedColor: const Color(0xFFD7262D),
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF2C2C2C)
                                : const Color(0xFFEEEEEE),
                        labelStyle: TextStyle(
                          color: activeStatus == AdminActiveStatusFilter.hidden
                              ? Colors.white
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF212121)),
                          fontWeight:
                              activeStatus == AdminActiveStatusFilter.hidden
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                          fontSize: 12,
                        ),
                        onSelected: (_) => onActiveStatusChanged(
                          AdminActiveStatusFilter.hidden,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: sortValue,
                    icon: const Icon(Icons.sort_rounded, size: 20),
                    isDense: true,
                    items: sortItems,
                    onChanged: onSortChanged,
                  ),
                ),
              ),
            ],
          ),
          if (extraFilterWidget != null) ...[
            const SizedBox(height: 6),
            extraFilterWidget!,
          ],
        ],
      ),
    );
  }
}
