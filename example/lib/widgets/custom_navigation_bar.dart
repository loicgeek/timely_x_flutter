// example/lib/widgets/custom_navigation_bar.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timely_x/timely_x.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({
    Key? key,
    required this.controller,
    this.onAddPressed,
  }) : super(key: key);

  final CalendarController controller;
  final VoidCallback? onAddPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Month Indicator
              Text(
                controller.getViewPeriodDescription(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(width: 24),

              // Navigation Controls
              _buildNavigationControls(),

              const Spacer(),

              // View Selector
              _buildViewSelector(context),

              const SizedBox(width: 16),

              // Resource Filter
              _buildResourceFilter(context),

              const SizedBox(width: 16),

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationControls() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNavButton(
            Icons.chevron_left,
            controller.previous,
            isLeft: true,
          ),
          _buildTodayButton(),
          _buildNavButton(Icons.chevron_right, controller.next, isRight: true),
        ],
      ),
    );
  }

  Widget _buildNavButton(
    IconData icon,
    VoidCallback onTap, {
    bool isLeft = false,
    bool isRight = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.horizontal(
        left: isLeft ? const Radius.circular(6) : Radius.zero,
        right: isRight ? const Radius.circular(6) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildTodayButton() {
    return InkWell(
      onTap: controller.goToToday,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.symmetric(
            vertical: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: const Text(
          'Today',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildViewSelector(BuildContext context) {
    final viewNames = {
      CalendarViewType.day: 'Day',
      CalendarViewType.week: 'Week',
      CalendarViewType.month: 'Month',
    };

    return PopupMenuButton<CalendarViewType>(
      offset: const Offset(0, 48),
      onSelected: controller.setViewType,
      itemBuilder: (context) => [
        _buildViewMenuItem('Day', CalendarViewType.day, Icons.view_day),
        _buildViewMenuItem('Week', CalendarViewType.week, Icons.view_week),
        _buildViewMenuItem(
          'Month',
          CalendarViewType.month,
          Icons.calendar_month,
        ),
        _buildViewMenuItem('Agenda', CalendarViewType.agenda, Icons.view_list),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              viewNames[controller.viewType] ?? 'Week',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<CalendarViewType> _buildViewMenuItem(
    String label,
    CalendarViewType viewType,
    IconData icon,
  ) {
    final isSelected = controller.viewType == viewType;
    return PopupMenuItem(
      value: viewType,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? Colors.blue : Colors.grey),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.blue : Colors.black87,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            const Icon(Icons.check, size: 18, color: Colors.blue),
          ],
        ],
      ),
    );
  }

  Widget _buildResourceFilter(BuildContext context) {
    final resources = controller.resources;

    return PopupMenuButton(
      offset: const Offset(0, 48),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (resources.isNotEmpty) ...[
              for (
                int i = 0;
                i < (resources.length > 3 ? 3 : resources.length);
                i++
              )
                Padding(
                  padding: EdgeInsets.only(left: i > 0 ? 4 : 0),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: resources[i].color ?? Colors.blue,
                    child: Text(
                      resources[i].name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
            ],
            const Text(
              'All providers',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey.shade600),
          ],
        ),
      ),
      onSelected: (value) {
        controller.addResourceToFilter(value.id);
      },
      itemBuilder: (context) => resources
          .map(
            (resource) => PopupMenuItem(
              value: resource,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: resource.color ?? Colors.blue,
                    child: Text(
                      resource.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(resource.name),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onAddPressed,
          style: ElevatedButton.styleFrom(
            // backgroundColor: const Color(0xFF212121),
            // foregroundColor: Colors.white,
            // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 18),
              SizedBox(width: 4),
              Text(
                'Add',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
