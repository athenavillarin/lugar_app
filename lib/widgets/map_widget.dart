import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapWidget extends StatefulWidget {
  final LatLng center;
  final double zoom;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final bool isSelectionMode;
  final Function(LatLng)? onLocationSelected;
  final VoidCallback? onCancel;

  const MapWidget({
    super.key,
    this.center = const LatLng(10.7202, 122.5621), // Iloilo City coordinates
    this.zoom = 13.0,
    this.markers = const [],
    this.polylines = const [],
    this.isSelectionMode = false,
    this.onLocationSelected,
    this.onCancel,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  LatLng? selectedLocation;

  @override
  Widget build(BuildContext context) {
    // Create markers list with selected location if in selection mode
    List<Marker> displayMarkers = List.from(widget.markers);

    if (widget.isSelectionMode && selectedLocation != null) {
      displayMarkers.add(
        Marker(
          point: selectedLocation!,
          width: 40,
          height: 40,
          child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
        ),
      );
    }
    // No default marker - only show markers when explicitly provided or in selection mode

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: widget.center,
            initialZoom: widget.zoom,
            onTap: widget.isSelectionMode
                ? (tapPosition, latLng) {
                    setState(() {
                      selectedLocation = latLng;
                    });
                    widget.onLocationSelected?.call(latLng);
                  }
                : null,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.lugar_app',
            ),
            MarkerLayer(markers: displayMarkers),
            if (widget.polylines.isNotEmpty)
              PolylineLayer(polylines: widget.polylines),
          ],
        ),

        // Selection mode overlay
        if (widget.isSelectionMode)
          Positioned(
            top: 48,
            left: 16,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 4,
              child: InkWell(
                onTap: widget.onCancel,
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

        // Instruction text for selection mode
        if (widget.isSelectionMode && selectedLocation == null)
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Tap on the map to select location',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
