import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:timely_x_flutter/src/models/tyx_resource_option.dart';
import 'package:timely_x_flutter/src/presentation/tyx_resource/tyx_resource_view_content.dart';

class TyxResourceView extends StatefulWidget {
  const TyxResourceView({
    super.key,
    this.onDateChanged,
    this.onShowDatePicker,
    required this.option,
    this.currentDateFormatter,
  });
  final Function(DateTime date)? onDateChanged;
  final String Function(DateTime date)? currentDateFormatter;
  final Future<DateTime?> Function({required BuildContext context})?
      onShowDatePicker;
  final TyxResourceOption option;

  @override
  State<TyxResourceView> createState() => _TyxResourceViewState();
}

class _TyxResourceViewState extends State<TyxResourceView> {
  late DateTime _currentDate;
  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
  }

  _onDateChanged(DateTime date) {
    setState(() {
      _currentDate = date;
      widget.onDateChanged?.call(_currentDate);
    });
  }

  _gotoNextDate() {
    _onDateChanged(Jiffy.parseFromDateTime(_currentDate)
        .startOf(Unit.day)
        .add(days: 1)
        .dateTime);
  }

  _gotoPreviousDate() {
    _onDateChanged(Jiffy.parseFromDateTime(_currentDate)
        .startOf(Unit.day)
        .subtract(days: 1)
        .dateTime);
  }

  _onShowDatePicker({required BuildContext ctx}) async {
    var pickedDate = widget.onShowDatePicker != null
        ? await widget.onShowDatePicker?.call(context: ctx)
        : await showDatePicker(
            context: ctx,
            initialDate: _currentDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
    if (pickedDate != null) {
      _onDateChanged(pickedDate as DateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        _onShowDatePicker(ctx: context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(widget.currentDateFormatter != null
                                ? widget.currentDateFormatter!(_currentDate)
                                : DateFormat("dd MMM yyyy")
                                    .format(_currentDate)),
                            const SizedBox(width: 2),
                            Transform.rotate(
                              angle: -pi / 2,
                              child: const Icon(
                                Icons.chevron_left,
                                weight: .5,
                                size: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.chevron_left,
                            weight: .5,
                            size: 17,
                            color: Color(0Xff5C5F62),
                          ),
                          SizedBox(width: 2),
                          Text(
                            "Aujourd'hui",
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0Xff5C5F62),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right,
                            weight: .5,
                            size: 17,
                            color: Color(0Xff5C5F62),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Theme.of(context).primaryColor.withOpacity(.3),
                    ),
                    child: Text(
                      "Jour",
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      // color:
                      //     Theme.of(context).primaryColor.withOpacity(.3),
                    ),
                    child: Text(
                      "Semaine",
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      // color:
                      //     Theme.of(context).primaryColor.withOpacity(.3),
                    ),
                    child: Text(
                      "Mois",
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TyxResourceViewContent(
              option: widget.option,
            ),
          ),
        ],
      ),
    );
  }
}
