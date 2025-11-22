import 'package:flutter/material.dart';
import 'package:calendar2/calendar2.dart';

/// Helper class for creating test resources
class TestResources {
  /// Creates a basic resource
  static DefaultResource basic({
    String? id,
    String? name,
    String? avatarUrl,
    Color? color,
    bool? isActive,
    String? category,
  }) {
    return DefaultResource(
      id: id ?? 'resource-${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Test Resource',
      avatarUrl: avatarUrl,
      color: color ?? Colors.blue,
      isActive: isActive ?? true,
      category: category,
    );
  }

  /// Creates a resource with avatar URL
  static DefaultResource withAvatar({
    String? id,
    String? name,
    required String avatarUrl,
  }) {
    return DefaultResource(
      id: id ?? 'resource-avatar-${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Resource with Avatar',
      avatarUrl: avatarUrl,
    );
  }

  /// Creates an inactive resource
  static DefaultResource inactive({String? id, String? name}) {
    return DefaultResource(
      id: id ?? 'resource-inactive-${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Inactive Resource',
      isActive: false,
      color: Colors.grey,
    );
  }

  /// Creates a resource with category
  static DefaultResource withCategory({
    String? id,
    String? name,
    required String category,
    Color? color,
  }) {
    return DefaultResource(
      id: id ?? 'resource-cat-${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Categorized Resource',
      category: category,
      color: color ?? Colors.blue,
    );
  }

  /// Creates a list of resources for testing
  static List<DefaultResource> multipleResources({
    int count = 5,
    String? prefix,
    List<String>? categories,
  }) {
    return List.generate(count, (index) {
      return DefaultResource(
        id: 'resource-${prefix ?? 'multi'}-$index',
        name: '${prefix ?? 'Resource'} ${index + 1}',
        color: _colorForIndex(index),
        category: categories != null && categories.isNotEmpty
            ? categories[index % categories.length]
            : null,
        isActive: true,
      );
    });
  }

  /// Creates resources for different teams/departments
  static List<DefaultResource> byDepartment() {
    return [
      DefaultResource(
        id: 'eng-1',
        name: 'John Doe',
        category: 'Engineering',
        color: Colors.blue,
      ),
      DefaultResource(
        id: 'eng-2',
        name: 'Jane Smith',
        category: 'Engineering',
        color: Colors.blue,
      ),
      DefaultResource(
        id: 'sales-1',
        name: 'Bob Johnson',
        category: 'Sales',
        color: Colors.green,
      ),
      DefaultResource(
        id: 'sales-2',
        name: 'Alice Williams',
        category: 'Sales',
        color: Colors.green,
      ),
      DefaultResource(
        id: 'design-1',
        name: 'Charlie Brown',
        category: 'Design',
        color: Colors.purple,
      ),
    ];
  }

  /// Creates a large set of resources for performance testing
  static List<DefaultResource> largeSet({
    int count = 100,
    List<String>? categories,
  }) {
    return List.generate(count, (index) {
      return DefaultResource(
        id: 'perf-resource-$index',
        name: 'Resource $index',
        color: _colorForIndex(index),
        category: categories != null && categories.isNotEmpty
            ? categories[index % categories.length]
            : null,
        isActive: index % 10 != 0, // Every 10th resource is inactive
      );
    });
  }

  /// Helper to get color based on index
  static Color _colorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];
    return colors[index % colors.length];
  }

  /// Creates meeting room resources
  static List<DefaultResource> meetingRooms() {
    return [
      DefaultResource(
        id: 'room-a',
        name: 'Conference Room A',
        category: 'Large',
        color: Colors.blue,
      ),
      DefaultResource(
        id: 'room-b',
        name: 'Conference Room B',
        category: 'Medium',
        color: Colors.green,
      ),
      DefaultResource(
        id: 'room-c',
        name: 'Meeting Room C',
        category: 'Small',
        color: Colors.orange,
      ),
      DefaultResource(
        id: 'room-d',
        name: 'Phone Booth',
        category: 'Solo',
        color: Colors.purple,
      ),
    ];
  }

  /// Creates medical resources (doctors, rooms, equipment)
  static List<DefaultResource> medicalResources() {
    return [
      DefaultResource(
        id: 'dr-smith',
        name: 'Dr. Smith',
        category: 'General Practitioner',
        color: Colors.blue,
      ),
      DefaultResource(
        id: 'dr-jones',
        name: 'Dr. Jones',
        category: 'Specialist',
        color: Colors.purple,
      ),
      DefaultResource(
        id: 'exam-1',
        name: 'Exam Room 1',
        category: 'Room',
        color: Colors.green,
      ),
      DefaultResource(
        id: 'exam-2',
        name: 'Exam Room 2',
        category: 'Room',
        color: Colors.green,
      ),
      DefaultResource(
        id: 'xray',
        name: 'X-Ray Machine',
        category: 'Equipment',
        color: Colors.orange,
      ),
    ];
  }
}
