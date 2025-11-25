import 'package:flutter/material.dart';

enum FareType { regular, discounted }

class RouteOption {
  final String routeId;
  final List<RoutePoint> routePath;
  final String duration;
  final double regularFare;
  final double discountedFare;
  final List<TransportSegment> segments;
  final List<TimelinePoint> timeline;

  const RouteOption({
    required this.routeId,
    required this.routePath,
    required this.duration,
    required this.regularFare,
    required this.discountedFare,
    required this.segments,
    required this.timeline,
  });
}

class RoutePoint {
  final double latitude;
  final double longitude;
  const RoutePoint({required this.latitude, required this.longitude});
}

class TransportSegment {
  final IconData icon;
  final String type;

  const TransportSegment({required this.icon, required this.type});
}

class TimelinePoint {
  final String label;
  final String time;
  final bool isCheckpoint;

  const TimelinePoint({
    required this.label,
    required this.time,
    this.isCheckpoint = false,
  });
}
