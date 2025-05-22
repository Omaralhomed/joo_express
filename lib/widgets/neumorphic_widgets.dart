import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

export 'neumorphic_button.dart';
export 'neumorphic_card.dart';
export 'glassmorphic_container.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final bool isPressed;
  final VoidCallback? onTap;

  const NeumorphicContainer({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.isPressed = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: isPressed ? NeumorphicConstants.baseColor : NeumorphicConstants.lightColor,
          borderRadius: BorderRadius.circular(NeumorphicConstants.borderRadius),
          boxShadow: NeumorphicConstants.getNeumorphicShadow(isPressed: isPressed),
        ),
        child: child,
      ),
    );
  }
}

class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const NeumorphicButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.width = 200,
    this.height = 50,
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
        decoration: BoxDecoration(
          color: NeumorphicConstants.baseColor,
          borderRadius: BorderRadius.circular(NeumorphicConstants.borderRadius),
          boxShadow: NeumorphicConstants.getNeumorphicShadow(isPressed: isPressed),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isPressed ? NeumorphicConstants.baseColor : NeumorphicConstants.lightColor,
              NeumorphicConstants.baseColor,
            ],
          ),
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}

class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;

  const NeumorphicCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: NeumorphicConstants.baseColor,
        borderRadius: BorderRadius.circular(NeumorphicConstants.borderRadius),
        boxShadow: NeumorphicConstants.getNeumorphicShadow(),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            NeumorphicConstants.lightColor,
            NeumorphicConstants.baseColor,
          ],
        ),
      ),
      child: child,
    );
  }
}

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;

  const GlassmorphicContainer({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: NeumorphicConstants.getGlassmorphicDecoration(),
      child: child,
    );
  }
} 