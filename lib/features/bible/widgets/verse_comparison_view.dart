import 'package:flutter/material.dart';

import 'book_selector_row.dart';

class VerseComparisonView extends StatelessWidget {
  final List<String> selectedVersions;

  const VerseComparisonView({super.key, required this.selectedVersions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const BookSelectorRow(),
        Expanded(
          child: ListView.builder(
            itemCount: 10, // 예시: 10개의 절
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('절 ${index + 1}', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 4),
                    for (final version in selectedVersions)
                      Text('[$version] 본문 내용 ${index + 1}'),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
