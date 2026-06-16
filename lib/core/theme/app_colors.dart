import 'package:flutter/material.dart';

/// Design tokens for Fearless Inventory (indigo + cyan palette).
abstract final class AppColors {
  AppColors._();

  // ── Brand palette ─────────────────────────────────────────────────────
  static const Color indigoPrimary = Color(0xFF4F46E5);
  static const Color cyanSecondary = Color(0xFF06B6D4);
  static const Color lightIndigo = Color(0xFF6366F1);
  static const Color softIndigo = Color(0xFF818CF8);
  static const Color brightCyan = Color(0xFF22D3EE);

  // ── Dark surfaces ───────────────────────────────────────────────────────
  static const Color scaffold = Color(0xFF12121F);
  static const Color surface = Color(0xFF1E1E2E);
  static const Color card = Color(0xFF252535);
  static const Color onSurface = Color(0xFFE0E0F0);
  static const Color onSurfaceMuted = Color(0xFF9CA3AF);
  static const Color bodySmall = Color(0xFFB0B0C8);

  // ── Semantic accents (feature / quote / journal context) ──────────────
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentDeepOrange = Color(0xFFEA580C);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color accentDeepPurple = Color(0xFF6D28D9);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentDeepGreen = Color(0xFF15803D);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentBlue = Color(0xFF3B82F6);

  /// Step 5 ceremony / landing accents (cyan family).
  static const Color ceremonyAccent = Color(0xFF06B6D4);
  static const Color ceremonySurface = Color(0xFF1E2A44);

  /// Literature reader links.
  static const Color literatureLink = Color(0xFF6366F1);
  static const Color literatureLinkVisited = Color(0xFF818CF8);

  /// Dashboard quick-action tints (harmonized with brand).
  static const Color dashboardBlue = Color(0xFF6366F1);
  static const Color dashboardTeal = Color(0xFF06B6D4);
  static const Color dashboardPurple = Color(0xFF7C3AED);
  static const Color dashboardAmber = Color(0xFFF59E0B);

  /// Meeting source chips (light panels on dark — keep readable pairs).
  static const Color meetingChipAaBg = Color(0x1A6366F1);
  static const Color meetingChipAaFg = Color(0xFF818CF8);
  static const Color meetingChipAaBorder = Color(0xFF4F46E5);

  static const Color meetingChipNaBg = Color(0x1A06B6D4);
  static const Color meetingChipNaFg = Color(0xFF22D3EE);
  static const Color meetingChipNaBorder = Color(0xFF06B6D4);

  static const Color meetingChipOaBg = Color(0x1AF59E0B);
  static const Color meetingChipOaFg = Color(0xFFFBBF24);
  static const Color meetingChipOaBorder = Color(0xFFD97706);

  static const Color meetingChipOtherBg = Color(0x1F9CA3AF);
  static const Color meetingChipOtherFg = Color(0xFF9CA3AF);
  static const Color meetingChipOtherBorder = Color(0xFF6B7280);
}
