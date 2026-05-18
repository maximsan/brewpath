import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:coffee_quest/services/analytics/analytics_service.dart';

part 'analytics_provider.g.dart';

@riverpod
AnalyticsService analyticsService(Ref ref) =>
    const NoOpAnalyticsService();
