import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:front_erp_aromair/data/models/bouteille_detail.dart';
import 'package:front_erp_aromair/data/repositories/admin/BouteillesRepository.dart';
import 'package:front_erp_aromair/data/services/BouteillesService.dart';
import 'package:front_erp_aromair/view/widgets/admin_drawer.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
            backgroundColor: const Color(0xFF0A1E40),
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "Détails de la Bouteille",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
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
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: SizedBox(
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 12,
                    shadowColor: Colors.black.withOpacity(0.4),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              const Icon(
                                Icons.local_drink,
                                color: Color(0xFF0A1E40),
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Détails de la Bouteille",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0A1E40),
                                ),
                              ),
                              const Spacer(),
                              if (!c.isLoading.value &&
                                  c.error.value == null &&
                                  d != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF0A1E40,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    "Ref: ${d.cab}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF0A1E40),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Informations détaillées sur la bouteille",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 24),

                          if (c.isLoading.value)
                            const Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF0A1E40),
                                      ),
                                      strokeWidth: 3,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      "Chargement des détails...",
                                      style: TextStyle(
                                        color: Color(0xFF0A1E40),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else if (c.error.value != null)
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red.shade400,
                                      size: 52,
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
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                      ),
                                      child: Text(
                                        c.error.value!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: c.fetch,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF0A1E40,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        elevation: 2,
                                      ),
                                      child: const Text("Réessayer"),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else if (d == null)
                            const Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      color: Colors.grey,
                                      size: 64,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      "Aucune donnée disponible",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Color(0xFF0A1E40),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Informations principales
                                    _sectionTitle("Informations Générales"),
                                    const SizedBox(height: 16),
                                    _infoCard(
                                      child: Column(
                                        children: [
                                          _infoRow("Référence", d.cab),
                                          _infoRow("Client", d.client),
                                          _infoRow(
                                            "Emplacement",
                                            d.emplacement,
                                          ),
                                          _infoRow("Type", d.type),
                                          _infoRow("État", d.etat),
                                          _infoRow("Parfum", d.parfum),
                                          _infoRow(
                                            "Date de Fabrication",
                                            _formatDate(d.dateProd),
                                          ),
                                          _infoRow(
                                            "Date de mise en marche",
                                            _formatDate(d.dateMiseEnMarche),
                                          ),
                                          _infoRow(
                                            "Rythme de consommation/jour",
                                            d.rythmeConsomParJour != null
                                                ? "${d.rythmeConsomParJour} ml"
                                                : "-",
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Informations sur les quantités
                                    _sectionTitle("Quantités"),
                                    const SizedBox(height: 16),
                                    _infoCard(
                                      child: Table(
                                        columnWidths: const {
                                          0: FlexColumnWidth(2),
                                          1: FlexColumnWidth(1.5),
                                          2: FlexColumnWidth(1.5),
                                          3: FlexColumnWidth(1.5),
                                        },
                                        children: [
                                          TableRow(
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF0A1E40,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            children: [
                                              _tableHeader("Type"),
                                              _tableHeader("Quantité initiale"),
                                              _tableHeader("Quantité prévue"),
                                              _tableHeader("Quantité restante"),
                                            ],
                                          ),
                                          TableRow(
                                            children: [
                                              _tableCell(d.type),
                                              _tableCell(_ml(d.qteInitiale)),
                                              _tableCell(_ml(d.qtePrevu)),
                                              _tableCell(_ml(d.qteExistante)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Programmes
                                    // Programme Section - Replace the existing code with this
                                    _sectionTitle("Programmes"),
                                    const SizedBox(height: 16),
                                    if (d.programmes.isEmpty)
                                      _emptyProgrammesCard()
                                    else
                                      Column(
                                        children: d.programmes
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                              final index = entry.key;
                                              final programme = entry.value;
                                              return _programmeCard(
                                                programme,
                                                index,
                                              );
                                            })
                                            .toList(),
                                      ),
                                  ],
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

  Widget _emptyProgrammesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.schedule, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            "Aucun programme configuré",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Ajoutez des programmes pour automatiser la diffusion",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _programmeCard(ProgrammeRow programme, int index) {
    final cardColors = [
      const Color(0xFF0A1E40).withOpacity(0.8),
      const Color(0xFF1E3A8A).withOpacity(0.8),
      const Color(0xFF152A51).withOpacity(0.8),
    ];
    final color = cardColors[index % cardColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Programme Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Programme ${index + 1}",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatFrequency(programme),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Programme Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time Range
                _programmeDetailRow(
                  Icons.access_time,
                  "Plage horaire",
                  "${_formatTime(programme.heureDebut)} - ${_formatTime(programme.heureFin)}",
                ),
                const SizedBox(height: 12),

                // Active Days
                _programmeDetailRow(Icons.calendar_today, "Jours actifs", ""),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _buildDayChips(programme.joursActifs),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _programmeDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0A1E40).withOpacity(0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              if (value.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDayChips(List<String> joursActifs) {
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final fullDays = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];

    return days.map((day) {
      final isActive = joursActifs.any(
        (activeDay) => fullDays[days.indexOf(day)] == activeDay,
      );

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF0A1E40).withOpacity(0.9)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? const Color(0xFF0A1E40) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          day,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      );
    }).toList();
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
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0A1E40),
          ),
        ),
      ],
    );
  }

  Widget _infoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF0A1E40),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF0A1E40),
        ),
      ),
    );
  }

  Widget _tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(text, style: TextStyle(color: Colors.grey.shade700)),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return "-";
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  String _formatTime(String? time) {
    if (time == null) return "-";
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}h${parts[1]}';
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  String _formatFrequency(dynamic programme) {
    if (programme.tempsEnMarche == null || programme.tempsDeRepos == null)
      return "-";

    final unit = (programme.unite ?? '').toLowerCase().contains('minute')
        ? 'min'
        : 'h';
    return '${programme.tempsEnMarche}$unit marche / ${programme.tempsDeRepos}$unit repos';
  }

  String _ml(int? value) => value == null ? "-" : "${value}ml";
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
