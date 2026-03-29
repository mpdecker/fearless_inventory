import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../data/repositories/step12_repository.dart';
import '../../../data/repositories/service_commitments_repository.dart';
import '../../../data/repositories/sponsee_repository.dart';
import '../../../data/repositories/meetings_repository.dart';

/// All Step 12 calendar events, ordered by start time ascending.
final step12EventsProvider = StreamProvider<List<StepTwelveEvent>>(
  (ref) => ref.watch(step12RepositoryProvider).watchAll(),
);

/// All sponsees, active first then alphabetically.
final allSponseesProvider = StreamProvider<List<Sponsee>>(
  (ref) => ref.watch(sponseeRepositoryProvider).watchAll(),
);

/// Active service commitments only.
final activeServiceCommitmentsProvider = StreamProvider<List<ServiceCommitment>>(
  (ref) => ref.watch(serviceCommitmentsRepositoryProvider).watchActive(),
);

/// Past/inactive service commitments.
final historyServiceCommitmentsProvider = StreamProvider<List<ServiceCommitment>>(
  (ref) => ref.watch(serviceCommitmentsRepositoryProvider).watchHistory(),
);

/// All 12th-step calls (past + future), most recent first.
final twelfthStepCallsProvider = StreamProvider<List<TwelfthStepCall>>(
  (ref) => ref.watch(serviceCommitmentsRepositoryProvider).watchCalls(),
);

/// Upcoming (scheduled, future) 12th-step calls only.
final scheduledStepCallsProvider = StreamProvider<List<TwelfthStepCall>>(
  (ref) =>
      ref.watch(serviceCommitmentsRepositoryProvider).watchScheduledCalls(),
);

/// Completed / past 12th-step calls only.
final pastStepCallsProvider = StreamProvider<List<TwelfthStepCall>>(
  (ref) => ref.watch(serviceCommitmentsRepositoryProvider).watchPastCalls(),
);

/// Count of 12th-step calls logged this calendar month.
final stepCallsThisMonthProvider = StreamProvider<int>(
  (ref) =>
      ref.watch(serviceCommitmentsRepositoryProvider).watchCallsThisMonth(),
);

/// Meetings the user has marked for planned recurring attendance.
/// Used by the Step 12 calendar to show them as weekly recurring events.
final plannedMeetingsProvider = StreamProvider<List<Meeting>>(
  (ref) => ref.watch(meetingsRepositoryProvider).watchPlannedMeetings(),
);
