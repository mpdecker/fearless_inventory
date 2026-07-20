/// Bundled recovery literature (PDF). User-supplied, licensed copies.
abstract final class LiteratureBookCatalog {
  static const String bigBookAsset =
      'assets/literature/AA-Big-Book-4th-edition.pdf';
  static const String twelveTwelveAsset =
      'assets/literature/AA-12-Steps-12-Traditions.pdf';

  static const String bigBookKey = 'bigbook';
  static const String twelveTwelveKey = 'twelve_twelve';

  static const String asBillSeesItAsset =
      'assets/literature/As-Bill-Sees-It.pdf';
  static const String dailyReflectionsAsset =
      'assets/literature/AA-Daily-Reflections.pdf';

  static String assetForBookKey(String bookKey) {
    switch (bookKey) {
      case bigBookKey:
        return bigBookAsset;
      case twelveTwelveKey:
        return twelveTwelveAsset;
      default:
        throw ArgumentError.value(bookKey, 'bookKey');
    }
  }

  static String titleForBookKey(String bookKey) {
    switch (bookKey) {
      case bigBookKey:
        return 'The Big Book';
      case twelveTwelveKey:
        return 'Twelve Steps and Twelve Traditions';
      default:
        return 'Literature';
    }
  }

  static String subtitleForBookKey(String bookKey) {
    switch (bookKey) {
      case bigBookKey:
        return 'Alcoholics Anonymous — Fourth Edition';
      case twelveTwelveKey:
        return 'The "12 & 12"';
      default:
        return '';
    }
  }
}
