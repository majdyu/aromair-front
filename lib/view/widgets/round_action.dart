import 'package:flutter/material.dart';

class RoundAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? bg;
  const RoundAction({super.key, required this.icon, this.onTap, this.bg});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: (bg ?? Colors.white).withOpacity(0.15),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            Icons.adaptive.arrow_forward,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
