import 'package:flutter/material.dart';
import '../../models/route_option.dart';
import '../constants/ui_constants.dart';

class RouteCard extends StatelessWidget {
  final RouteOption route;
  final FareType fareType;
  final bool isSelected;
  final Color primaryBlue;
  final VoidCallback? onTap;

  const RouteCard({
    super.key,
    required this.route,
    required this.fareType,
    required this.isSelected,
    required this.primaryBlue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fare = fareType == FareType.regular
        ? route.regularFare
        : route.discountedFare;

    return InkWell(
      onTap: onTap,
      borderRadius: UIConstants.borderRadiusLarge,
      child: Container(
        padding: UIConstants.paddingXLarge,
        decoration: UIConstants.cardDecoration(
          theme,
          selected: isSelected,
          primaryBlue: primaryBlue,
        ),
        child: Column(
          children: [
            _buildTopRow(fare),
            const SizedBox(height: 24),
            _buildTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow(double fare) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            RichText(
              text: TextSpan(
                text: route.duration.split(' ')[0], // Extract the number
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2024),
                  fontFamily: 'Montserrat',
                ),
                children: [
                  TextSpan(
                    text: ' mins', // Extract the unit
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2024),
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Row(
              children: route.segments
                  .where((segment) {
                    final isWalk = segment.type.toLowerCase().contains('walk');
                    // Only show walking if it covers more than one point
                    return !isWalk || segment.startIndex != segment.endIndex;
                  })
                  .map((segment) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        segment.icon,
                        size: 16,
                        color: const Color(0xFF1F2024),
                      ),
                    );
                  })
                  .toList(),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₱ ${fare.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2024),
                fontFamily: 'Montserrat',
              ),
            ),
            if (fareType == FareType.discounted)
              Text(
                'Discounted',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Filter timeline points to match filtered segments logic
        final timeline = route.timeline;
        final segments = route.segments;
        List<int> validTimelineIndexes = [];
        if (timeline.isNotEmpty) {
          validTimelineIndexes.add(0); // Always show first point
          for (int i = 1; i < timeline.length - 1; i++) {
            // Find the segment that starts at this timeline index
            final seg = segments.length > i - 1 ? segments[i - 1] : null;
            final isWalk =
                seg != null && seg.type.toLowerCase().contains('walk');
            if (!isWalk || (seg != null && seg.startIndex != seg.endIndex)) {
              validTimelineIndexes.add(i);
            }
          }
          if (timeline.length > 1)
            validTimelineIndexes.add(
              timeline.length - 1,
            ); // Always show last point
        }
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 7,
              left: 10,
              right: 10,
              child: Container(height: 2, color: primaryBlue),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: validTimelineIndexes.map((i) {
                final point = timeline[i];
                return Column(
                  children: [
                    _buildTimelineDot(point),
                    const SizedBox(height: 8),
                    Text(
                      point.label,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      point.time,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimelineDot(TimelinePoint point) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: primaryBlue, width: 2),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: point.isCheckpoint ? Colors.white : primaryBlue,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
