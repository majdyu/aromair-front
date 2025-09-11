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
            backgroundColor: const Color(0xFF75A6D1),
            centerTitle: true,
            title: const Text("Visualiser Client"),
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
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: c.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : c.error.value != null
                            ? Center(child: Text("Erreur: ${c.error.value}"))
                            : d == null
                                ? const Center(child: Text("Aucune donnée"))
                                : SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // ---------- Coordonnées (editable) + Satisfaction ----------
                                        _sectionContainer(
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  const Text(
                                                    "Coordonnées",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                  ),
                                                  Obx(() {
                                                    if (!c.isEditing.value) {
                                                      return IconButton(
                                                        tooltip: 'Modifier',
                                                        onPressed: c.startEdit,
                                                        icon: const Icon(Icons.edit_outlined),
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
                                                          label: const Text('Enregistrer'),
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(child: _coordsBlock(d, c)),
                                                  const SizedBox(width: 16),
                                                  _satisfactionGauge(d.satisfaction),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 18),

                                        // ---------- Diffuseurs ----------
                                        _sectionTitle(
                                          "Diffuseurs",
                                          trailing: IconButton(
                                            onPressed: () => showAffecterClientDiffuseurDialog(context, c),
                                            icon: const Icon(Icons.add),
                                            color: const Color(0xFF5DB7A1),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        _card(_diffuseursTable(d.diffuseurs, c)),
                                        const SizedBox(height: 18),

                                        // ---------- Interventions ----------
                                        _sectionTitle("Interventions"),
                                        const SizedBox(height: 8),
                                        _card(_interventionsTable(d.interventions)),
                                        const SizedBox(height: 18),

                                        // ---------- Réclamations ----------
                                        _sectionTitle("Réclamations"),
                                        const SizedBox(height: 8),
                                        _card(
                                          d.reclamations.isEmpty
                                              ? const Padding(
                                                  padding: EdgeInsets.all(16),
                                                  child: Text("Aucune réclamation."),
                                                )
                                              : _reclamationsTable(d.reclamations),
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
            color: const Color(0xFF5DB7A1).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF5DB7A1)),
          ),
          child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
        );

    // kv (lecture)
    Widget kv(String k, String v) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text("$k: ", style: const TextStyle(fontWeight: FontWeight.w700)),
              Expanded(child: Text(v)),
            ],
          ),
        );

    // form decorations (édition)
    InputDecoration deco(String label) => InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          isDense: true,
        );

    Widget numberField(TextEditingController ctrl, String label) => TextFormField(
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
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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
            Wrap(children: [
              if (d.nature != null) chip(d.nature! == "ENTREPRISE" ? "Entreprise" : "Particulier"),
              if (d.type != null) chip("Type: ${d.type}"),
              if (d.importance != null) chip("Importance: ${d.importance}"),
              if (d.algoPlan != null) chip("Algo: ${d.algoPlan}"),
            ]),
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
                  const Text("Adresse: ", style: TextStyle(fontWeight: FontWeight.w700)),
                  IconButton(
                    tooltip: "Ouvrir dans Google Maps",
                    onPressed: c.openMaps,
                    icon: const Icon(Icons.map_outlined),
                    color: const Color(0xFF3E7DA6),
                    splashRadius: 20,
                  ),
                  if (!(rawAdr.startsWith('http://') || rawAdr.startsWith('https://')))
                    Expanded(child: Text(rawAdr.isEmpty ? '-' : rawAdr)),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(child: kv("Fr Livraison (jour)", (d.frequenceLivraisonParJour ?? 0).toString())),
                Expanded(child: kv("Fr Visite (jour)", (d.frequenceVisiteParJour ?? 0).toString())),
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
                Expanded(child: dropdown("Nature", ClientDetailController.natureOptions, c.nature)),
                const SizedBox(width: 10),
                Expanded(child: dropdown("Type", ClientDetailController.typeOptions, c.type)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: dropdown("Importance", ClientDetailController.importanceOptions, c.importance)),
                const SizedBox(width: 10),
                Expanded(child: dropdown("Algo", ClientDetailController.algoOptions, c.algo)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextFormField(controller: c.nomCtrl, decoration: deco("Nom de Client"))),
                const SizedBox(width: 10),
                Expanded(child: TextFormField(controller: c.telCtrl, decoration: deco("Téléphone"))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextFormField(controller: c.coordCtrl, decoration: deco("Coordonateur"))),
                const SizedBox(width: 10),
                Expanded(child: TextFormField(controller: c.adrCtrl, decoration: deco("Adresse (URL ou texte)"))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: numberField(c.frLivCtrl, "Fr Livraison (jour)")),
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
                    color: const Color(0xFF6C56B8),
                    trackColor: const Color(0xFFEDEAF6),
                    strokeWidth: 11,
                  ),
                  child: Center(
                    child: Text(
                      "$pct%",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          const Text("Satisfaction", style: TextStyle(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }

  // ---- Diffuseurs
  static Widget _diffuseursTable(List<ClientDiffuseurRow> rows, ClientDetailController c) {
    if (rows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("Aucun diffuseur."),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        showCheckboxColumn: false,
        columnSpacing: 24,
        headingRowColor: MaterialStateProperty.all(const Color(0xFF5DB7A1)),
        columns: const [
          DataColumn(label: _Head("CAB")),
          DataColumn(label: _Head("Modèle")),
          DataColumn(label: _Head("Type_Carte")),
          DataColumn(label: _Head("Emplacement")),
        ],
        rows: rows
            .map(
              (r) => DataRow(
                onSelectChanged: (_) => c.goToClientDiffuseur(r.id),
                cells: [
                  DataCell(Text(r.cab)),
                  DataCell(Text(r.modele)),
                  DataCell(Text(r.typeCarte)),
                  DataCell(Text(r.emplacement)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  // ---- Interventions
  static Widget _interventionsTable(List<InterventionRow> rows) {
    if (rows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("Aucune intervention."),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        showCheckboxColumn: false,
        columnSpacing: 20,
        headingRowColor: MaterialStateProperty.all(const Color(0xFF5DB7A1)),
        columns: const [
          DataColumn(label: _Head("Date")),
          DataColumn(label: _Head("Technicien")),
          DataColumn(label: _Head("Alertes")),
          DataColumn(label: _Head("Statut")),
        ],
        rows: rows
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
            .toList(),
      ),
    );
  }

  // ---- Réclamations
  static Widget _reclamationsTable(List<ReclamationRow> rows) {
    if (rows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("Aucune réclamation."),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        showCheckboxColumn: false,
        columnSpacing: 24,
        headingRowColor: MaterialStateProperty.all(const Color(0xFF5DB7A1)),
        columns: const [
          DataColumn(label: _Head("Date")),
          DataColumn(label: _Head("Problème")),
          DataColumn(label: _Head("Technicien")),
          DataColumn(label: _Head("Statut")),
        ],
        rows: rows.map((r) => DataRow(
          onSelectChanged: (_) => Get.toNamed('/reclamations/${r.id}'),
          cells: [
            DataCell(Text(r.date ?? "-")),
            DataCell(SizedBox(
              width: 260,
              child: Text(r.probleme ?? "-", overflow: TextOverflow.ellipsis),
            )),
            DataCell(Text(r.technicien ?? "-")),
            DataCell(Text(r.statut ?? "-")),
          ],
        )).toList(),
      ),
    );
  }


  // ---------------------------------------------------------------------------
  // helpers (styles)
  // ---------------------------------------------------------------------------

  static Widget _sectionContainer({required Widget child}) => ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 6),
              )
            ],
            border: Border.all(color: const Color(0x11000000)),
          ),
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      );

  static Widget _card(Widget child) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      );

  static Widget _sectionTitle(String t, {Widget? trailing}) => Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFF5DB7A1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const Spacer(),
          if (trailing != null) trailing,
        ],
      );
}

class _Head extends StatelessWidget {
  final String t;
  const _Head(this.t);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      );
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
