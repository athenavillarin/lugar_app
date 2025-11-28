import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/route_detail_screen.dart';
import '../models/route_option.dart';
import '../../providers/favorites_provider.dart';
import '../home/constants/ui_constants.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isInitialized = false;
  bool _showDeleteButtons = false;
  String _selectedLocation = '';
  bool _showLocationDropdown = false;
  List<String> _locations = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final provider = context.read<FavoritesProvider>();
    await provider.fetchFavorites();
    if (mounted) {
      final dests =
          provider.favorites
              .map((f) => f.destination)
              .where((d) => d.trim().isNotEmpty)
              .toSet()
              .toList()
            ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      setState(() {
        _locations = dests;
        if (_selectedLocation.isEmpty ||
            !_locations.contains(_selectedLocation)) {
          _selectedLocation = _locations.isNotEmpty ? _locations.first : '';
        }
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favoritesProvider = context.watch<FavoritesProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'FAVOURITES',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              setState(() {
                _showDeleteButtons = !_showDeleteButtons;
              });
            },
          ),
        ],
      ),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : favoritesProvider.favorites.isEmpty
          ? _buildEmptyState(theme)
          : RefreshIndicator(
              onRefresh: _loadFavorites,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildLocationRow(theme),
                        _buildLocationDropdown(theme),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...favoritesProvider.favorites
                      .where(
                        (fav) =>
                            _selectedLocation.isEmpty ||
                            fav.destination == _selectedLocation,
                      )
                      .map((fav) {
                        return FavoriteCard(
                          favorite: fav,
                          showDeleteButton: _showDeleteButtons,
                          onDelete: () async {
                            await favoritesProvider.deleteFavorite(fav.id);
                          },
                        );
                      }),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildLocationRow(ThemeData theme) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showLocationDropdown = !_showLocationDropdown;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: UIConstants.borderRadiusLarge,
        ),
        child: Row(
          children: [
            Text(
              'YOUR LOCATION',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (_selectedLocation.isEmpty ? 'Select' : _selectedLocation)
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  _showLocationDropdown ? Icons.expand_less : Icons.expand_more,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDropdown(ThemeData theme) {
    if (!_showLocationDropdown) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: UIConstants.borderRadiusLarge,
        boxShadow: UIConstants.cardShadow(opacity: 0.1),
      ),
      child: Column(
        children: _locations.map((location) {
          final isSelected = location == _selectedLocation;
          return InkWell(
            onTap: () {
              setState(() {
                _selectedLocation = location;
                _showLocationDropdown = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent,
                border: Border(
                  bottom: location != _locations.last
                      ? BorderSide(color: Colors.grey[200]!)
                      : BorderSide.none,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      location,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.black87,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_border,
              size: 64,
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No favourites yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the star on a route to save it here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoriteCard extends StatelessWidget {
  const FavoriteCard({
    super.key,
    required this.favorite,
    required this.showDeleteButton,
    required this.onDelete,
  });

  final FavoriteRoute favorite;
  final bool showDeleteButton;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryBlue = theme.colorScheme.primary;

    return Dismissible(
      key: Key(favorite.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: () async {
          try {
            // Use stored routePath if available, otherwise fetch from Firestore
            List<RoutePoint> routePath;
            if (favorite.routePath != null && favorite.routePath!.isNotEmpty) {
              routePath = favorite.routePath!
                  .map(
                    (p) => RoutePoint(
                      latitude: p['latitude']!,
                      longitude: p['longitude']!,
                    ),
                  )
                  .toList();
            } else {
              // Fallback: fetch from Firestore route document
              final doc = await FirebaseFirestore.instance
                  .collection('routes')
                  .doc(favorite.routeId)
                  .get();
              final data = doc.data();
              if (data == null) return;

              final dynamic routePathRaw = data['route_path'];
              if (routePathRaw is! List) return;
              final List<Map<String, dynamic>> routePathCoords = routePathRaw
                  .whereType<Map<String, dynamic>>()
                  .toList();
              if (routePathCoords.length < 2) return;

              routePath = routePathCoords
                  .map(
                    (pt) => RoutePoint(
                      latitude: (pt['latitude'] as num).toDouble(),
                      longitude: (pt['longitude'] as num).toDouble(),
                    ),
                  )
                  .toList();
            }

            // Build segments from stored data
            List<TransportSegment> segments;
            if (favorite.segments != null && favorite.segments!.isNotEmpty) {
              segments = favorite.segments!.map((s) {
                final type = s['type'] as String? ?? 'Jeepney';
                return TransportSegment(
                  icon: type.toLowerCase().contains('walk')
                      ? Icons.directions_walk
                      : Icons.directions_bus,
                  type: type,
                  startIndex: s['startIndex'] as int? ?? 0,
                  endIndex: s['endIndex'] as int? ?? routePath.length - 1,
                  durationMinutes:
                      s['durationMinutes'] as int? ?? favorite.durationMinutes,
                  getOnLabel: s['getOnLabel'] as String?,
                  getOffLabel: s['getOffLabel'] as String?,
                );
              }).toList();
            } else {
              // Fallback: create a simple segment
              segments = [
                TransportSegment(
                  icon: Icons.directions_bus,
                  type: 'Jeepney',
                  startIndex: 0,
                  endIndex: routePath.length - 1,
                  durationMinutes: favorite.durationMinutes,
                  getOnLabel: favorite.origin,
                  getOffLabel: favorite.destination,
                ),
              ];
            }

            // Build timeline
            final now = DateTime.now();
            DateTime cumulativeTime = now;
            final timeline = <TimelinePoint>[];

            for (int i = 0; i < segments.length; i++) {
              final segment = segments[i];
              if (i == 0) {
                timeline.add(
                  TimelinePoint(
                    label: segment.getOnLabel ?? favorite.origin,
                    time:
                        '${cumulativeTime.hour.toString().padLeft(2, '0')}:${cumulativeTime.minute.toString().padLeft(2, '0')}',
                  ),
                );
              }

              cumulativeTime = cumulativeTime.add(
                Duration(minutes: segment.durationMinutes),
              );

              if (i == segments.length - 1) {
                timeline.add(
                  TimelinePoint(
                    label: segment.getOffLabel ?? favorite.destination,
                    time:
                        '${cumulativeTime.hour.toString().padLeft(2, '0')}:${cumulativeTime.minute.toString().padLeft(2, '0')}',
                  ),
                );
              } else {
                timeline.add(
                  TimelinePoint(
                    label: segment.getOffLabel ?? 'Transfer',
                    time:
                        '${cumulativeTime.hour.toString().padLeft(2, '0')}:${cumulativeTime.minute.toString().padLeft(2, '0')}',
                  ),
                );
              }
            }

            final routeOption = RouteOption(
              routeId: favorite.routeId,
              routePath: routePath,
              duration: '${favorite.durationMinutes} mins',
              regularFare: favorite.price,
              discountedFare: favorite.price,
              segments: segments,
              timeline: timeline,
              price: favorite.price,
              startTime:
                  '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
              endTime:
                  '${cumulativeTime.hour.toString().padLeft(2, '0')}:${cumulativeTime.minute.toString().padLeft(2, '0')}',
              progress: 0.0,
              startLocation: favorite.origin,
              checkpointLocation: favorite.destination,
            );

            // Navigate to detail screen
            // ignore: use_build_context_synchronously
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    RouteDetailScreenClean(routeOption: routeOption),
              ),
            );
          } catch (e) {
            // Silently ignore for now; could add a SnackBar if desired
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: UIConstants.cardDecoration(theme),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: UIConstants.paddingXLarge,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLocationHeader(theme),
                        const SizedBox(height: 12),
                        _buildTopRow(primaryBlue),
                        const SizedBox(height: 24),
                        _buildTimeline(primaryBlue, theme),
                      ],
                    ),
                  ),
                ),
                if (showDeleteButton)
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      width: 69,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FE),
                        borderRadius: BorderRadius.only(
                          topRight: UIConstants.borderRadiusLarge.topRight,
                          bottomRight:
                              UIConstants.borderRadiusLarge.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/trash.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow(Color primaryBlue) {
    // Determine icons from checkpoints
    final hasWalk = favorite.checkpoints.length > 2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  text: '${favorite.durationMinutes}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2024),
                    fontFamily: 'Montserrat',
                  ),
                  children: const [
                    TextSpan(
                      text: ' mins',
                      style: TextStyle(
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_walk,
                      size: 16,
                      color: Color(0xFF1F2024),
                    ),
                  ),
                  if (hasWalk) const SizedBox(width: 8),
                  if (hasWalk)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_bus,
                        size: 16,
                        color: Color(0xFF1F2024),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'P ${favorite.price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }

  Widget _buildLocationHeader(ThemeData theme) {
    // Extract first significant word from location
    String getFirstWord(String location) {
      // Remove common prefixes
      String cleaned = location.trim();

      // Split by space or comma and get first meaningful word
      final words = cleaned.split(RegExp(r'[\s,]+'));
      if (words.isEmpty) return location;

      // Skip very short words like "to", "at", "in"
      for (final word in words) {
        if (word.length > 2) {
          return word;
        }
      }

      return words.first;
    }

    final shortOrigin = getFirstWord(favorite.origin);
    final shortDestination = getFirstWord(favorite.destination);

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
          color: Color(0xFF1F2024),
        ),
        children: [
          TextSpan(text: shortOrigin),
          TextSpan(
            text: ' → ',
            style: TextStyle(
              color: theme.hintColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(text: shortDestination),
        ],
      ),
    );
  }

  Widget _buildTimeline(Color primaryBlue, ThemeData theme) {
    // Get first word for destination display
    String getFirstWord(String location) {
      final words = location.trim().split(RegExp(r'[\s,]+'));
      if (words.isEmpty) return location;

      for (final word in words) {
        if (word.length > 2) return word;
      }

      return words.first;
    }

    // Calculate middle time from actual segment data if available
    int getMiddleTime() {
      if (favorite.segments != null && favorite.segments!.isNotEmpty) {
        // If we have segments, use the first segment's duration
        final firstSegmentDuration =
            favorite.segments!.first['durationMinutes'] as int? ?? 0;
        return firstSegmentDuration;
      }
      // Fallback: use 40% of total duration
      return (favorite.durationMinutes * 0.4).round();
    }

    // Always show exactly 3 points: Start → Jeepney → Destination
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal timeline with 3 dots and lines
        Row(
          children: [
            // Start dot
            Container(
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
                    color: primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            // Line
            Expanded(
              child: Container(
                height: 2,
                color: primaryBlue,
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
            // Jeepney dot
            Container(
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
                    color: primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            // Line
            Expanded(
              child: Container(
                height: 2,
                color: primaryBlue,
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
            // Destination dot
            Container(
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
                    color: primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Checkpoint labels with duration times
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: theme.hintColor,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.left,
                    maxLines: 1,
                  ),
                  Text(
                    '0 min',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.hintColor.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Jeepney',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: theme.hintColor,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                  Text(
                    '${getMiddleTime()} min',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.hintColor.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    getFirstWord(favorite.destination),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: theme.hintColor,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${favorite.durationMinutes} min',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.hintColor.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
