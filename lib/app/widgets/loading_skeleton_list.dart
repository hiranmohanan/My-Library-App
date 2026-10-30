import 'package:flutter/material.dart';

class LoadingSkeletonList extends StatelessWidget {
  const LoadingSkeletonList({this.itemCount = 5, super.key});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Semantics(
      label: 'Loading library',
      child: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(width: 52, height: 72, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 18, color: color),
                    const SizedBox(height: 10),
                    FractionallySizedBox(
                      widthFactor: 0.6,
                      alignment: Alignment.centerLeft,
                      child: Container(height: 14, color: color),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
