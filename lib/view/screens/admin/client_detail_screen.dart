import 'package:flutter/material.dart';
import 'package:front_erp_aromair/view/widgets/affecter_clientdiffuseur_dialog.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import 'package:front_erp_aromair/view/widgets/admin_drawer.dart';
import 'package:front_erp_aromair/data/models/client_detail.dart';
import 'package:front_erp_aromair/viewmodel/admin/client_detail_controller.dart';

class ClientDetailScreen extends StatelessWidget {
  final int clientId;
  const ClientDetailScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    final tag = 'client_$clientId';
    return GetX<ClientDetailController>(
      init: Get.put(ClientDetailController(clientId), tag: tag),
      tag: tag,
      builder: (c) {
        final d = c.dto.value;
        return Scaffold(
          drawer: const AdminDrawer(),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0A1E40),
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "Détails du Client",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: c.fetch,
                tooltip: "Actualiser",
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A1E40), // Dark navy
                  Color(0xFF152A51), // Medium navy
                  Color(0xFF1E3A8A), // Royal blue
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: c.isLoading.value
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF0A1E40),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "Chargement des détails...",
                                  style: TextStyle(color: Color(0xFF0A1E40)),
                                ),
                              ],
                            ),
                          )
                        : c.error.value != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade400,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Erreur de chargement",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF0A1E40),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  c.error.value!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: c.fetch,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0A1E40),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text("Réessayer"),
                                ),
                              ],
                            ),
                          )
                        : d == null
                        ? const Center(
                            child: Text(
                              "Aucune donnée disponible",
                              style: TextStyle(color: Color(0xFF0A1E40)),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header section
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      color: Color(0xFF0A1E40),
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "Détails du Client",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0A1E40),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF0A1E40,
                                        ).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            size: 12,
                                            color: const Color(0xFF0A1E40),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            d.nature ?? "Client",
                                            style: const TextStyle(
                                              color: Color(0xFF0A1E40),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "ID : ${d.id}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // ---------- Coordonnées (editable) + Satisfaction ----------
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: _infoCard(
                                        "Coordonnées",
                                        Icons.contact_page,
                                        [
                                          const SizedBox(height: 10),
                                          _coordsBlock(d, c),
                                        ],
                                        trailing: Obx(() {
                                          if (!c.isEditing.value) {
                                            return IconButton(
                                              tooltip: 'Modifier',
                                              onPressed: c.startEdit,
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                              ),
                                            );
                                          }
                                          return Row(
                                            children: [
                                              TextButton.icon(
                                                onPressed: c.cancelEdit,
                                                icon: const Icon(Icons.close),
                                                label: const Text('Annuler'),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton.icon(
                                                onPressed: c.save,
                                                icon: const Icon(Icons.check),
                                                label: const Text(
                                                  'Enregistrer',
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      flex: 1,
                                      child: _infoCard(
                                        "Satisfaction",
                                        Icons.sentiment_satisfied,
                                        [
                                          Center(
                                            child: _satisfactionGauge(
                                              d.satisfaction,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // ---------- Diffuseurs ----------
                                _sectionTitle("Diffuseurs"),
                                const SizedBox(height: 12),
                                _dataTableCard(
                                  columns: [
                                    const DataColumn(
                                      label: _TableHeader("CAB"),
                                    ),
                                    const DataColumn(
                                      label: _TableHeader("Modèle"),
                                    ),
                                    const DataColumn(
                                      label: _TableHeader("Type_Carte"),
                                    ),
                                    const DataColumn(
                                      label: _TableHeader("Emplacement"),
                                    ),
                                    if (c.isSuperAdmin)
                                      const DataColumn(
                                        label: _TableHeader("Actions"),
                                      ),
                                  ],
                                  rows: _diffuseursTable(
                                    context,
                                    d.diffuseurs,
                                    c,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // ---------- Interventions ----------
                                _sectionTitle("Interventions"),
                                const SizedBox(height: 12),
                                _dataTableCard(
                                  columns: const [
                                    DataColumn(label: _TableHeader("Date")),
                                    DataColumn(
                                      label: _TableHeader("Technicien"),
                                    ),
                                    DataColumn(label: _TableHeader("Alertes")),
                                    DataColumn(label: _TableHeader("Statut")),
                                  ],
                                  rows: _interventionsTable(d.interventions),
                                ),
                                const SizedBox(height: 24),

                                // ---------- Réclamations ----------
                                _sectionTitle("Réclamations"),
                                const SizedBox(height: 12),
                                d.reclamations.isEmpty
                                    ? _emptyStateCard(
                                        Icons.report_problem,
                                        "Aucune réclamation enregistrée",
                                      )
                                    : _dataTableCard(
                                        columns: const [
                                          DataColumn(
                                            label: _TableHeader("Date"),
                                          ),
                                          DataColumn(
                                            label: _TableHeader("Problème"),
                                          ),
                                          DataColumn(
                                            label: _TableHeader("Technicien"),
                                          ),
                                          DataColumn(
                                            label: _TableHeader("Statut"),
                                          ),
                                        ],
                                        rows: _reclamationsTable(
                                          d.reclamations,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => showAffecterClientDiffuseurDialog(context, c),
            backgroundColor: const Color(0xFF0A1E40),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // UI blocks
  // ---------------------------------------------------------------------------

  // ---- Coordonnées : EDIT / VIEW
  static Widget _coordsBlock(ClientDetail d, ClientDetailController c) {
    // chips (lecture)
    Widget chip(String t) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.only(right: 6, bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1E40).withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF0A1E40)),
      ),
      child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
    );

    // kv (lecture)
    Widget kv(String k, String v) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              "$k:",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(v, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );

    // form decorations (édition)
    InputDecoration deco(String label) => InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      isDense: true,
    );

    Widget numberField(TextEditingController ctrl, String label) =>
        TextFormField(
          controller: ctrl,
          decoration: deco(label),
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return null;
            if (int.tryParse(v.trim()) == null) return 'Nombre invalide';
            return null;
          },
        );

    Widget dropdown(String label, List<String> items, RxnString value) => Obx(
      () => DropdownButtonFormField<String>(
        value: value.value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => value.value = v,
        decoration: deco(label),
      ),
    );

    final rawAdr = d.adresse.trim();

    return Obx(() {
      if (!c.isEditing.value) {
        // ---------- MODE LECTURE ----------
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              children: [
                if (d.nature != null)
                  chip(
                    d.nature! == "ENTREPRISE" ? "Entreprise" : "Particulier",
                  ),
                if (d.type != null) chip("Type: ${d.type}"),
                if (d.importance != null) chip("Importance: ${d.importance}"),
                if (d.algoPlan != null) chip("Algo: ${d.algoPlan}"),
              ],
            ),
            const SizedBox(height: 10),
            kv("Nom de Client", d.nom),
            Row(
              children: [
                Expanded(child: kv("Téléphone", d.telephone)),
                Expanded(child: kv("Coordonateur", d.coordonateur)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    child: const Text(
                      "Adresse:",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: "Ouvrir dans Google Maps",
                    onPressed: c.openMaps,
                    icon: const Icon(Icons.map_outlined),
                    color: const Color(0xFF0A1E40),
                    splashRadius: 20,
                  ),
                  if (!(rawAdr.startsWith('http://') ||
                      rawAdr.startsWith('https://')))
                    Expanded(
                      child: Text(
                        rawAdr.isEmpty ? '-' : rawAdr,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: kv(
                    "Fr Livraison (jour)",
                    (d.frequenceLivraisonParJour ?? 0).toString(),
                  ),
                ),
                Expanded(
                  child: kv(
                    "Fr Visite (jour)",
                    (d.frequenceVisiteParJour ?? 0).toString(),
                  ),
                ),
              ],
            ),
          ],
        );
      }

      // ---------- MODE ÉDITION ----------
      return Form(
        key: c.formKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: dropdown(
                    "Nature",
                    ClientDetailController.natureOptions,
                    c.nature,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: dropdown(
                    "Type",
                    ClientDetailController.typeOptions,
                    c.type,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: dropdown(
                    "Importance",
                    ClientDetailController.importanceOptions,
                    c.importance,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: dropdown(
                    "Algo",
                    ClientDetailController.algoOptions,
                    c.algo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: c.nomCtrl,
                    decoration: deco("Nom de Client"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: c.telCtrl,
                    decoration: deco("Téléphone"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: c.coordCtrl,
                    decoration: deco("Coordonateur"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: c.adrCtrl,
                    decoration: deco("Adresse (URL ou texte)"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: numberField(c.frLivCtrl, "Fr Livraison (jour)"),
                ),
                const SizedBox(width: 10),
                Expanded(child: numberField(c.frVisCtrl, "Fr Visite (jour)")),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ---- Satisfaction (jauge circulaire)
  static Widget _satisfactionGauge(int? value) {
    final int pct = (value ?? 0).clamp(0, 100);
    final double v = pct / 100.0;

    return SizedBox(
      width: 150,
      height: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: v),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, anim, _) {
              return SizedBox(
                width: 108,
                height: 108,
                child: CustomPaint(
                  painter: _DonutPainter(
                    progress: anim,
                    color: const Color(0xFF0A1E40),
                    trackColor: const Color(0xFFEDEAF6),
                    strokeWidth: 11,
                  ),
                  child: Center(
                    child: Text(
                      "$pct%",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          const Text(
            "Satisfaction",
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // ---- Diffuseurs
  static List<DataRow> _diffuseursTable(
    BuildContext context,
    List<ClientDiffuseurRow> rows,
    ClientDetailController c,
  ) {
    if (rows.isEmpty) {
      return [
        const DataRow(
          cells: [
            DataCell(
              Text(
                "Aucun diffuseur",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataCell(SizedBox()),
            DataCell(SizedBox()),
            DataCell(SizedBox()),
            DataCell(SizedBox()),
          ],
        ),
      ];
    }

    // petite boîte de confirmation avant retrait
    Future<void> _confirmRetirer(String cab) async {
      await Get.defaultDialog(
        title: "Confirmer",
        middleText: "Retirer le diffuseur $cab de ce client ?",
        textCancel: "Annuler",
        textConfirm: "Retirer",
        confirmTextColor: Colors.white,
        onConfirm: () async {
          Get.back(); // fermer le dialog
          await c.retirerClientDiffuseur(cab: cab); // appelle le controller
        },
      );
    }

    return rows.map((r) {
      return DataRow(
        onSelectChanged: (_) => c.goToClientDiffuseur(r.id),
        cells: [
          DataCell(Text(r.cab)),
          DataCell(Text(r.modele)),
          DataCell(Text(r.typeCarte)),
          DataCell(Text(r.emplacement)),
          if (c.isSuperAdmin)
            DataCell(
              Tooltip(
                message: "Retirer ce diffuseur du client",
                child: IconButton(
                  icon: const Icon(
                    Icons.remove_circle,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => _confirmRetirer(r.cab),
                ),
              ),
            ),
        ],
      );
    }).toList();
  }

  // ---- Interventions
  static List<DataRow> _interventionsTable(List<InterventionRow> rows) {
    if (rows.isEmpty) {
      return [
        const DataRow(
          cells: [
            DataCell(
              Text(
                "Aucune intervention",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataCell(SizedBox()),
            DataCell(SizedBox()),
            DataCell(SizedBox()),
          ],
        ),
      ];
    }
    return rows
        .map(
          (r) => DataRow(
            onSelectChanged: (_) => Get.toNamed('/interventions/${r.id}'),
            cells: [
              DataCell(Text(r.date ?? "-")),
              DataCell(Text(r.technicien ?? "-")),
              DataCell(Text(r.alertes == true ? "Oui" : "Non")),
              DataCell(Text(r.statut ?? "-")),
            ],
          ),
        )
        .toList();
  }

  // ---- Réclamations
  static List<DataRow> _reclamationsTable(List<ReclamationRow> rows) {
    if (rows.isEmpty) {
      return [
        const DataRow(
          cells: [
            DataCell(
              Text(
                "Aucune réclamation",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataCell(SizedBox()),
            DataCell(SizedBox()),
            DataCell(SizedBox()),
          ],
        ),
      ];
    }
    return rows
        .map(
          (r) => DataRow(
            onSelectChanged: (_) => Get.toNamed('/reclamations/${r.id}'),
            cells: [
              DataCell(Text(r.date ?? "-")),
              DataCell(
                SizedBox(
                  width: 260,
                  child: Text(
                    r.probleme ?? "-",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(Text(r.technicien ?? "-")),
              DataCell(Text(r.statut ?? "-")),
            ],
          ),
        )
        .toList();
  }

  // ---------- UI Components ----------
  Widget _infoCard(
    String title,
    IconData icon,
    List<Widget> children, {
    Widget? trailing,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF0A1E40), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A1E40),
                  ),
                ),
                const Spacer(),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF0A1E40),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A1E40),
          ),
        ),
      ],
    );
  }

  Widget _dataTableCard({
    required List<DataColumn> columns,
    required List<DataRow> rows,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            constraints: const BoxConstraints(minWidth: 800),
            child: DataTable(
              showCheckboxColumn: false,
              columnSpacing: 24,
              headingRowHeight: 48,
              dataRowMinHeight: 48,
              headingRowColor: MaterialStateProperty.all(
                const Color(0xFF0A1E40).withOpacity(0.8),
              ),
              columns: columns,
              rows: rows,
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyStateCard(IconData icon, String message) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _DonutPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final prog = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // fond complet
    canvas.drawArc(rect, 0, 2 * math.pi, false, track);

    // progrès (démarrage à 12h)
    final start = -math.pi / 2;
    final sweep = (2 * math.pi) * progress;
    canvas.drawArc(rect, start, sweep, false, prog);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth;
}
