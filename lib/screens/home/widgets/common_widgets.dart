import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';

/// Reusable sheet container with standard decoration
class SheetContainer extends StatelessWidget {
  final Widget child;
  final ScrollController? scrollController;

  const SheetContainer({super.key, required this.child, this.scrollController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Column(
      children: [
        Center(child: UIConstants.dragHandle(theme.colorScheme.primary)),
        Expanded(child: child),
      ],
    );

    return Container(
      decoration: UIConstants.sheetDecoration(theme),
      child: scrollController != null
          ? ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
              children: [content],
            )
          : content,
    );
  }
}

/// Reusable card container with standard decoration
class CardContainer extends StatelessWidget {
  final Widget child;
  final bool selected;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  const CardContainer({
    super.key,
    required this.child,
    this.selected = false,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryBlue = theme.colorScheme.primary;

    final container = Container(
      padding: padding ?? UIConstants.paddingXLarge,
      decoration: UIConstants.cardDecoration(
        theme,
        selected: selected,
        primaryBlue: primaryBlue,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: UIConstants.borderRadiusLarge,
        child: container,
      );
    }

    return container;
  }
}

/// Segment card header (black background with icon and info)
class SegmentHeader extends StatelessWidget {
  final IconData icon;
  final String type;
  final String? fare;
  final String duration;

  const SegmentHeader({
    super.key,
    required this.icon,
    required this.type,
    this.fare,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingMedium,
        vertical: 10,
      ),
      decoration: UIConstants.segmentHeaderDecoration(
        radius: UIConstants.radiusLarge,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: theme.colorScheme.onPrimary,
                size: UIConstants.iconSizeMedium,
              ),
              const SizedBox(width: UIConstants.spacingSmall),
              Text(
                type,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (fare != null) ...[
                Text(
                  fare!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: UIConstants.spacingMedium),
              ],
              Text(
                duration,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Back button with standard styling
class BackButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;

  const BackButtonWidget({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(
        left: UIConstants.spacingXLarge,
        top: UIConstants.spacingSmall,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onPressed ?? () => Navigator.of(context).pop(),
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
