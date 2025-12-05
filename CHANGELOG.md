# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.2] - 2024-12-05
* Added screenshots to documentation

## [2.0.1] - 2024-12-05
* Added screenshots to documentation

## [2.0.0] - 2024-12-05

### 🎉 Major Release - Complete Rewrite

TimelyX 2.0 is a complete rewrite and massive upgrade from v1.x, offering a professional, production-ready calendar library with comprehensive features and extensive customization.

### ⚠️ BREAKING CHANGES

This is a major version update with breaking changes from v1.x. The API has been completely redesigned for better usability and consistency.

**Migration Required:**
- Package name remains `timely_x`
- API structure has changed significantly

**Installation:**
```yaml
dependencies:
  timely_x: ^2.0.0
```

### ✨ Added

#### Core Features
- **Multiple View Types**: Day, Week, Month, and Agenda views with smooth transitions
- **Multi-Resource Scheduling**: Display appointments across multiple resources (people, rooms, equipment, etc.)
- **Business Hours Support**: Define working hours and unavailability periods per resource
- **Appointment Count Badges**: Show appointment counts in resource headers (configurable per view layout)
- **Intelligent Overlap Handling**: Automatic positioning and sizing of overlapping appointments
- **Current Time Indicator**: Real-time line showing the current time in day/week views
- **Date Range Selection**: Single date, range, and multi-date selection modes in month view

#### Interactions
- **Rich Gesture Support**:
  - Single tap on appointments
  - Long press on appointments
  - Secondary tap (right-click) on appointments
  - Cell tap and long press for creating appointments
  - Resource and date header interactions
- **Drag and Drop**: Full drag and drop support with configurable snap-to-grid
- **Appointment Resizing**: Resize appointments to change duration
- **Scroll Synchronization**: Seamless synchronized scrolling across view components

#### Customization
- **65+ Theme Properties** organized into categories:
  - 16 color properties (grid, backgrounds, highlights, weekends)
  - 10 text style properties (complete typography control)
  - 6 date format properties (flexible formatting for any locale)
  - 7 spacing properties (padding, margins, sizing)
  - 8 month view specific properties
  - 3 decoration properties (borders, shadows)
  - 4 drag & drop customization properties
  - 11 agenda view properties
- **Custom Builders**: Replace any component with your own implementation:
  - Resource headers
  - Date headers
  - Time column
  - Appointments
  - Empty cells
  - Current time indicator
  - Agenda items and sections
- **Flexible Layouts**:
  - Week view: Resources-first or Days-first layouts
  - Configurable column widths (min, max, preferred)
  - Responsive design with automatic adaptation

#### Developer Experience
- **Powerful Controller API**: Complete CRUD operations with reactive state management
- **Type-Safe Models**: Extend abstract base classes for custom implementations
- **Conflict Detection**: Built-in time slot availability checking
- **DST-Safe Date Handling**: Proper handling of daylight saving time transitions
- **Event Callbacks**: Comprehensive callback system for all interactions
- **Extensive Documentation**:
  - Complete API reference
  - Customization guide
  - Quick reference cheat sheet
  - Migration guide
  - Real-world examples
  - Contributing guidelines

#### Performance
- **Viewport-Based Rendering**: Only render visible appointments for optimal performance
- **Smooth 60 FPS**: Optimized for smooth scrolling even with 100+ appointments
- **Efficient State Management**: Minimal rebuilds with targeted notifications
- **Web Optimized**: Special optimizations for web platform

#### Testing
- **430+ Test Cases**: Comprehensive test coverage including:
  - Unit tests for all utilities and models
  - Widget tests for all views
  - Controller tests
  - Date/time edge cases
  - DST transition handling

### 🔧 Changed
- Complete API redesign for better consistency and usability
- Improved performance with viewport-based rendering
- Enhanced scroll synchronization algorithm
- Better gesture handling with conflict resolution
- Modernized codebase with latest Flutter best practices

### 🐛 Fixed
- DST transition issues in date calculations
- Scroll synchronization bugs in week view
- Appointment positioning edge cases with overlaps
- Memory leaks in controller disposal
- Context menu positioning issues
- Various rendering glitches on web platform

### 📚 Documentation
- New comprehensive README with quick start guide
- Detailed customization guide (CUSTOMIZATION_GUIDE.md)
- Complete features documentation (FEATURES.md)
- Project structure documentation (PROJECT_STRUCTURE.md)
- API reference with examples
- Migration guide from v1.x

### 🎯 Platform Support
- ✅ iOS
- ✅ Android  
- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux

### 📦 Requirements
- Flutter SDK: >= 3.0.0
- Dart SDK: >= 3.0.0

---

## [1.0.0] - 2024-XX-XX

### Added
- Initial major release with basic calendar functionality
- Day and Week views
- Basic appointment management
- Resource management
- Simple customization options

---

## [0.0.19] - 2024-XX-XX

### Fixed
- Week view builder issues
- Navigation between dates

---

## [0.0.18] - 2024-XX-XX

### Fixed
- Month view date generation
- Daylight saving time (DST) transition issues

---

## [0.0.17] - 2024-XX-XX

### Added
- All-day event support

---

## [0.0.16] - 2024-XX-XX

### Changed
- Updated README.md with better documentation

---

## [0.0.15] - 2024-XX-XX

### Added
- Multi-selection mode to calendar view

---

## [0.0.14] - 2024-XX-XX

### Added
- Events to calendar view

### Breaking Changes
- Modified event handling API

---

## [0.0.13] - 2024-XX-XX

### Added
- Right-click callback for calendar interactions

---

## [0.0.12] - 2024-XX-XX

### Added
- Border changed callback for day view

---

## [0.0.11] - 2024-XX-XX

### Fixed
- Large view rendering for calendar

---

## [0.0.9] - 2024-XX-XX

### Added
- Event builder for each calendar view type

---

## [0.0.7] - 2024-XX-XX

### Added
- Calendar customization support

---

## [0.0.6] - 2024-XX-XX

### Added
- Padding to day header

---

## [0.0.5] - 2024-XX-XX

### Added
- ID field to TyxEvent

---

## [0.0.4] - 2024-XX-XX

### Added
- Padding to day header

### Fixed
- onBorderChanged callback behavior

---

## [0.0.3] - 2024-XX-XX

### Added
- onBorderChanged callback

---

## [0.0.2] - 2024-XX-XX

### Added
- README.md documentation

---

## [0.0.1] - 2024-XX-XX

### Added
- Initial release with basic calendar functionality

---

## Links

- [Repository](https://github.com/loicgeek/timely_x_flutter)
- [Issue Tracker](https://github.com/loicgeek/timely_x_flutter/issues)
- [Documentation](https://github.com/loicgeek/timely_x_flutter#readme)