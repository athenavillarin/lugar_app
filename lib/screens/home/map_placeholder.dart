import 'package:flutter/material.dart';

class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({
    super.key,
    required this.isSelectionMode,
    required this.onLocationSelected,
    required this.onCancel,
  });

  final bool isSelectionMode;
  final Function(String) onLocationSelected;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        if (isSelectionMode) {
          // Simulate selecting a location on the map
          // In real implementation, this would convert tap position to lat/lng
          onLocationSelected('Selected Location (Tap on map)');
        }
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F0F7), Color(0xFFF5F8FF)],
          ),
        ),
        child: Stack(
          children: [
            // Map placeholder content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelectionMode ? Icons.location_pin : Icons.map_outlined,
                    size: 80,
                    color: isSelectionMode
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isSelectionMode ? 'Tap to select location' : 'Map View',
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelectionMode
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSelectionMode
                        ? 'Tap anywhere on the map'
                        : 'Google Maps integration pending',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),

            // Cancel button when in selection mode
            if (isSelectionMode)
              Positioned(
                top: 48,
                left: 16,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  elevation: 2,
                  child: InkWell(
                    onTap: onCancel,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
