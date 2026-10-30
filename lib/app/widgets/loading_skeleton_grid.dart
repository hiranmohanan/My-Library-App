import 'package:flutter/material.dart';

class LoadingSkeletonGrid extends StatelessWidget {
  const LoadingSkeletonGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        itemCount: 6,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: (constraints.maxWidth / 112).floor().clamp(2, 5),
          crossAxisSpacing: 12,
          mainAxisSpacing: 20,
          childAspectRatio: 0.58,
        ),
        itemBuilder: (context, index) => Semantics(
          label: 'Loading library item',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: 8),
              Container(width: double.infinity, height: 10, color: color),
              const SizedBox(height: 5),
              Container(width: 48, height: 8, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
