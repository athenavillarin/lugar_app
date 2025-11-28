import 'package:flutter/material.dart';

/// Common UI constants and styling for home screen
class UIConstants {
  UIConstants._();

  // Border Radius Values
  static const double radiusSmall = 2.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusSheet = 24.0;

  // Common Border Radius
  static BorderRadius get borderRadiusSmall =>
      BorderRadius.circular(radiusSmall);
  static BorderRadius get borderRadiusMedium =>
      BorderRadius.circular(radiusMedium);
  static BorderRadius get borderRadiusLarge =>
      BorderRadius.circular(radiusLarge);
  static BorderRadius get borderRadiusXLarge =>
      BorderRadius.circular(radiusXLarge);
  static BorderRadius get borderRadiusSheet =>
      BorderRadius.circular(radiusSheet);

  // Sheet Border Radius (for top-only rounded corners)
  static BorderRadius get sheetTopBorderRadius => const BorderRadius.only(
        topLeft: Radius.circular(radiusSheet),
        topRight: Radius.circular(radiusSheet),
      );

  // Card Border Radius (for top-only rounded corners)
  static BorderRadius cardTopBorderRadius(double radius) => BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
      );

  // Shadows
  static List<BoxShadow> get sheetShadow => const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 10,
          offset: Offset(0, -2),
        ),
      ];

  static List<BoxShadow> cardShadow({double opacity = 0.05}) => [
        BoxShadow(
          color: Colors.black.withOpacity(opacity),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  // Common Decorations
  static BoxDecoration sheetDecoration(ThemeData theme) => BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: sheetTopBorderRadius,
        boxShadow: sheetShadow,
      );

  static BoxDecoration cardDecoration(
    ThemeData theme, {
    Color? borderColor,
    bool selected = false,
    Color? primaryBlue,
  }) =>
      BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: borderRadiusLarge,
        border: Border.all(
          color: selected && primaryBlue != null
              ? primaryBlue.withOpacity(0.3)
              : borderColor ?? Colors.transparent,
        ),
        boxShadow: cardShadow(),
      );

  static BoxDecoration segmentHeaderDecoration({
    required double radius,
  }) =>
      BoxDecoration(
        color: Colors.black87,
        borderRadius: cardTopBorderRadius(radius),
      );

  // Drag Handle
  static Widget dragHandle(Color primaryBlue) => Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: primaryBlue,
          borderRadius: borderRadiusSmall,
        ),
      );

  // Timeline Dot
  static Widget timelineDot({
    required Color primaryBlue,
    required bool isCheckpoint,
    double size = 16,
  }) =>
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: primaryBlue,
            width: 2,
          ),
        ),
        child: Center(
          child: Container(
            width: size * 0.375,
            height: size * 0.375,
            decoration: BoxDecoration(
              color: isCheckpoint ? Colors.white : primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );

  // Walking/Jeepney Timeline Progress Line (horizontal)
  static Widget timelineProgressLineHorizontal({
    required Color primaryBlue,
    double width = 32,
    bool isStart = true,
  }) =>
      Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isStart ? primaryBlue : Colors.white,
              shape: BoxShape.circle,
              border: isStart ? null : Border.all(color: primaryBlue),
            ),
          ),
          Container(
            width: width,
            height: 2,
            color: primaryBlue,
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isStart ? Colors.white : primaryBlue,
              shape: BoxShape.circle,
              border: isStart ? Border.all(color: primaryBlue) : null,
            ),
          ),
        ],
      );

  // Walking/Jeepney Timeline Progress Line (vertical)
  static Widget timelineProgressLineVertical({
    required Color primaryBlue,
    double height = 32,
    bool isStart = true,
  }) =>
      Column(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isStart ? primaryBlue : Colors.white,
              shape: BoxShape.circle,
              border: isStart ? null : Border.all(color: primaryBlue),
            ),
          ),
          Container(
            width: 2,
            height: height,
            color: primaryBlue,
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isStart ? Colors.white : primaryBlue,
              shape: BoxShape.circle,
              border: isStart ? Border.all(color: primaryBlue) : null,
            ),
          ),
        ],
      );

  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 20.0;
  static const double spacingXXLarge = 24.0;
  static const double spacingHuge = 32.0;
  static const double spacingXXXLarge = 40.0;

  // Padding
  static const EdgeInsets paddingSmall = EdgeInsets.all(spacingSmall);
  static const EdgeInsets paddingMedium = EdgeInsets.all(spacingMedium);
  static const EdgeInsets paddingLarge = EdgeInsets.all(spacingLarge);
  static const EdgeInsets paddingXLarge = EdgeInsets.all(spacingXLarge);
  static const EdgeInsets paddingXXLarge = EdgeInsets.all(spacingXXLarge);

  static const EdgeInsets paddingHorizontalSmall =
      EdgeInsets.symmetric(horizontal: spacingSmall);
  static const EdgeInsets paddingHorizontalMedium =
      EdgeInsets.symmetric(horizontal: spacingMedium);
  static const EdgeInsets paddingHorizontalLarge =
      EdgeInsets.symmetric(horizontal: spacingLarge);
  static const EdgeInsets paddingHorizontalXLarge =
      EdgeInsets.symmetric(horizontal: spacingXLarge);

  static const EdgeInsets paddingVerticalSmall =
      EdgeInsets.symmetric(vertical: spacingSmall);
  static const EdgeInsets paddingVerticalMedium =
      EdgeInsets.symmetric(vertical: spacingMedium);
  static const EdgeInsets paddingVerticalLarge =
      EdgeInsets.symmetric(vertical: spacingLarge);
  static const EdgeInsets paddingVerticalXLarge =
      EdgeInsets.symmetric(vertical: spacingXLarge);

  // Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 18.0;
  static const double iconSizeLarge = 24.0;
  static const double iconSizeXLarge = 56.0;

  // Button Height
  static const double buttonHeight = 49.0;
}
