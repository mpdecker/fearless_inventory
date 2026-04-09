enum ReviewType {
  morning,
  spotCheck,
  nightly;

  String get dbValue => switch (this) {
        ReviewType.morning   => 'morning',
        ReviewType.spotCheck => 'spot_check',
        ReviewType.nightly   => 'nightly',
      };

  static ReviewType fromDb(String? value) => switch (value) {
        'morning'    => ReviewType.morning,
        'spot_check' => ReviewType.spotCheck,
        _            => ReviewType.nightly,
      };

  String get displayTitle => switch (this) {
        ReviewType.morning   => 'Morning 10th Step',
        ReviewType.spotCheck => 'Spot Check',
        ReviewType.nightly   => 'Nightly 10th Step',
      };
}
