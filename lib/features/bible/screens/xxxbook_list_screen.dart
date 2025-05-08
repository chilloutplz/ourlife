// // book_list_screen.dart
// import 'package:flutter/material.dart';
// import '../models.dart';
// import '../services/bible_service.dart';

// class BookListScreen extends StatefulWidget {
//   final String version;
//   const BookListScreen({required this.version, super.key});
//   @override State<BookListScreen> createState() => _SB();
// }

// class _SB extends State<BookListScreen> {
//   late Future<List<Book>> _future;
//   @override void initState() {
//     super.initState();
//     _future = BibleService.getBooks(widget.version);
//   }

//   @override Widget build(BuildContext c) {
//     return Scaffold(
//       appBar: AppBar(title: Text('책 (${widget.version})')),
//       body: FutureBuilder<List<Book>>(
//         future: _future,
//         builder: (_, snap) {
//           if (!snap.hasData) return const Center(child: CircularProgressIndicator());
//           final books = snap.data!;
//           return GridView.count(
//             crossAxisCount: 3,
//             children: books.map((b) {
//               return GestureDetector(
//                 onTap: () => Navigator.pushNamed(
//                   c, '/bible/chapters',
//                   arguments: {'version': widget.version, 'book': b.slug},
//                 ),
//                 child: Card(
//                   child: Center(child: Text(b.name)),
//                 ),
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }
// }
