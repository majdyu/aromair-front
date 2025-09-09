import 'package:flutter/material.dart';
import 'package:front_erp_aromair/viewmodel/admin/alerte_detail_controller.dart';
import 'package:get/get.dart';

import 'package:front_erp_aromair/data/models/alerte_recos.dart';
import '../../widgets/admin_drawer.dart';

class AlerteDetailScreen extends StatelessWidget {
  final int alerteId;
  const AlerteDetailScreen({super.key, required this.alerteId});

  void _showRecosBottomSheet(
    BuildContext context,
    List<String> recos,
    void Function(String? selected) onInsert,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        if (recos.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text("Aucune recommandation pour ce problème."),
          );
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Recommandations",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ...recos.map(
                (r) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.tips_and_updates_outlined),
                  title: Text(r),
                  trailing: TextButton(
                    onPressed: () {
                      onInsert(r);
                      Navigator.pop(context);
                    },
                    child: const Text("Insérer"),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tag = 'al_$alerteId';
    return GetX<AlerteDetailController>(
      init: Get.put(AlerteDetailController(alerteId), tag: tag),
      tag: tag,
      builder: (c) {
        final dto = c.dto.value;

        return Scaffold(
          drawer: const AdminDrawer(),
          appBar: AppBar(
            backgroundColor: const Color(0xFF75A6D1),
            centerTitle: true,
            title: const Text('Consulter Alerte'),
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          ),
          body: Container(
            color: const Color(0xFF75A6D1),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: c.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : c.error.value != null
                            ? Center(child: Text('Erreur: ${c.error.value}'))
                            : dto == null
                                ? const Center(child: Text('Aucune donnée'))
                                : SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _kv('Date', dto.date),
                                        _kv('Problème', dto.probleme ?? '-'),
                                        _kv('Cause', dto.cause ?? '-'),
                                        _kv(
                                          'Diffuseur',
                                          _fmtDiffuseur(
                                            dto.diffuseurCab,
                                            dto.diffuseurModele,
                                            dto.diffuseurTypeCarte,
                                          ),
                                        ),
                                        _kv('Client', dto.client),
                                        if (dto.emplacement.isNotEmpty)
                                          _kv('Emplacement', dto.emplacement),
                                        const SizedBox(height: 16),

                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text('Décision prise:'),
                                            const SizedBox(width: 8),
                                            Tooltip(
                                              message: 'Voir recommandations',
                                              child: InkWell(
                                                onTap: () {
                                                  final recos = AlerteRecos.forProblem(dto.probleme);
                                                  _showRecosBottomSheet(
                                                    context,
                                                    recos,
                                                    (text) {
                                                      if (text != null && text.trim().isNotEmpty) {
                                                        c.decisionCtrl.text = text;
                                                      }
                                                    },
                                                  );
                                                },
                                                child: const Icon(
                                                  Icons.info,
                                                  color: Color(0xFF3E7DA6),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: c.decisionCtrl,
                                          minLines: 3,
                                          maxLines: 6,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // ---- Boutons (Résolu + Visualiser Client) ----
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: c.isSaving.value
                                                  ? null
                                                  : () async {
                                                      await c.onTogglePressed();
                                                    },
                                              icon: Icon(
                                                (dto.etatResolution)
                                                    ? Icons.sentiment_satisfied_alt
                                                    : Icons.sentiment_dissatisfied,
                                                color: Colors.white,
                                              ),
                                              label: Text(
                                                (dto.etatResolution) ? 'Résolu' : 'Valider',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    dto.etatResolution ? Colors.green : Colors.red,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 28,
                                                  vertical: 14,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(30),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            OutlinedButton.icon(
                                              onPressed: () => c.goToClient(),
                                              icon: const Icon(Icons.person_search, size: 20),
                                              label: const Text('Visualiser Client'),
                                              style: OutlinedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                                side: const BorderSide(color: Color(0xFF3E7DA6), width: 1.5),
                                                foregroundColor: const Color(0xFF3E7DA6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static String _fmtDiffuseur(String cab, String modele, String type) {
    final p = <String>[];
    if (cab != '-') p.add(cab);
    if (modele != '-') p.add(modele);
    if (type != '-') p.add(type);
    return p.isEmpty ? '-' : p.join(' • ');
  }

  static Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 14),
            children: [
              TextSpan(
                text: '$k: ',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              TextSpan(text: v),
            ],
          ),
        ),
      );
}
