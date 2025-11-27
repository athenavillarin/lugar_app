import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/route_option.dart';
import '../../widgets/map_widget.dart';

class RouteDetailScreenClean extends StatefulWidget {
  final RouteOption routeOption;

  const RouteDetailScreenClean({super.key, required this.routeOption});

  @override
  State<RouteDetailScreenClean> createState() => _RouteDetailScreenCleanState();
}

class _RouteDetailScreenCleanState extends State<RouteDetailScreenClean> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  String? _routeName;
  bool _loadingRouteName = true;
  bool _isFavorite = false;
  String? _routeDescription;

  @override
  void initState() {
    super.initState();
    _fetchRouteName();
    _checkFavorite();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> _fetchRouteName() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('routes')
          .doc(widget.routeOption.routeId)
          .get();

      final data = doc.data();
      final name = data?['name'] as String?;
      final jeepneySignage = data?['jeepney_signage'] as String?;

      setState(() {
        _routeName = name ?? 'Route ${widget.routeOption.routeId}';
        _routeDescription = jeepneySignage; // may be null
        _loadingRouteName = false;
      });
    } catch (_) {
      setState(() {
        _routeName = 'Route ${widget.routeOption.routeId}';
        _routeDescription = null;
        _loadingRouteName = false;
      });
    }
  }

  Future<void> _checkFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(widget.routeOption.routeId)
            .get();

        setState(() => _isFavorite = doc.exists);
      } catch (_) {}
    } else {
      // Check local storage for guests
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList('guest_favorites') ?? [];
      setState(
        () => _isFavorite = favorites.contains(widget.routeOption.routeId),
      );
    }
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isFavorite = !_isFavorite);

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(widget.routeOption.routeId);

    try {
      if (_isFavorite) {
        // Parse duration
        final durationMatch = RegExp(
          r'(\d+)',
        ).firstMatch(widget.routeOption.duration);
        final durationMinutes = durationMatch != null
            ? int.parse(durationMatch.group(1)!)
            : 30;

        // Extract checkpoints from timeline
        final checkpoints = widget.routeOption.timeline
            .map((t) => t.label)
            .toList();

        await ref.set({
          'title': _routeName ?? 'Route ${widget.routeOption.routeId}',
          'durationMinutes': durationMinutes,
          'price': widget.routeOption.regularFare,
          'checkpoints': checkpoints,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await ref.delete();
      }
    } catch (_) {
      // revert UI state on error
      setState(() => _isFavorite = !_isFavorite);
    }
  }

  void _minimizeSheet() {
    _sheetController.animateTo(
      0.15,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryBlue = theme.colorScheme.primary;

    // Prepare route points
    final List<LatLng> routePoints = widget.routeOption.routePath
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    // Segment-based polylines and markers
    final List<Polyline> polylines = [];
    final List<Marker> markers = [];
    if (routePoints.isNotEmpty && widget.routeOption.segments.isNotEmpty) {
      for (final segment in widget.routeOption.segments) {
        // Defensive: clamp indices
        int startIdx = segment.startIndex.clamp(0, routePoints.length - 1);
        int endIdx = segment.endIndex.clamp(0, routePoints.length - 1);
        if (startIdx > endIdx) {
          final tmp = startIdx;
          startIdx = endIdx;
          endIdx = tmp;
        }
        // Only add walking marker/polyline if segment covers more than one point
        final isWalk = segment.type.toLowerCase().contains('walk');
        if (!isWalk || startIdx != endIdx) {
          // Polyline for this segment
          final segPoints = routePoints.sublist(startIdx, endIdx + 1);
          polylines.add(
            Polyline(
              points: segPoints,
              color: theme.colorScheme.primary,
              strokeWidth: 4.0,
              isDotted: isWalk,
            ),
          );
          // Marker at start of segment
          String iconPath = isWalk
              ? 'assets/icons/map_walking.png'
              : 'assets/icons/map_jeepney.png';
          markers.add(
            Marker(
              point: routePoints[startIdx],
              width: 32,
              height: 32,
              child: Image.asset(iconPath, width: 32, height: 32),
            ),
          );
        }
      }
      // Always add a marker at the end
      markers.add(
        Marker(
          point: routePoints.last,
          width: 32,
          height: 32,
          child: const Icon(Icons.location_on, color: Colors.red, size: 32),
        ),
      );
    }
    final LatLng center = routePoints.isNotEmpty
        ? routePoints.first
        : const LatLng(10.7202, 122.5621);

    final timelineTimes = widget.routeOption.timeline
        .map(
          (p) => Expanded(
            child: Text(
              p.time,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        )
        .toList();

    final timelineDots = widget.routeOption.timeline
        .map(
          (p) => const Expanded(child: Column(children: [SizedBox(height: 6)])),
        )
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          MapWidget(center: center, polylines: polylines, markers: markers),

          /// Draggable Sheet
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.6,
            minChildSize: 0.15,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    /// Drag handle
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

                    /// Back button
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(),
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),

                    /// Main content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Route Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'P ${widget.routeOption.regularFare.toStringAsFixed(2)}',
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _loadingRouteName
                                          ? 'Loading...'
                                          : (_routeName ??
                                                'Route ${widget.routeOption.routeId}'),
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                if (widget.routeOption.timeline.isNotEmpty) ...[
                                  Row(children: timelineTimes),
                                  const SizedBox(height: 8),
                                  Row(children: timelineDots),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// Segments
                          Column(
                            children: widget.routeOption.segments.map((
                              segment,
                            ) {
                              final isWalk = segment.type
                                  .toLowerCase()
                                  .contains('walk');
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Segment Header
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                segment.icon,
                                                color:
                                                    theme.colorScheme.onPrimary,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                segment.type,
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .onPrimary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              if (!isWalk)
                                                Text(
                                                  'P ${widget.routeOption.regularFare.toStringAsFixed(0)}',
                                                  style: theme
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                        color: theme
                                                            .colorScheme
                                                            .onPrimary,
                                                      ),
                                                ),
                                              if (!isWalk)
                                                const SizedBox(width: 12),
                                              Text(
                                                '${segment.durationMinutes} min',
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .onPrimary,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Segment Body
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: isWalk
                                          ? Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    segment.getOnLabel ??
                                                        'Start',
                                                    style: theme
                                                        .textTheme
                                                        .bodyMedium,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                // Horizontal line with circles for walk
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 12,
                                                      height: 12,
                                                      decoration: BoxDecoration(
                                                        color: primaryBlue,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 32,
                                                      height: 2,
                                                      color: primaryBlue,
                                                    ),
                                                    Container(
                                                      width: 12,
                                                      height: 12,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: primaryBlue,
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    segment.getOffLabel ??
                                                        'Route',
                                                    textAlign: TextAlign.right,
                                                    style: theme
                                                        .textTheme
                                                        .bodyMedium,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.alt_route,
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        _routeDescription !=
                                                                    null &&
                                                                _routeDescription!
                                                                    .isNotEmpty
                                                            ? _routeDescription!
                                                            : 'Route',
                                                        style: theme
                                                            .textTheme
                                                            .bodyMedium,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Container(
                                                          width: 12,
                                                          height: 12,
                                                          decoration:
                                                              BoxDecoration(
                                                                color:
                                                                    primaryBlue,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                        ),
                                                        Container(
                                                          width: 2,
                                                          height: 32,
                                                          color: primaryBlue,
                                                        ),
                                                        Container(
                                                          width: 12,
                                                          height: 12,
                                                          decoration: BoxDecoration(
                                                            border: Border.all(
                                                              color:
                                                                  primaryBlue,
                                                            ),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            segment.getOnLabel ??
                                                                'Get On',
                                                            style: theme
                                                                .textTheme
                                                                .bodyLarge,
                                                          ),
                                                          const SizedBox(
                                                            height: 32,
                                                          ),
                                                          Text(
                                                            segment.getOffLabel ??
                                                                'Get Off',
                                                            style: theme
                                                                .textTheme
                                                                .bodyLarge,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),

                    /// Bottom Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 49,
                                  child: ElevatedButton(
                                    onPressed: _minimizeSheet,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryBlue,
                                      foregroundColor:
                                          theme.colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'See Map',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: _isFavorite
                                    ? Image.asset(
                                        'assets/icons/star_enabled.png',
                                        width: 24,
                                        height: 24,
                                      )
                                    : Image.asset(
                                        'assets/icons/star.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                onPressed: _toggleFavorite,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Find new route button (centered, styled as a TextButton)
                          Center(
                            child: TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop('find_new_route'),
                              child: Text(
                                'Find new route',
                                style: TextStyle(
                                  color: primaryBlue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
