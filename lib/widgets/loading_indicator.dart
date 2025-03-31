import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final Color color;
  final double size;

  const LoadingIndicator({
    super.key,
    this.color = Colors.blue,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(color: color, strokeWidth: 3.0),
    );
  }
}
