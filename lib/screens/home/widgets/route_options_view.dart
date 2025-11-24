import 'package:flutter/material.dart';
import '../../models/route_option.dart';
import 'fare_type_toggle.dart';
import 'route_card.dart';

class RouteOptionsView extends StatelessWidget {
  const RouteOptionsView({
    super.key,
    required this.routeOptions,
    required this.selectedFareType,
    required this.onFareTypeChanged,
    required this.primaryBlue,
  });

  final List<RouteOption> routeOptions;
  final FareType selectedFareType;
  final Function(FareType) onFareTypeChanged;
  final Color primaryBlue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FareTypeToggle(
          selectedType: selectedFareType,
          onChanged: onFareTypeChanged,
          primaryBlue: primaryBlue,
        ),
        const SizedBox(height: 20),
        ...routeOptions.map(
          (route) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: RouteCard(
              route: route,
              fareType: selectedFareType,
              isSelected: false, // This can be managed in the parent state
              primaryBlue: primaryBlue,
            ),
          ),
        ),
      ],
    );
  }
}
