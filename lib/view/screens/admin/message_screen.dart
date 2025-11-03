// lib/view/screens/admin/message_screen.dart
import 'package:flutter/material.dart';
import 'package:front_erp_aromair/viewmodel/admin/message_controller.dart';
import 'package:get/get.dart';
import 'package:front_erp_aromair/data/repositories/admin/messaging_broadcast_repository.dart';
import 'package:front_erp_aromair/data/services/message_broadcast_service.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/theme/colors.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_scaffold.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(
      MessagingBroadcastController(
        repo: MessagingBroadcastRepository(
          MessagingBroadcastService(buildDio()),
        ),
      ),
    );

    return AromaScaffold(
      title: 'Broadcast WhatsApp',
      body: Column(
        children: [
          // HEADER
          _ElegantHeader(controller: c),
          const SizedBox(height: 24),

          // SINGLE ELEGANT CARD CONTAINING EVERYTHING
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1) TYPES
                      Obx(
                        () => _ElegantFilterSection(
                          title: 'Type de client',
                          items: c.types,
                          selected: c.selectedTypes.toSet(),
                          color: AppColors.primary,
                          onTap: c.toggleType,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 2) NATURES
                      Obx(
                        () => _ElegantFilterSection(
                          title: 'Nature',
                          items: c.natures,
                          selected: c.selectedNatures.toSet(),
                          color: Colors.indigo,
                          onTap: c.toggleNature,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 3) IMPORTANCE
                      Obx(
                        () => _ElegantFilterSection(
                          title: 'Importance',
                          items: c.importances,
                          selected: c.selectedImportances.toSet(),
                          color: Colors.orange,
                          onTap: c.toggleImportance,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // MESSAGE
                      const _ElegantSectionTitle("Message"),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          minLines: 5,
                          maxLines: 7,
                          onChanged: (v) => c.message.value = v,
                          decoration: const InputDecoration(
                            hintText:
                                "Ex: Bonjour {{1}} 👋 L'équipe AROMAIR vous contacte pour informer que ...",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // SEND BUTTON
                      Obx(
                        () => _ElegantSendButton(
                          isSending: c.sending.value,
                          onTap: c.send,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // RESULT
                      Obx(() {
                        final r = c.lastResult.value;
                        if (r == null) return const SizedBox.shrink();
                        return _ElegantResultCard(text: r);
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ============ ELEGANT HEADER ============
class _ElegantHeader extends StatelessWidget {
  final MessagingBroadcastController controller;
  const _ElegantHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.98),
            AppColors.primary.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.message_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Broadcast WhatsApp",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Filtrez vos contacts puis envoyez un message personnalisé.",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats
          Obx(
            () => Row(
              children: [
                _ElegantStatPill(
                  icon: Icons.filter_list_rounded,
                  label: "Types",
                  value: controller.selectedTypes.length.toString(),
                ),
                const SizedBox(width: 10),
                _ElegantStatPill(
                  icon: Icons.apartment_rounded,
                  label: "Natures",
                  value: controller.selectedNatures.length.toString(),
                ),
                const SizedBox(width: 10),
                _ElegantStatPill(
                  icon: Icons.star_rounded,
                  label: "Imp.",
                  value: controller.selectedImportances.length.toString(),
                ),
                const Spacer(),
                if (controller.lastResult.value != null)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ElegantStatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ElegantStatPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// ============ ELEGANT FILTER SECTION ============
class _ElegantFilterSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final Iterable<String> selected;
  final Color color;
  final void Function(String) onTap;

  const _ElegantFilterSection({
    required this.title,
    required this.items,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ElegantSectionTitle(title),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map(
                (it) => _ElegantChip(
                  label: it,
                  selected: selected.contains(it),
                  color: color,
                  onTap: () => onTap(it),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ElegantChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _ElegantChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 0 : 1.5,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: selected
                  ? Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                      key: const Key('selected'),
                    )
                  : Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      key: const Key('unselected'),
                    ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey.shade800,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ElegantSectionTitle extends StatelessWidget {
  final String text;
  const _ElegantSectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: Colors.black87,
      ),
    );
  }
}

/// ============ ELEGANT SEND BUTTON ============
class _ElegantSendButton extends StatelessWidget {
  final bool isSending;
  final VoidCallback onTap;
  const _ElegantSendButton({required this.isSending, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.primary,
        elevation: 2,
        child: InkWell(
          onTap: isSending ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSending)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.8),
                      ),
                    ),
                  )
                else
                  const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  isSending ? "Envoi en cours..." : "Envoyer le broadcast",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
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

/// ============ ELEGANT RESULT CARD ============
class _ElegantResultCard extends StatelessWidget {
  final String text;
  const _ElegantResultCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
