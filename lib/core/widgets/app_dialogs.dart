import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';

/// [showDatePicker] wrapped so the dialog inherits [Theme.of(context)] instead of
/// forcing a light Material palette (better for dark theme + iOS).
Future<DateTime?> showAppThemedDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String? helpText,
  String? cancelText,
  String? confirmText,
  String? fieldLabelText,
  String? errorFormatText,
  String? errorInvalidText,
}) {
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    helpText: helpText,
    cancelText: cancelText,
    confirmText: confirmText,
    fieldLabelText: fieldLabelText,
    errorFormatText: errorFormatText,
    errorInvalidText: errorInvalidText,
    builder: (ctx, child) => Theme(
      data: Theme.of(ctx),
      child: child!,
    ),
  );
}

/// Themed [showTimePicker] for consistent dark styling with [showAppThemedDatePicker].
Future<TimeOfDay?> showAppThemedTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  String? cancelText,
  String? confirmText,
  String? helpText,
}) {
  return showTimePicker(
    context: context,
    initialTime: initialTime,
    cancelText: cancelText,
    confirmText: confirmText,
    helpText: helpText,
    builder: (ctx, child) => Theme(
      data: Theme.of(ctx),
      child: child!,
    ),
  );
}

DateTime _clampDate(DateTime d, DateTime first, DateTime last) {
  if (d.isBefore(first)) return first;
  if (d.isAfter(last)) return last;
  return d;
}

/// On iOS uses a Cupertino wheel picker; elsewhere uses [showAppThemedDatePicker].
Future<DateTime?> showAdaptiveAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String? helpText,
  String? cancelText,
  String? confirmText,
  String? fieldLabelText,
  String? errorFormatText,
  String? errorInvalidText,
}) async {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
    final clampedInitial = _clampDate(initialDate, firstDate, lastDate);

    return showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (modalContext) {
        DateTime selected = clampedInitial;
        final bottom = MediaQuery.paddingOf(modalContext).bottom;

        return ColoredBox(
          color: Theme.of(modalContext).scaffoldBackgroundColor,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottom),
              child: StatefulBuilder(
                builder: (ctx, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          CupertinoButton(
                            onPressed: () => Navigator.pop(modalContext),
                            child: Text(cancelText ?? 'Cancel'),
                          ),
                          if (helpText != null) ...[
                            Expanded(
                              child: Text(
                                helpText,
                                textAlign: TextAlign.center,
                                style: Theme.of(modalContext).textTheme.titleSmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ] else
                            const Spacer(),
                          CupertinoButton(
                            onPressed: () =>
                                Navigator.pop(modalContext, selected),
                            child: Text(confirmText ?? 'Done'),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 216,
                        child: CupertinoTheme(
                          data: CupertinoThemeData(
                            brightness: Theme.of(modalContext).brightness,
                            primaryColor:
                                Theme.of(modalContext).colorScheme.primary,
                          ),
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime: selected,
                            minimumDate: firstDate,
                            maximumDate: lastDate,
                            onDateTimeChanged: (d) =>
                                setState(() => selected = d),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  return showAppThemedDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    helpText: helpText,
    cancelText: cancelText,
    confirmText: confirmText,
    fieldLabelText: fieldLabelText,
    errorFormatText: errorFormatText,
    errorInvalidText: errorInvalidText,
  );
}

/// On iOS uses a Cupertino wheel picker; elsewhere uses [showAppThemedTimePicker].
Future<TimeOfDay?> showAdaptiveAppTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  String? cancelText,
  String? confirmText,
  String? helpText,
}) async {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
    final now = DateTime.now();

    return showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (modalContext) {
        DateTime wheelValue = DateTime(
          now.year,
          now.month,
          now.day,
          initialTime.hour,
          initialTime.minute,
        );
        final bottom = MediaQuery.paddingOf(modalContext).bottom;

        return ColoredBox(
          color: Theme.of(modalContext).scaffoldBackgroundColor,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottom),
              child: StatefulBuilder(
                builder: (ctx, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          CupertinoButton(
                            onPressed: () => Navigator.pop(modalContext),
                            child: Text(cancelText ?? 'Cancel'),
                          ),
                          if (helpText != null) ...[
                            Expanded(
                              child: Text(
                                helpText,
                                textAlign: TextAlign.center,
                                style: Theme.of(modalContext).textTheme.titleSmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ] else
                            const Spacer(),
                          CupertinoButton(
                            onPressed: () => Navigator.pop(
                              modalContext,
                              TimeOfDay(
                                hour: wheelValue.hour,
                                minute: wheelValue.minute,
                              ),
                            ),
                            child: Text(confirmText ?? 'Done'),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 216,
                        child: CupertinoTheme(
                          data: CupertinoThemeData(
                            brightness: Theme.of(modalContext).brightness,
                          ),
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.time,
                            use24hFormat: MediaQuery.of(modalContext)
                                .alwaysUse24HourFormat,
                            initialDateTime: wheelValue,
                            onDateTimeChanged: (d) =>
                                setState(() => wheelValue = d),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  return showAppThemedTimePicker(
    context: context,
    initialTime: initialTime,
    cancelText: cancelText,
    confirmText: confirmText,
    helpText: helpText,
  );
}
