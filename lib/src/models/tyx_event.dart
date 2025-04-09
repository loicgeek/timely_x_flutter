import 'dart:ui';

class TyxEvent {
  DateTime start;
  DateTime end;
  Color color;
  String? resourceId;
  String? title;
  String? description;
  String? location;

  TyxEvent({
    required this.start,
    required this.end,
    required this.color,
    this.resourceId,
    this.title,
    this.description,
    this.location,
  });

  @override
  bool operator ==(covariant TyxEvent other) {
    if (identical(this, other)) return true;

    return other.start == start &&
        other.end == end &&
        other.color == color &&
        other.title == title &&
        other.description == description &&
        other.location == location &&
        other.resourceId == resourceId;
  }

  @override
  int get hashCode =>
      start.hashCode ^
      end.hashCode ^
      color.hashCode ^
      resourceId.hashCode ^
      title.hashCode ^
      location.hashCode ^
      description.hashCode;
}
