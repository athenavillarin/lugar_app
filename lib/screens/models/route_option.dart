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
  final double price;
  final String? startTime;
  final String? endTime;
  final double progress;
  final String? startLocation;
  final String? checkpointLocation;

  const RouteOption({
    required this.routeId,
    required this.routePath,
    required this.duration,
    required this.regularFare,
    required this.discountedFare,
    required this.segments,
    required this.timeline,
    required this.price,
    this.startTime,
    this.endTime,
    required this.progress,
    this.startLocation,
    this.checkpointLocation,
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
  final int startIndex;
  final int endIndex;

  final int durationMinutes;
  final String? getOnLabel;
  final String? getOffLabel;

  const TransportSegment({
    required this.icon,
    required this.type,
    required this.startIndex,
    required this.endIndex,
    required this.durationMinutes,
    this.getOnLabel,
    this.getOffLabel,
  });
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
