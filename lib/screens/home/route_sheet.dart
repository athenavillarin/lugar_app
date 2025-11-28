import 'package:flutter/material.dart';
import '../models/location_suggestion.dart';
import '../models/route_option.dart';
import 'route_detail_screen.dart';
import 'widgets/fare_type_toggle.dart';
import 'widgets/location_suggestion_dropdown.dart';
import 'widgets/route_card.dart';

class RouteSheet extends StatelessWidget {
  const RouteSheet({
    super.key,
    required this.fromController,
    required this.toController,
    required this.fromFocusNode,
    required this.toFocusNode,
    required this.isFormValid,
    required this.onSwap,
    required this.onFindRoute,
    required this.fromSuggestions,
    required this.toSuggestions,
    required this.showFromDropdown,
    required this.showToDropdown,
    required this.onSelectFromLocation,
    required this.onSelectToLocation,
    required this.onChooseOnMapFrom,
    required this.onChooseOnMapTo,
    required this.isMapSelectionMode,
    required this.showResults,
    required this.routeOptions,
    required this.selectedFareType,
    required this.onFareTypeChanged,
    required this.sheetController,
    required this.onFindNewRoute,
  });
  final VoidCallback onFindNewRoute;

  final TextEditingController fromController;
  final TextEditingController toController;
  final FocusNode fromFocusNode;
  final FocusNode toFocusNode;
  final bool isFormValid;
  final VoidCallback onSwap;
  final VoidCallback onFindRoute;
  final List<LocationSuggestion> fromSuggestions;
  final List<LocationSuggestion> toSuggestions;
  final bool showFromDropdown;
  final bool showToDropdown;
  final Function(LocationSuggestion) onSelectFromLocation;
  final Function(LocationSuggestion) onSelectToLocation;
  final VoidCallback onChooseOnMapFrom;
  final VoidCallback onChooseOnMapTo;
  final bool isMapSelectionMode;
  final bool showResults;
  final List<RouteOption> routeOptions;
  final FareType selectedFareType;
  final Function(FareType) onFareTypeChanged;

  final DraggableScrollableController sheetController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryBlue = theme.colorScheme.primary;
    print(
      'DEBUG: RouteSheet build called, routeOptions.length = [33m${routeOptions.length}[0m, showResults = $showResults',
    );

    // Minimize sheet when in map selection mode
    if (isMapSelectionMode) {
      return DraggableScrollableSheet(
        initialChildSize: 0.15,
        minChildSize: 0.15,
        maxChildSize: 0.15,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'Select location on map',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return DraggableScrollableSheet(
      controller: sheetController,
      initialChildSize: showResults ? 0.6 : 0.45,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Stack(
            children: [
              ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Title(),
                        const SizedBox(height: 24),
                        _InputForm(
                          primaryBlue: primaryBlue,
                          fromController: fromController,
                          toController: toController,
                          fromFocusNode: fromFocusNode,
                          toFocusNode: toFocusNode,
                          onSwap: onSwap,
                        ),
                        const SizedBox(height: 20),
                        if (!showResults)
                          _FindRouteButton(
                            primaryBlue: primaryBlue,
                            isEnabled: isFormValid,
                            onPressed: onFindRoute,
                          )
                        else ...[
                          FareTypeToggle(
                            selectedType: selectedFareType,
                            onChanged: onFareTypeChanged,
                            primaryBlue: primaryBlue,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Choose your route',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Route cards
                          Column(
                            children: routeOptions.isNotEmpty
                                ? routeOptions.map((route) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16.0,
                                      ), // Add spacing between route options
                                      child: RouteCard(
                                        route: route,
                                        fareType: selectedFareType,
                                        isSelected:
                                            false, // You can implement selection logic
                                        primaryBlue: primaryBlue,
                                        onTap: () async {
                                          final result =
                                              await Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      RouteDetailScreenClean(
                                                        routeOption: route,
                                                      ),
                                                ),
                                              );
                                          if (result == 'find_new_route') {
                                            onFindNewRoute();
                                          }
                                        },
                                      ),
                                    );
                                  }).toList()
                                : [
                                    // Placeholder when no routes
                                    Container(
                                      height: 120,
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        color: theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Center(
                                        child: Text('No routes found'),
                                      ),
                                    ),
                                  ],
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),

              // Dropdown overlays - positioned directly below input form
              if (showFromDropdown)
                Positioned(
                  top: 220, // Adjust as needed for your layout
                  left: 24,
                  right: 24,
                  child: LocationSuggestionDropdown(
                    suggestions: fromSuggestions,
                    onSelectLocation: onSelectFromLocation,
                    onChooseOnMap: onChooseOnMapFrom,
                  ),
                ),
              if (showToDropdown)
                Positioned(
                  top: 308, // Place below the 'To' field (adjust as needed)
                  left: 24,
                  right: 24,
                  child: LocationSuggestionDropdown(
                    suggestions: toSuggestions,
                    onSelectLocation: onSelectToLocation,
                    onChooseOnMap: onChooseOnMapTo,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 24,
          height: 1.3,
          color: Color(0xFF1F2024),
          fontFamily: 'Montserrat',
        ),
        children: [
          TextSpan(
            text: 'WHERE WOULD YOU\nLIKE TO GO ',
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
          TextSpan(
            text: 'TODAY?',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _InputForm extends StatelessWidget {
  const _InputForm({
    required this.primaryBlue,
    required this.fromController,
    required this.toController,
    required this.fromFocusNode,
    required this.toFocusNode,
    required this.onSwap,
  });

  final Color primaryBlue;
  final TextEditingController fromController;
  final TextEditingController toController;
  final FocusNode fromFocusNode;
  final FocusNode toFocusNode;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryBlue, width: 2),
                  color: primaryBlue,
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Column(
                children: List.generate(
                  5,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    width: 2,
                    height: 4,
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryBlue, width: 2),
                  color: Colors.transparent,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                _InputField(
                  label: 'From',
                  placeholder: 'Your Location',
                  controller: fromController,
                  focusNode: fromFocusNode,
                ),
                const SizedBox(height: 20),
                _InputField(
                  label: 'To',
                  placeholder: 'Your Destination',
                  controller: toController,
                  focusNode: toFocusNode,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: onSwap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryBlue, width: 1.5),
                color: Colors.white,
              ),
              child: Icon(Icons.swap_vert, color: primaryBlue, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.focusNode,
  });

  final String label;
  final String placeholder;
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          focusNode: focusNode,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2024),
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey[400],
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

class _FindRouteButton extends StatelessWidget {
  const _FindRouteButton({
    required this.primaryBlue,
    required this.isEnabled,
    required this.onPressed,
  });

  final Color primaryBlue;
  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 49,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primaryBlue.withOpacity(0.5),
          disabledForegroundColor: Colors.white.withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Find Route',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }
}
