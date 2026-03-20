enum AmendsType {
  personal,
  financial,
  emotional,
  professional,
  indirect;

  String get displayName {
    switch (this) {
      case AmendsType.personal: return 'Personal / Face-to-Face';
      case AmendsType.financial: return 'Financial / Restitution';
      case AmendsType.emotional: return 'Emotional / Relationship';
      case AmendsType.professional: return 'Professional / Workplace';
      case AmendsType.indirect: return 'Indirect / Service';
    }
  }
}