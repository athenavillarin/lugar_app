# Home Screen Code Organization

## Overview
The home screen code has been organized to reduce redundancy and improve maintainability by extracting common UI patterns into reusable constants and widgets.

## New Structure

### Constants
- **`constants/ui_constants.dart`** - Centralized UI constants for:
  - Border radius values (small: 2, medium: 12, large: 16, xlarge: 20, sheet: 24)
  - Common decorations (sheet, card, segment header)
  - Shadows (sheet, card)
  - Spacing and padding values
  - Icon sizes
  - Helper widgets (drag handle, timeline dots, progress lines)

### Reusable Widgets
- **`widgets/common_widgets.dart`** - Common UI components:
  - `SheetContainer` - Standardized sheet with drag handle
  - `CardContainer` - Reusable card with consistent decoration
  - `SegmentHeader` - Black header for segment cards
  - `BackButtonWidget` - Standardized back button

## Refactored Files

### 1. route_sheet.dart
**Changes:**
- Replaced hardcoded `BoxDecoration` with `UIConstants.sheetDecoration(theme)`
- Replaced drag handles with `UIConstants.dragHandle(primaryBlue)`
- Replaced border radius values with `UIConstants.borderRadiusLarge`

**Benefits:**
- Consistent sheet appearance across the app
- Easy to update all sheets by modifying one constant
- Reduced code duplication

### 2. widgets/route_card.dart
**Changes:**
- Replaced card decoration with `UIConstants.cardDecoration(theme, ...)`
- Replaced padding with `UIConstants.paddingXLarge`
- Replaced border radius with `UIConstants.borderRadiusLarge`

**Benefits:**
- Consistent card styling
- Centralized shadow and border management

### 3. route_detail_screen.dart
**Changes:**
- Replaced sheet decoration with `UIConstants.sheetDecoration(theme)`
- Replaced drag handle with `UIConstants.dragHandle(primaryBlue)`
- Replaced back button with `BackButtonWidget`
- Replaced card decorations with `UIConstants.cardDecoration(theme)`
- Replaced segment header with `SegmentHeader` widget

**Benefits:**
- Significantly reduced code (~70 lines saved per segment header alone)
- Easier to maintain segment headers
- Consistent styling across all detail screens

## Usage Examples

### Before (Redundant):
```dart
Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: theme.colorScheme.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: isSelected ? primaryBlue.withOpacity(0.3) : Colors.transparent,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: content,
)
```

### After (Clean):
```dart
Container(
  padding: UIConstants.paddingXLarge,
  decoration: UIConstants.cardDecoration(
    theme,
    selected: isSelected,
    primaryBlue: primaryBlue,
  ),
  child: content,
)
```

## Benefits of Organization

1. **Consistency**: All similar UI elements use the same values
2. **Maintainability**: Update one constant to change all instances
3. **Readability**: Less boilerplate, more focus on logic
4. **Reusability**: Common widgets can be used across different screens
5. **Scalability**: Easy to add new consistent UI elements

## Next Steps

To continue improving organization:

1. Extract more common patterns (e.g., timeline components, location input fields)
2. Consider creating a theme extension for custom colors
3. Move more complex widgets to separate files
4. Add documentation comments to all public constants and widgets
5. Consider creating a design system document

## File Locations

```
lib/screens/home/
├── constants/
│   └── ui_constants.dart          # UI constants and common decorations
├── widgets/
│   ├── common_widgets.dart        # Reusable UI components
│   ├── route_card.dart            # Refactored route card
│   ├── fare_type_toggle.dart      # (existing)
│   ├── location_suggestion_dropdown.dart  # (existing)
│   └── route_options_view.dart    # (existing)
├── home_screen.dart               # Main home screen
├── route_sheet.dart               # Refactored route sheet
├── route_detail_screen.dart       # Refactored route details
├── route_map_screen.dart          # Route map view
└── (other files...)
```
