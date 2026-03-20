import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'core/database/database.dart';
import 'core/services/notification_service.dart'; // Import the new service

void main() async {
  // Required for plugin initialization before runApp
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the notification service
  final notificationService = NotificationService();
  await notificationService.init();
  
  // Schedule a daily reminder for the 10th Step
  // Set this to your preferred time (e.g., 21:00 is 9:00 PM)
  await notificationService.scheduleDailyReviewReminder(hour: 21, minute: 0);

  runApp(const ProviderScope(child: FearlessInventoryApp()));
}

class FearlessInventoryApp extends ConsumerWidget {
  const FearlessInventoryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Fearless Inventory',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const HomeScreen(),
    );
  }
}