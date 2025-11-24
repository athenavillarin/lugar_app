import 'package:flutter/material.dart';

class LocationSuggestion {
  final String name;
  final String address;

  const LocationSuggestion({required this.name, required this.address});
}

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
    // Calculate actual height needed
    final double itemHeight = 68; // Approximate height per item
    final double headerHeight = 48; // "Choose on the map" button
    final double contentHeight =
        headerHeight + (suggestions.length * itemHeight);
    final double actualHeight = contentHeight > 250 ? 250 : contentHeight;

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
            // Choose on map option (fixed at top)
            InkWell(
              onTap: () {
                print('Choose on map tapped'); // Debug
                onChooseOnMap();
              },
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE0E3EB), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
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

            // Location suggestions (scrollable)
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  final isLast = index == suggestions.length - 1;

                  return InkWell(
                    onTap: () {
                      print('Location tapped: ${suggestion.name}'); // Debug
                      onSelectLocation(suggestion);
                    },
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
                                bottom: BorderSide(
                                  color: Color(0xFFE0E3EB),
                                  width: 1,
                                ),
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
