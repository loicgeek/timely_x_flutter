import 'tyx_resource.dart';

class TyxResourceEnhanced<R extends TyxResource> {
  final double width;
  final double height;
  final R? resource;
  TyxResourceEnhanced({
    required this.width,
    required this.height,
    this.resource,
  });
}
