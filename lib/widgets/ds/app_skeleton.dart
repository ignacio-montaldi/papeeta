import 'package:flutter/material.dart';

import 'package:papeeta/core/theme/theme.dart';

/// Bloque con shimmer. Reemplaza al spinner a pantalla completa.
///
/// El shimmer se anima con un solo [AnimationController] por bloque; para
/// listas grandes conviene envolver la lista en un [Skeletonized] y usar
/// [SkeletonBox] adentro, que comparten un único controller.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppRadius.smAll,
  });

  const SkeletonBox.line({
    super.key,
    this.width,
    this.height = 10,
  }) : borderRadius = const BorderRadius.all(Radius.circular(6));

  const SkeletonBox.circle({super.key, required double size})
      : width = size,
        height = size,
        borderRadius = AppRadius.fullAll;

  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semantic;
    final t = _ShimmerScope.of(context);

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: LinearGradient(
            colors: [
              semantic.skeletonBase,
              semantic.skeletonHighlight,
              semantic.skeletonBase,
            ],
            stops: const [0.25, 0.5, 0.75],
            begin: Alignment(-1 + 3 * t, 0),
            end: Alignment(1 + 3 * t, 0),
          ),
        ),
      ),
    );
  }
}

/// Anima todos los [SkeletonBox] descendientes con un único controller.
class Skeletonized extends StatefulWidget {
  const Skeletonized({super.key, required this.child});

  final Widget child;

  @override
  State<Skeletonized> createState() => _SkeletonizedState();
}

class _SkeletonizedState extends State<Skeletonized>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.shimmer,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return _ShimmerScope(t: _controller.value, child: child!);
      },
      child: widget.child,
    );
  }
}

class _ShimmerScope extends InheritedWidget {
  const _ShimmerScope({required this.t, required super.child});

  final double t;

  /// Sin un [Skeletonized] arriba, el bloque se dibuja estático.
  static double of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_ShimmerScope>()
            ?.t ??
        0.5;
  }

  @override
  bool updateShouldNotify(_ShimmerScope oldWidget) => oldWidget.t != t;
}

/// Skeleton de una tarjeta de receta, con la misma silueta que [RecipeCard].
class RecipeCardSkeleton extends StatelessWidget {
  const RecipeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: AppRadius.lgAll,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AspectRatio(
            aspectRatio: AppSizes.recipeCardImageRatio,
            child: SkeletonBox(borderRadius: BorderRadius.zero),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 13, 13, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: 0.38,
                  child: const SkeletonBox.line(height: 9),
                ),
                const SizedBox(height: AppSpacing.sm + 1),
                FractionallySizedBox(
                  widthFactor: 0.75,
                  child: const SkeletonBox.line(height: 14),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const SkeletonBox.circle(size: 26),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FractionallySizedBox(
                        widthFactor: 0.45,
                        alignment: Alignment.centerLeft,
                        child: const SkeletonBox.line(height: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton de una tarjeta de grupo.
class GroupCardSkeleton extends StatelessWidget {
  const GroupCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: context.semantic.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(height: 80, borderRadius: BorderRadius.zero),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: 0.6,
                  child: const SkeletonBox.line(height: 14),
                ),
                const SizedBox(height: AppSpacing.sm + 1),
                FractionallySizedBox(
                  widthFactor: 0.85,
                  child: const SkeletonBox.line(height: 10),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: const [
                    SkeletonBox(
                      width: 70,
                      height: 22,
                      borderRadius: AppRadius.fullAll,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    SkeletonBox(
                      width: 70,
                      height: 22,
                      borderRadius: AppRadius.fullAll,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
