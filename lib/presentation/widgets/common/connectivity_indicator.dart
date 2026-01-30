import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Connectivity Indicator Widget
/// Shows connection status as a small dot
class ConnectivityIndicator extends StatelessWidget {
  final bool isConnected;
  final double size;
  final bool showLabel;

  const ConnectivityIndicator({
    super.key,
    required this.isConnected,
    this.size = 10,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isConnected ? AppColors.success : AppColors.error;

    if (showLabel) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDot(color),
          const SizedBox(width: 8),
          Text(
            isConnected ? 'En línea' : 'Sin conexión',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return _buildDot(color);
  }

  Widget _buildDot(Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

/// Animated connectivity indicator with pulse effect
class AnimatedConnectivityIndicator extends StatefulWidget {
  final bool isConnected;
  final double size;

  const AnimatedConnectivityIndicator({
    super.key,
    required this.isConnected,
    this.size = 10,
  });

  @override
  State<AnimatedConnectivityIndicator> createState() =>
      _AnimatedConnectivityIndicatorState();
}

class _AnimatedConnectivityIndicatorState
    extends State<AnimatedConnectivityIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isConnected ? AppColors.success : AppColors.error;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: _animation.value * 0.5),
                blurRadius: 8 * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
