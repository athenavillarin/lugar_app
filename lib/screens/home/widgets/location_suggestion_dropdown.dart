import 'package:flutter/material.dart';
import '../../models/location_suggestion.dart';

class LocationSuggestionDropdown extends StatelessWidget {
  const LocationSuggestionDropdown({
    super.key,
    required this.suggestions,
    required this.onSelectLocation,
    required this.onChooseOnMap,
  });

  final List<LocationSuggestion> suggestions;
  final Function(LocationSuggestion) onSelectLocation;
  final VoidCallback onChooseOnMap;

  @override
  Widget build(BuildContext context) {
    final double itemHeight = 68;
    final double headerHeight = 48;
    final double contentHeight =
        headerHeight + ((suggestions.length + 2) * itemHeight);
    final double actualHeight = contentHeight > 320 ? 320 : contentHeight;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        height: actualHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Your location option
            InkWell(
              onTap: () => onSelectLocation(
                LocationSuggestion(name: 'Your location', address: ''),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE0E3EB))),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.my_location,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Your location',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Choose on the map option
            InkWell(
              onTap: onChooseOnMap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE0E3EB))),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.map_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Choose on the map',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Divider
            const Divider(height: 1, color: Color(0xFFE0E3EB)),
            // Suggestions list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  final isLast = index == suggestions.length - 1;
                  return InkWell(
                    onTap: () => onSelectLocation(suggestion),
                    borderRadius: isLast
                        ? const BorderRadius.vertical(
                            bottom: Radius.circular(12),
                          )
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: isLast
                            ? null
                            : const Border(
                                bottom: BorderSide(color: Color(0xFFE0E3EB)),
                              ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFF6B7280),
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  suggestion.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2024),
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  suggestion.address,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF6B7280),
                                    fontFamily: 'Montserrat',
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
