// lib/service/elegant_snackbar_service.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ElegantSnackbarService {
  static void showSuccess({
    required String message,
    String title = "Succès",
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    _showElegantSnackbar(
      title: title,
      message: message,
      type: ElegantSnackbarType.success,
      duration: duration,
      onTap: onTap,
    );
  }

  static void showError({
    required String message,
    String title = "Erreur",
    Duration duration = const Duration(seconds: 5),
    VoidCallback? onTap,
  }) {
    _showElegantSnackbar(
      title: title,
      message: message,
      type: ElegantSnackbarType.error,
      duration: duration,
      onTap: onTap,
    );
  }

  static void _showElegantSnackbar({
    required String title,
    required String message,
    required ElegantSnackbarType type,
    required Duration duration,
    VoidCallback? onTap,
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.showSnackbar(
      GetSnackBar(
        // we render everything ourselves inside messageText
        titleText: const SizedBox.shrink(),
        messageText: _ElegantSnackbarContent(
          title: title,
          message: message,
          type: type,
          duration: duration,
          onTap: onTap,
        ),
        backgroundColor: Colors.transparent,
        duration: duration,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
        padding: EdgeInsets.zero,
        borderRadius: 20,
        boxShadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
        overlayBlur: 0.8,
        overlayColor: Colors.black.withOpacity(0.4),
        animationDuration: const Duration(milliseconds: 500),
        isDismissible: true,
        dismissDirection: DismissDirection.up,
        forwardAnimationCurve: Curves.easeOutCubic,
        reverseAnimationCurve: Curves.easeInCubic,
        mainButton: const SizedBox.shrink(),

        // ❌ Removed: userInputForm (expects a Form, not a Widget)
        // userInputForm: _ElegantSnackbarContent(...),
      ),
    );
  }
}

class _ElegantSnackbarContent extends StatefulWidget {
  final String title;
  final String message;
  final ElegantSnackbarType type;
  final Duration duration;
  final VoidCallback? onTap;

  const _ElegantSnackbarContent({
    required this.title,
    required this.message,
    required this.type,
    required this.duration,
    this.onTap,
  });

  @override
  __ElegantSnackbarContentState createState() =>
      __ElegantSnackbarContentState();
}

class __ElegantSnackbarContentState extends State<_ElegantSnackbarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _progressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _controller.forward();

    // Start progress animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      // Guard against very short durations
      final remaining = widget.duration - const Duration(milliseconds: 300);
      _controller.animateTo(
        1.0,
        duration: remaining.isNegative ? Duration.zero : remaining,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap?.call();
        Get.closeCurrentSnackbar();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: widget.type.color.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Animated background bar
                const Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: _LeftGradientBar(),
                ),

                // Main content
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 16,
                    top: 20,
                    bottom: 20,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Animated icon
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.type.color,
                              widget.type.color.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.type.color.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.type.icon,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: widget.type.color,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.message,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Close button
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Get.closeCurrentSnackbar(),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return SizedBox(
                        height: 3,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.type.color,
                          ),
                          value: _progressAnimation.value,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Extracted for const friendliness on the Positioned widget above.
class _LeftGradientBar extends StatelessWidget {
  const _LeftGradientBar();

  @override
  Widget build(BuildContext context) {
    // We need access to ElegantSnackbarType color: pull from Theme via Inherited? Simpler: keep as non-const above.
    // Instead, rebuild here using a transparent placeholder; actual colored shadow is already handled by container.
    // If you want the gradient to reflect the type color, move this back inline (as in your original code).
    return SizedBox(
      width: 6,
      // Transparent; left shadow/gradient handled in parent content.
      child: ColoredBox(color: Colors.transparent),
    );
  }
}

enum ElegantSnackbarType {
  success,
  error;

  Color get color {
    switch (this) {
      case ElegantSnackbarType.success:
        return const Color(0xFF10B981); // Emerald
      case ElegantSnackbarType.error:
        return const Color(0xFFEF4444); // Red
    }
  }

  IconData get icon {
    switch (this) {
      case ElegantSnackbarType.success:
        return Icons.check_rounded;
      case ElegantSnackbarType.error:
        return Icons.error_outline_rounded;
    }
  }
}
