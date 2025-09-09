import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:front_erp_aromair/data/models/bouteille_detail.dart';
import 'package:front_erp_aromair/data/repositories/admin/BouteillesRepository.dart';
import 'package:front_erp_aromair/data/services/BouteillesService.dart';
import 'package:front_erp_aromair/view/widgets/admin_drawer.dart';
import 'package:get/get.dart';

class BouteilleDetailScreen extends StatelessWidget {
  final int bouteilleId;
  const BouteilleDetailScreen({super.key, required this.bouteilleId});

  @override
  Widget build(BuildContext context) {
    final tag = 'bt_$bouteilleId';
    return GetX<_BouteilleCtrl>(
      init: Get.put(_BouteilleCtrl(bouteilleId), tag: tag),
      tag: tag,
      builder: (c) {
        final d = c.dto.value;

        return Scaffold(
          drawer: const AdminDrawer(),
          appBar: AppBar(
            backgroundColor: const Color(0xFF75A6D1),
            centerTitle: true,
            title: const Text('Consulter Bouteille'),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: c.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : c.error.value != null
                            ? Center(child: Text('Erreur: ${c.error.value}'))
                            : d == null
                                ? const Center(child: Text('Aucune donnée'))
                                : SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // En-tête
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  _kv('Ref', d.cab),
                                                  _kv('Client', d.client),
                                                  _kv('Date de Fabrication', d.dateProd ?? '-'),
                                                  _kv('Date de mise en marche', d.dateMiseEnMarche ?? '-'),
                                                  Row(
                                                    children: [
                                                      const Text('Rythme Consommation / jour: '),
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                                        decoration: BoxDecoration(
                                                          border: Border.all(color: Colors.black26),
                                                          borderRadius: BorderRadius.circular(20),
                                                        ),
                                                        child: Text(d.rythmeConsomParJour == null
                                                            ? '-'
                                                            : '${d.rythmeConsomParJour}ml'),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  _kv('Diffuseur_emplacement', d.emplacement),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  _kv('Type', d.type),
                                                  _kv('Etat', d.etat),
                                                  _kv('Parfum', d.parfum),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 16),

                                        // Tableau quantités
                                        _sectionTitle('Bouteille'),
                                        const SizedBox(height: 8),
                                        _dataCard(
                                          child: Table(
                                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                            columnWidths: const {
                                              0: FlexColumnWidth(1.2),
                                              1: FlexColumnWidth(1),
                                              2: FlexColumnWidth(1),
                                              3: FlexColumnWidth(1),
                                              4: FlexColumnWidth(1.2),
                                            },
                                            children: [
                                              const TableRow(
                                                decoration: BoxDecoration(color: Color(0xFF5DB7A1)),
                                                children: [
                                                  _TH('Type'),
                                                  _TH('Quantité initiale'),
                                                  _TH('Quantité prévu'),
                                                  _TH('Quantité laissée'),
                                                  _TH('Parfum'),
                                                ],
                                              ),
                                              TableRow(
                                                children: [
                                                  _TD(d.type),
                                                  _TD(_ml(d.qteInitiale)),
                                                  _TD(_ml(d.qtePrevu)),
                                                  _TD(_ml(d.qteExistante)),
                                                  _TD(d.parfum),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 16),

                                        // Programmes
                                        _sectionTitle('Programmes'),
                                        const SizedBox(height: 8),
                                        _dataCard(
                                          child: d.programmes.isEmpty
                                              ? const Padding(
                                                  padding: EdgeInsets.all(16),
                                                  child: Text('Aucun programme.'),
                                                )
                                              : Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                                  child: Column(
                                                    children: d.programmes.map((p) {
                                                      String freq() {
                                                        final u = (p.unite ?? '').toLowerCase();
                                                        final unit = u.contains('minute') ? 'minute' : u;
                                                        if (p.tempsEnMarche == null || p.tempsDeRepos == null) return '-';
                                                        return '${p.tempsEnMarche}-${p.tempsDeRepos} $unit';
                                                      }
                                                      String _hm(String? t) {
                                                        if (t == null) return '-';
                                                        final parts = t.split(':');
                                                        if (parts.length < 2) return '-';
                                                        final h = int.tryParse(parts[0]) ?? 0;
                                                        final m = int.tryParse(parts[1]) ?? 0;
                                                        return '${h}h${m.toString().padLeft(2, '0')}';
                                                      }

                                                      return Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                                        child: Row(
                                                          children: [
                                                            Expanded(child: Text('Fréquence: ${freq()}')),
                                                            Expanded(child: Text('Plage: ${_hm(p.heureDebut)} → ${_hm(p.heureFin)}')),
                                                            Expanded(
                                                              child: Wrap(
                                                                spacing: 6,
                                                                runSpacing: 4,
                                                                children: p.joursActifs
                                                                    .map((j) => Chip(label: Text(j)))
                                                                    .toList(),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
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
        );
      },
    );
  }

  static Widget _sectionTitle(String t) => Row(
        children: [
          Container(width: 4, height: 18, decoration: BoxDecoration(color: Color(0xFF5DB7A1), borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ],
      );

  static Widget _dataCard({required Widget child}) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(12)),
          child: child,
        ),
      );

  static Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 14),
            children: [
              TextSpan(text: '$k: ', style: const TextStyle(fontWeight: FontWeight.w600)),
              TextSpan(text: v),
            ],
          ),
        ),
      );

  static String _ml(int? v) => v == null ? '-' : '${v}ml';
}

class _TH extends StatelessWidget {
  final String t;
  const _TH(this.t);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      );
}

class _TD extends StatelessWidget {
  final String t;
  const _TD(this.t);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text(t),
      );
}

class _BouteilleCtrl extends GetxController {
  final int id;
  _BouteilleCtrl(this.id);

  final isLoading = false.obs;
  final error = RxnString();
  final dto = Rxn<BouteilleDetail>();

  late final BouteillesRepository repo = BouteillesRepository(
    BouteillesService(
      Dio(BaseOptions(baseUrl: 'http://localhost:8089/aromair_erp/api/')),
    ),
  );

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    isLoading.value = true;
    error.value = null;
    try {
      dto.value = await repo.detail(id);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
