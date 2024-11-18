import 'dart:ui';

class TyxEvent {
  DateTime start;
  DateTime end;
  Color color;
  String? resourceId;

  TyxEvent({
    required this.start,
    required this.end,
    required this.color,
    this.resourceId,
  });

  @override
  bool operator ==(covariant TyxEvent other) {
    if (identical(this, other)) return true;

    return other.start == start &&
        other.end == end &&
        other.color == color &&
        other.resourceId == resourceId;
  }

  @override
  int get hashCode =>
      start.hashCode ^ end.hashCode ^ color.hashCode ^ resourceId.hashCode;
}
