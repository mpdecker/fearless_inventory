import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../services/notification_service.dart';
import 'root_navigator.dart';
import '../../features/review/daily_review_hub_screen.dart';
import '../../features/stepwork/bedtime_meditation_screen.dart';

/// Routes the user from a local notification tap (foreground, background, or
/// cold start after [NotificationService.processPendingLaunchNotification]).
void navigateFromNotificationTap(NotificationResponse response) {
  final nav = rootNavigatorKey.currentState;
  if (nav == null) return;

  switch (response.id) {
    case NotificationService.idDailyReview:
      nav.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => const DailyReviewHubScreen(),
        ),
      );
      break;
    case NotificationService.idBedtimeMeditation:
      nav.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => const BedtimeMeditationScreen(),
        ),
      );
      break;
    default:
      break;
  }
}
