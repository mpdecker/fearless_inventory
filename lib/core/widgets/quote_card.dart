import 'package:flutter/material.dart';

import '../quotes/recovery_quotes.dart';
import '../theme/app_colors.dart';

/// A compact, styled quote card used throughout the app.
/// Renders the quote in italic with source citation beneath.
///
/// Usage:
/// ```dart
/// QuoteCard(quote: RecoveryQuotes.step4Resentment)
/// QuoteCard(quote: RecoveryQuotes.step10Evening, compact: true)
/// ```
class QuoteCard extends StatelessWidget {
  final RecoveryQuote quote;

  /// When true, reduces vertical padding and font size — useful inline.
  final bool compact;

  const QuoteCard({
    super.key,
    required this.quote,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _accentForCategory(quote.category, theme);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: compact ? 6 : 12),
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: compact ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: accent.withOpacity(0.6), width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Quote text ──────────────────────────────────────────────────
          Text(
            '\u201C${quote.text}\u201D',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurface,
              fontSize: compact ? 13 : 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          // ── Citation ─────────────────────────────────────────────────────
          Text(
            '— ${quote.citation}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Color _accentForCategory(QuoteCategory cat, ThemeData theme) {
    switch (cat) {
      case QuoteCategory.step1:
      case QuoteCategory.step2:
      case QuoteCategory.step3:
        return AppColors.lightIndigo;
      case QuoteCategory.step4:
        return AppColors.accentRed;
      case QuoteCategory.step5:
        return AppColors.cyanSecondary;
      case QuoteCategory.step6:
        return AppColors.accentPurple;
      case QuoteCategory.step7:
        return AppColors.cyanSecondary;
      case QuoteCategory.step8:
      case QuoteCategory.step9:
        return AppColors.accentDeepOrange;
      case QuoteCategory.step10:
        return AppColors.indigoPrimary;
      case QuoteCategory.step11:
        return AppColors.accentOrange;
      case QuoteCategory.step12:
        return AppColors.cyanSecondary;
      case QuoteCategory.tradition:
        return AppColors.accentDeepPurple;
      case QuoteCategory.promises:
        return AppColors.accentAmber;
      case QuoteCategory.general:
      case QuoteCategory.onboarding:
        return theme.colorScheme.primary;
    }
  }
}
