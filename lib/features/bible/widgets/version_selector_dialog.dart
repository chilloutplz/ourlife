import 'package:flutter/material.dart';

class VersionSelectorDialog extends StatefulWidget {
  final List<String> initialSelectedVersions;

  const VersionSelectorDialog({super.key, required this.initialSelectedVersions});

  @override
  State<VersionSelectorDialog> createState() => _VersionSelectorDialogState();
}

class _VersionSelectorDialogState extends State<VersionSelectorDialog> {
  late List<String> selected;
  final List<String> allVersions = ['개역개정', '개역한글', 'NIV', 'ESV'];

  @override
  void initState() {
    super.initState();
    selected = List.from(widget.initialSelectedVersions);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('성경 버전 선택'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          children: allVersions.map((version) {
            return CheckboxListTile(
              title: Text(version),
              value: selected.contains(version),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selected.add(version);
                  } else {
                    selected.remove(version);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(selected),
          child: const Text('확인'),
        ),
      ],
    );
  }
}
