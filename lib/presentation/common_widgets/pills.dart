import 'package:flutter/material.dart';

class PillButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool selected;
  final EdgeInsets padding;
  final double radius;
  final bool showBorder;
  final Color? bg;

  const PillButton({
    super.key,
    required this.child,
    this.onTap,
    this.selected = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.radius = 22,
    this.showBorder = true,
    this.bg,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? const Color(0xFFD1D5DB) : const Color(0xFFE5E7EB);
    return Material(
      color: bg ?? Colors.white,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: showBorder ? Border.all(color: borderColor) : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

class SmallBadge extends StatelessWidget {
  final String text;
  const SmallBadge(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE11D48), // merah
        borderRadius: BorderRadius.circular(9),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
