import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final bool useGradient;

  const NeumorphicButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.width = 200,
    this.height = 50,
    this.useGradient = false,
  }) : super(key: key);

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) {
        setState(() => isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width,
        height: widget.height,
        decoration: widget.useGradient
            ? NeumorphicConstants.getMainGradientDecoration()
            : BoxDecoration(
                color: isPressed ? NeumorphicConstants.baseColor : NeumorphicConstants.lightColor,
                borderRadius: BorderRadius.circular(NeumorphicConstants.buttonRadius),
                boxShadow: NeumorphicConstants.getNeumorphicShadow(isPressed: isPressed),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
        child: Center(child: widget.child),
      ),
    );
  }
} 