class Version {
  final String name;
  final String slug;
  Version({required this.name, required this.slug});
  factory Version.fromJson(Map<String, dynamic> j) => Version(
    name: j['name'], slug: j['slug']
  );
}

class Book {
  final String name;
  final String slug;
  final String testament;
  Book({required this.name, required this.slug, this.testament = ''});
  factory Book.fromJson(Map<String, dynamic> j) => Book(
    name: j['name'], slug: j['slug'], testament: j['testament'],
  );
}

class Verse {
  final String version;
  final String book;
  final int chapter;
  final int number;
  final String text;
  Verse({
    required this.version,
    required this.book,
    required this.chapter,
    required this.number,
    required this.text,
  });
  factory Verse.fromJson(Map<String, dynamic> j) => Verse(
    version: j['version'], book: j['book'],
    chapter: j['chapter'], number: j['number'], text: j['text'],
  );
}
