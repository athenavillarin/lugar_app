import 'package:flutter/material.dart';
import '../models/route_option.dart';
import 'route_map_screen.dart';

class RouteDetailScreen extends StatelessWidget {
  final RouteOption routeOption;
  const RouteDetailScreen({super.key, required this.routeOption});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final textColor = theme.textTheme.bodyMedium?.color;
    final card = theme.cardColor;
    final background = theme.scaffoldBackgroundColor;

    final fare = routeOption.regularFare;
    final timeline = routeOption.timeline;
    final segments = routeOption.segments;

    return Scaffold(
      appBar: AppBar(leading: BackButton()),
      backgroundColor: background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'P ${fare.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: timeline
                          .map(
                            (t) => Column(
                              children: [
                                Icon(
                                  t.isCheckpoint
                                      ? Icons.directions_bus
                                      : Icons.directions_walk,
                                  color: primary,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  t.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  t.time,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: textColor?.withOpacity(.6),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              ...segments.map((segment) {
                final isWalk = segment.type.toLowerCase().contains('walk');
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(segment.icon, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              isWalk
                                  ? 'Walk (375m) 5 min'
                                  : 'Jeep (2km) P 15.00   15 mins',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: isWalk
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Lorem ipsum',
                                    style: TextStyle(color: textColor),
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: 1,
                                      min: 0,
                                      max: 1,
                                      onChanged: null,
                                      activeColor: primary,
                                      inactiveColor: primary.withOpacity(.3),
                                    ),
                                  ),
                                  Text(
                                    'GT Mall Pavia',
                                    style: TextStyle(color: textColor),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.swap_vert, color: primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        'ROUTE',
                                        style: TextStyle(color: textColor),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Ungka to City Proper via CPU',
                                          style: TextStyle(color: textColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.radio_button_checked,
                                        color: primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'GET ON',
                                        style: TextStyle(color: textColor),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'GT Mall Pavia',
                                          style: TextStyle(color: textColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.radio_button_unchecked,
                                        color: primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'GET OFF',
                                        style: TextStyle(color: textColor),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Jaro Plaza',
                                          style: TextStyle(color: textColor),
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
              }),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            RouteMapScreen(routeOption: routeOption),
                      ),
                    );
                  },
                  child: const Text('See Map'),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Find new route',
                    style: TextStyle(color: primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
