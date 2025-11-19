// lib/src/models/calendar_resource.dart

import 'package:flutter/material.dart';

/// Abstract base class for calendar resources
/// Extend this class to create your custom resource model
abstract class CalendarResource {
  /// Unique identifier for the resource
  String get id;

  /// Display name of the resource
  String get name;

  /// Optional avatar URL or path
  String? get avatarUrl => null;

  /// Optional color for this resource
  Color? get color => null;

  /// Whether this resource is currently active/available
  bool get isActive => true;

  /// Optional category or department
  String? get category => null;

  /// Any custom data you want to attach
  Map<String, dynamic>? get customData => null;
}

/// Default implementation of CalendarResource
class DefaultResource extends CalendarResource {
  DefaultResource({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.color,
    this.isActive = true,
    this.category,
    this.customData,
  });

  @override
  final String id;

  @override
  final String name;

  @override
  final String? avatarUrl;

  @override
  final Color? color;

  @override
  final bool isActive;

  @override
  final String? category;

  @override
  final Map<String, dynamic>? customData;

  DefaultResource copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    Color? color,
    bool? isActive,
    String? category,
    Map<String, dynamic>? customData,
  }) {
    return DefaultResource(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
      customData: customData ?? this.customData,
    );
  }
}
