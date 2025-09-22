import 'package:flutter/material.dart';

class EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool embedded;
  final String? actionText;
  final VoidCallback? onAction;
  final bool scrollable; // NEW: enable scrolling
  final double? maxHeight; // NEW: optional max height for scrollable content

  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.message,
    this.embedded = false,
    this.actionText,
    this.onAction,
    this.scrollable =
        false, // default to non-scrollable for backward compatibility
    this.maxHeight = 300, // default max height for scrollable content
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 64, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        if (actionText != null && onAction != null) ...[
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A1E40),
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(actionText!),
          ),
        ],
      ],
    );

    // Wrap content in SingleChildScrollView if scrollable is true
    final scrollableContent = scrollable
        ? ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxHeight ?? double.infinity,
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: content,
            ),
          )
        : content;

    if (embedded) {
      // Inline (no card background) - scrollable version
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: scrollableContent,
      );
    }

    // Original card look - scrollable version
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: scrollableContent),
      ),
    );
  }
}

// Alternative: Dedicated scrollable empty state with better scroll control
class ScrollableEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final double maxHeight;
  final ScrollController? scrollController;

  const ScrollableEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.subtitle,
    this.actionText,
    this.onAction,
    this.maxHeight = 400,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.6,
          maxHeight: maxHeight,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A1E40),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(actionText!),
              ),
            ],
            const SizedBox(height: 40), // Extra space for better scrolling
          ],
        ),
      ),
    );
  }
}
