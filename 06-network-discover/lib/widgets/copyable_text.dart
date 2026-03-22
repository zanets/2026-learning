import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class CopyableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final String? tooltip;

  const CopyableText(this.text, {super.key, this.style, this.tooltip});

  @override
  State<CopyableText> createState() => _CopyableTextState();
}

class _CopyableTextState extends State<CopyableText> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _copied ? 'Copied!' : (widget.tooltip ?? 'Click to copy'),
      child: GestureDetector(
        onTap: _copy,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Text(
            widget.text,
            style: (widget.style ?? const TextStyle()).copyWith(
              color: _copied ? AppColors.success : null,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
              decorationColor: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
