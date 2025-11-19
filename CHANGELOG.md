# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned Features
- All-day events section
- Recurring appointments
- Export to iCal/CSV
- Timezone support
- Agenda view
- Resource grouping and filtering

## [1.0.0] - 2025-11-18

### Added - Major Release 🎉

#### Core Features
- **Multiple view types**: Day, Week, and Month views
- **Multi-resource support**: Display appointments across multiple resources (people, rooms, equipment)
- **Rich interactions**: 
  - Tap, long-press, and secondary tap on appointments
  - Cell tap and long press for creating appointments
  - Header interactions for resources and dates
- **Drag and drop**: Full drag and drop support with snap-to-grid
- **Appointment resizing**: Resize appointments to change duration
- **Overlap handling**: Intelligent positioning of overlapping appointments
- **Current time indicator**: Real-time line showing current time
- **Weekend highlighting**: Visual distinction for weekend days

#### Customization (65+ Theme Properties)
- **16 color properties**: Complete color customization including weekends, highlights, backgrounds
- **10 text style properties**: Full typography control for all text elements
- **6 date format properties**: Flexible date/time formatting for any locale
- **7 spacing properties**: Control all padding, margins, and sizing
- **8 month view properties**: Dedicated month view customization
- **3 decoration properties**: Border radius, shadows for appointments and headers
- **4 drag & drop properties**: Customize drag feedback appearance

#### Layouts
- **Resources-first layout**: Group by resource, then days
- **Days-first layout**: Group by day, then resources
- **Responsive design**: Automatic adaptation to screen sizes
- **Flexible column sizing**: Min, max, and preferred widths

#### Developer Features
- **Custom builders**: Replace any widget with custom implementation
  - Resource headers
  - Date headers
  - Time column
  - Appointments
  - Empty cells
  - Current time indicator
- **Event callbacks**: 
  - Appointment interactions (tap, long-press, secondary tap)
  - Cell interactions
  - Drag end
  - Header taps
- **State management**: Powerful controller with full CRUD operations
- **Conflict detection**: Check time slot availability
- **Type-safe**: Extend base classes for custom models

#### Documentation
- Comprehensive README with examples
- Complete customization guide
- Quick reference cheat sheet
- Migration guide
- Contributing guidelines
- API documentation

### Technical Details
- **Performance optimized**: Efficient rendering and scroll synchronization
- **Well tested**: Comprehensive unit and widget tests
- **Type safe**: Full type safety with abstract base classes
- **Clean architecture**: Separation of concerns, modular design
- **Zero dependencies**: Only requires Flutter SDK and intl package

### Supported Platforms
- ✅ iOS
- ✅ Android
- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux

### Requirements
- Flutter >= 3.0.0
- Dart >= 3.0.0

## [0.9.0] - 2025-11-10 (Beta)

### Added
- Beta release with core features
- Day and Week views
- Basic customization
- Appointment management
- Resource management

### Known Issues
- Month view incomplete
- Limited theming options
- No drag and drop

## [0.5.0] - 2025-10-15 (Alpha)

### Added
- Alpha release
- Basic calendar grid
- Simple appointment display
- Proof of concept

---

## Version History Summary

| Version | Date | Description |
|---------|------|-------------|
| 1.0.0 | 2025-11-18 | Major release with complete features |
| 0.9.0 | 2025-11-10 | Beta release |
| 0.5.0 | 2025-10-15 | Alpha release |

## Upgrade Guide

### Upgrading to 1.0.0

**From 0.9.0:**

No breaking changes! Update your `pubspec.yaml`:

```yaml
dependencies:
  flutter_resource_calendar: ^1.0.0
```

New features available:
- Full theme customization (65+ properties)
- Month view
- Drag and drop
- Custom builders
- Enhanced callbacks

See [MIGRATION_GUIDE.md](docs/MIGRATION_GUIDE.md) for details on new features.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to contribute to this project.

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.