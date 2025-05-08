import 'package:flutter/material.dart';

class BookSelectorRow extends StatelessWidget {
  const BookSelectorRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: '구약',
          items: ['구약', '신약']
              .map((value) => DropdownMenuItem(value: value, child: Text(value)))
              .toList(),
          onChanged: (value) {},
        ),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: '창세기',
          items: ['창세기', '출애굽기']
              .map((value) => DropdownMenuItem(value: value, child: Text(value)))
              .toList(),
          onChanged: (value) {},
        ),
        const SizedBox(width: 16),
        DropdownButton<int>(
          value: 1,
          items: List.generate(50, (index) => index + 1)
              .map((value) => DropdownMenuItem(value: value, child: Text('$value장')))
              .toList(),
          onChanged: (value) {},
        ),
      ],
    );
  }
}
