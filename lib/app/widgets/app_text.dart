import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    this.style,
    this.textAlign,
    this.maxLines,
    super.key,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  Widget build(BuildContext context) => Text(
    data,
    style: style,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: maxLines == null ? null : TextOverflow.ellipsis,
  );
}
