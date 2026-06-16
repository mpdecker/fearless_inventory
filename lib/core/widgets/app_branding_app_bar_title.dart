import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Layout presets for title / tagline scale; the icon always matches the two-line wordmark height.
enum AppBrandingLayout {
  appBar,
  onboarding,
}

/// Fearless Inventory mark: app icon + two-line wordmark (no raster white box).
class AppBrandingAppBarTitle extends StatelessWidget {
  const AppBrandingAppBarTitle({
    super.key,
    this.layout = AppBrandingLayout.appBar,
  });

  final AppBrandingLayout layout;

  /// Squircle artwork (transparent); avoids full wordmark PNGs with white matte.
  static const String iconAssetPath = 'assets/branding/icon_light.png';

  /// Must match [TextStyle.height] on the two wordmark lines below.
  static const double _wordmarkLineHeight = 1.05;

  static const double _kOnboardingTitleSize = 28.0;
  static const double _kOnboardingTaglineSize = 14.0;
  static const double _kOnboardingTaglineLineHeight = 1.2;
  static const double _kOnboardingTaglineTopGap = 6.0;

  /// Top inset of the onboarding logo inside the [Stack] (below status bar).
  static const double onboardingLogoTopOffset = 8.0;

  /// Vertical size of the onboarding mark (row: icon + wordmark + tagline).
  static double onboardingMarkHeight() {
    const wordmark = 2 * _kOnboardingTitleSize * _wordmarkLineHeight;
    const taglineBlock = _kOnboardingTaglineTopGap +
        _kOnboardingTaglineSize * _kOnboardingTaglineLineHeight;
    // Icon column matches wordmark height; tagline makes the text column taller.
    return wordmark + taglineBlock;
  }

  /// Top padding for onboarding [ScrollView] content (inside [SafeArea]) so it clears the logo.
  static double onboardingScrollTopPadding({double gapBelowMark = 16}) {
    return onboardingLogoTopOffset + onboardingMarkHeight() + gapBelowMark;
  }

  @override
  Widget build(BuildContext context) {
    final titleSize = switch (layout) {
      AppBrandingLayout.appBar => 21.0,
      AppBrandingLayout.onboarding => _kOnboardingTitleSize,
    };
    final taglineSize = switch (layout) {
      AppBrandingLayout.appBar => 0.0,
      AppBrandingLayout.onboarding => _kOnboardingTaglineSize,
    };

    // Icon square = combined height of "Fearless" + "Inventory" (two lines only).
    final iconSide = 2 * titleSize * _wordmarkLineHeight;

    final mark = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: iconSide,
          height: iconSide,
          child: Image.asset(
            iconAssetPath,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => Icon(
              Icons.fact_check_rounded,
              size: iconSide,
              color: AppColors.softIndigo,
            ),
          ),
        ),
        SizedBox(width: layout == AppBrandingLayout.appBar ? 10 : 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Fearless',
              style: TextStyle(
                height: _wordmarkLineHeight,
                fontSize: titleSize,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppColors.softIndigo,
              ),
            ),
            Text(
              'Inventory',
              style: TextStyle(
                height: _wordmarkLineHeight,
                fontSize: titleSize,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppColors.brightCyan,
              ),
            ),
            if (taglineSize > 0) ...[
              SizedBox(
                  height: layout == AppBrandingLayout.onboarding
                      ? _kOnboardingTaglineTopGap
                      : 0),
              Text(
                'CONTINUOUS STEPWORK',
                style: TextStyle(
                  height: layout == AppBrandingLayout.onboarding
                      ? _kOnboardingTaglineLineHeight
                      : null,
                  fontSize: taglineSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.2,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ],
          ],
        ),
      ],
    );

    return Semantics(
      label: 'Fearless Inventory',
      child: Align(
        alignment: Alignment.centerLeft,
        child: mark,
      ),
    );
  }
}
