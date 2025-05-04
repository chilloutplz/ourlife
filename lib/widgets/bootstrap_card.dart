// lib/widgets/bootstrap_card.dart

import 'package:flutter/material.dart';

enum BootstrapCardType { primary, success, danger, warning, info, light, dark }

class BootstrapCard extends StatelessWidget {
  final Widget? header;
  final Widget body;
  final Widget? footer;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final BorderRadius borderRadius;
  final BootstrapCardType? type;
  final bool twoTone;
  final bool outline;

  /// 헤더의 가로 정렬 (기본: start)
  final AlignmentGeometry headerAlignment;
  /// 푸터의 가로 정렬 (기본: end)
  final AlignmentGeometry footerAlignment;

  const BootstrapCard({
    super.key,
    this.header,
    required this.body,
    this.footer,
    this.padding = const EdgeInsets.all(16),
    this.elevation = 2,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.type,
    this.twoTone = false,
    this.outline = false,
    this.headerAlignment = Alignment.centerLeft,  // 기본값
    this.footerAlignment = Alignment.centerRight, // 기본값
  });

  Color _getMainColor(BootstrapCardType t, ColorScheme s) {
    switch (t) {
      case BootstrapCardType.primary: return s.primary;
      case BootstrapCardType.success: return Colors.green.shade600;
      case BootstrapCardType.danger:  return Colors.red.shade600;
      case BootstrapCardType.warning: return Colors.orange.shade700;
      case BootstrapCardType.info:    return Colors.lightBlue.shade600;
      case BootstrapCardType.light:   return Colors.grey.shade200;
      case BootstrapCardType.dark:    return Colors.grey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final mainColor = type != null ? _getMainColor(type!, s) : s.primary;
    final cardBg = twoTone ? s.surface : mainColor;
    final headerBg = mainColor;
    final headerTextColor = ThemeData.estimateBrightnessForColor(headerBg) == Brightness.dark
        ? Colors.white
        : Colors.black87;
    final bodyTextColor = twoTone ? s.onSurface : headerTextColor;

    return Card(
      color: outline ? Colors.transparent : cardBg,
      elevation: outline ? 0 : elevation,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: outline ? BorderSide(color: mainColor, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null) ...[
              Container(
                alignment: headerAlignment,            // 헤더 정렬 반영
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: headerBg,
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                ),
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: headerTextColor,
                  ),
                  child: header!,
                ),
              ),
              const SizedBox(height: 12),
            ],
            DefaultTextStyle(
              style: TextStyle(color: bodyTextColor),
              child: body,
            ),
            if (footer != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: footerAlignment,          // 푸터 정렬 반영
                child: DefaultTextStyle(
                  style: TextStyle(color: bodyTextColor),
                  child: footer!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
