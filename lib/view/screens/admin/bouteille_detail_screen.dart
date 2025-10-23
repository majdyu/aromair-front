import 'package:flutter/material.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/data/models/bouteille_detail.dart';
import 'package:front_erp_aromair/data/repositories/admin/BouteillesRepository.dart';
import 'package:front_erp_aromair/data/services/BouteillesService.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_scaffold.dart';
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

        return AromaScaffold(
          title: "Détails de la Bouteille",

          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A1E40),
                  Color(0xFF152A51),
                  Color(0xFF1E3A8A),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 14000),
                  child: _buildContent(c, d),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(_BouteilleCtrl c, BouteilleDetail? d) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 16,
      shadowColor: Colors.black.withOpacity(0.3),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade50],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Header
              _buildHeader(c, d),
              const SizedBox(height: 32),

              if (c.isLoading.value)
                _buildLoadingState()
              else if (c.error.value != null)
                _buildErrorState(c)
              else if (d == null)
                _buildEmptyState()
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Informations Générales
                        _buildGeneralInfoSection(d),
                        const SizedBox(height: 32),

                        // Quantities Section
                        _buildQuantitiesSection(d),
                        const SizedBox(height: 32),

                        // Programmes Section
                        _buildProgrammesSection(d),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(_BouteilleCtrl c, BouteilleDetail? d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A1E40), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0A1E40).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.inventory_2_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Détails de la Bouteille",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0A1E40),
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    "Informations complètes et programmes de diffusion",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (!c.isLoading.value && c.error.value == null && d != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1E40).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF0A1E40).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.qr_code_2_rounded,
                      size: 18,
                      color: const Color(0xFF0A1E40).withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "REF: ${d.cab}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A1E40),
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0A1E40).withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF0A1E40),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.inventory_2_rounded,
                      color: const Color(0xFF0A1E40).withOpacity(0.3),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Chargement des détails...",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0A1E40),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Récupération des informations de la bouteille",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(_BouteilleCtrl c) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Erreur de chargement",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0A1E40),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                c.error.value!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: c.fetch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A1E40),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF0A1E40).withOpacity(0.3),
              ),
              child: const Text(
                "Réessayer",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0A1E40).withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 56,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Aucune donnée disponible",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0A1E40),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Les informations de cette bouteille ne sont pas disponibles",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralInfoSection(BouteilleDetail d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Informations Générales"),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _enhancedInfoRow("Référence", d.cab, Icons.qr_code_2_rounded),
                _divider(),
                _enhancedInfoRow("Client", d.client, Icons.business_rounded),
                _divider(),
                _enhancedInfoRow(
                  "Emplacement",
                  d.emplacement,
                  Icons.location_on_rounded,
                ),
                _divider(),
                _enhancedInfoRow("Type", d.type, Icons.category_rounded),
                _divider(),
                _enhancedInfoRow("État", d.etat, Icons.verified_rounded),
                _divider(),
                _enhancedInfoRow("Parfum", d.parfum, Icons.air_rounded),
                _divider(),
                _enhancedInfoRow(
                  "Date de Fabrication",
                  _formatDate(d.dateProd),
                  Icons.date_range_rounded,
                ),
                _divider(),
                _enhancedInfoRow(
                  "Date de mise en marche",
                  _formatDate(d.dateMiseEnMarche),
                  Icons.play_arrow_rounded,
                ),
                _divider(),
                _enhancedInfoRow(
                  "Rythme de consommation/jour",
                  d.rythmeConsomParJour != null
                      ? "${d.rythmeConsomParJour} ml"
                      : "-",
                  Icons.timeline_rounded,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitiesSection(BouteilleDetail d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Quantités"),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
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
                    color: const Color(0xFF0A1E40).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  children: [
                    _enhancedTableHeader("Type", Icons.category_rounded),
                    _enhancedTableHeader(
                      "Quantité initiale",
                      Icons.inventory_2_rounded,
                    ),
                    _enhancedTableHeader(
                      "Quantité prévue",
                      Icons.analytics_rounded,
                    ),
                    _enhancedTableHeader(
                      "Quantité restante",
                      Icons.production_quantity_limits,
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    _enhancedTableCell(d.type, isPrimary: true),
                    _enhancedTableCell(_ml(d.qteInitiale)),
                    _enhancedTableCell(_ml(d.qtePrevu)),
                    _enhancedTableCell(_ml(d.qteExistante), isHighlight: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgrammesSection(BouteilleDetail d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Programmes de Diffusion"),
        const SizedBox(height: 20),
        if (d.programmes.isEmpty)
          _buildEmptyProgrammes()
        else
          Column(
            children: d.programmes.asMap().entries.map((entry) {
              final index = entry.key;
              final programme = entry.value;
              return _enhancedProgrammeCard(programme, index);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyProgrammes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF0A1E40).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.schedule_rounded,
              size: 40,
              color: const Color(0xFF0A1E40).withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Aucun programme configuré",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0A1E40),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Ajoutez des programmes pour automatiser la diffusion des parfums",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _enhancedProgrammeCard(ProgrammeRow programme, int index) {
    final cardColors = [
      [Color(0xFF0A1E40), Color(0xFF1E3A8A)],
      [Color(0xFF1E3A8A), Color(0xFF3730A3)],
      [Color(0xFF152A51), Color(0xFF0A1E40)],
    ];
    final colors = cardColors[index % cardColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Programme Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.schedule_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Programme ${index + 1}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatFrequency(programme),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Actif",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Programme Details
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time Range
                _enhancedProgrammeDetail(
                  Icons.access_time_rounded,
                  "Plage horaire",
                  "${_formatTime(programme.heureDebut)} - ${_formatTime(programme.heureFin)}",
                  Colors.blue.shade600,
                ),
                const SizedBox(height: 20),

                // Active Days
                _enhancedProgrammeDetail(
                  Icons.calendar_month_rounded,
                  "Jours d'activation",
                  "",
                  Colors.green.shade600,
                ),
                const SizedBox(height: 12),
                _buildEnhancedDayChips(programme.joursActifs),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _enhancedProgrammeDetail(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              if (value.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
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

  Widget _buildEnhancedDayChips(List<String> joursActifs) {
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

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: days.map((day) {
        final isActive = joursActifs.any(
          (activeDay) => fullDays[days.indexOf(day)] == activeDay,
        );

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0A1E40) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? const Color(0xFF0A1E40) : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF0A1E40).withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isActive)
                Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
              if (isActive) const SizedBox(width: 6),
              Text(
                day,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 24,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0A1E40), Color(0xFF1E3A8A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A1E40),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _enhancedInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF0A1E40).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF0A1E40)),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF0A1E40),
              fontSize: 15,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _enhancedTableHeader(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0A1E40)),
          const SizedBox(width: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A1E40),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _enhancedTableCell(
    String text, {
    bool isPrimary = false,
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isHighlight
              ? const Color(0xFF0A1E40)
              : isPrimary
              ? const Color(0xFF1E3A8A)
              : Colors.grey.shade700,
          fontWeight: isHighlight || isPrimary
              ? FontWeight.w700
              : FontWeight.w500,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: 1,
      color: Colors.grey.shade200,
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
    BouteillesService(buildDio()),
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
      print("Fetched dto: ${dto.value}");
    } catch (e) {
      print("Error fetching bouteille detail: $e");
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
