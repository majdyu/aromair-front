import 'package:flutter/material.dart';
import 'package:front_erp_aromair/data/models/client.dart';
import 'package:front_erp_aromair/data/repositories/admin/client_repository.dart';
import 'package:front_erp_aromair/data/services/client_service.dart';
import 'package:front_erp_aromair/routes/app_routes.dart';
import 'package:front_erp_aromair/viewmodel/admin/client_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:front_erp_aromair/theme/colors.dart';
import 'package:front_erp_aromair/view/widgets/common/aroma_scaffold.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});
  static const natureOptions = ["ENTREPRISE", "PARTICULIER"];
  static const typeOptions = ["ACHAT", "CONVENTION", "MAD"];
  static const importanceOptions = ["ELEVE", "MOYENNE", "FAIBLE"];
  static const algoOptions = ["FREQUENCE_PLAN", "SUR_COMMANDE"];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientController>(
      init: ClientController(ClientRepository(ClientService())),
      builder: (c) {
        return AromaScaffold(
          title: "Clients",
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Nouveau client",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => _openCreateClientSheet(context, c),
          ),
          onRefresh: c.fetch,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A1E40).withOpacity(0.02),
                  Color(0xFF0A1E40).withOpacity(0.01),
                  Colors.white,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // ===== ELEGANT HEADER =====
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF0A1E40).withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Title with elegant icon
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF0A1E40),
                                    Color(0xFF1E3A8A),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.business_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Gestion des Clients",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0A1E40),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  "Administration et suivi de votre portefeuille clients",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),

                            // Stats with elegant design
                            Obx(() {
                              if (c.isLoading.value || c.error.value != null)
                                return const SizedBox.shrink();
                              return Row(
                                children: [
                                  _elegantStat(
                                    value: c.filteredItems.length.toString(),
                                    label: "Total",
                                    color: Color(0xFF0A1E40),
                                  ),
                                  const SizedBox(width: 16),
                                  _elegantStat(
                                    value: c.filteredItems
                                        .where((client) => client.estActive)
                                        .length
                                        .toString(),
                                    label: "Actifs",
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 16),
                                  _elegantStat(
                                    value: c.filteredItems
                                        .where((client) => !client.estActive)
                                        .length
                                        .toString(),
                                    label: "Suspendus",
                                    color: AppColors.danger,
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ===== CREATIVE FILTER BAR =====
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              // Search with elegant design
                              Expanded(
                                flex: 3,
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    controller: c.searchCtrl,
                                    decoration: InputDecoration(
                                      hintText: "Rechercher un client...",
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade500,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search_rounded,
                                        color: Colors.grey.shade500,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Type filter
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2<String>(
                                      isExpanded: true,
                                      value: c.type?.toUpperCase(),
                                      hint: Text(
                                        "Type de client",
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'ACHAT',
                                          child: Text('ACHAT'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'CONVENTION',
                                          child: Text('CONVENTION'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'MAD',
                                          child: Text('MAD'),
                                        ),
                                      ],
                                      onChanged: (v) => c.setType(v),
                                      buttonStyleData: const ButtonStyleData(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        height: 48,
                                      ),
                                      iconStyleData: const IconStyleData(
                                        icon: Icon(Icons.expand_more_rounded),
                                      ),
                                      dropdownStyleData: DropdownStyleData(
                                        width: 200,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Status filter
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2<String>(
                                      isExpanded: true,
                                      value: c.activeFilter.value,
                                      hint: Text(
                                        "Statut client",
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'ALL',
                                          child: Text('Tous les statuts'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'ACTIVE',
                                          child: Text('Actifs uniquement'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'INACTIVE',
                                          child: Text('Suspendus uniquement'),
                                        ),
                                      ],
                                      onChanged: (v) {
                                        if (v != null) c.setActiveFilter(v);
                                      },
                                      buttonStyleData: const ButtonStyleData(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        height: 48,
                                      ),
                                      iconStyleData: const IconStyleData(
                                        icon: Icon(Icons.expand_more_rounded),
                                      ),
                                      dropdownStyleData: DropdownStyleData(
                                        width: 200,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ===== ELEGANT CLIENT LIST =====
                  Expanded(
                    child: Obx(() {
                      if (c.isLoading.value) return _buildElegantLoading();
                      if (c.error.value != null) return _buildElegantError();

                      final list = c.filteredItems;
                      if (list.isEmpty) return _buildElegantEmpty();

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final client = list[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ElegantClientCard(
                              client: client,
                              onView: () => Get.toNamed(
                                AppRoutes.detailClient,
                                arguments: {'id': client.id},
                              ),
                              onToggleStatus: (_) => c.onToggleActive(client),
                              onDelete: () =>
                                  print("Delete client: ${client.nom}"),
                              isBusy: c.isToggling(client.id),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _elegantStat({
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElegantLoading() {
    return Center(
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
                  color: Color(0xFF0A1E40).withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A1E40)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Chargement des clients...",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElegantError() {
    return Center(
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
                  color: Color(0xFF0A1E40).withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Erreur de chargement",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Veuillez réessayer ultérieurement",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildElegantEmpty() {
    return Center(
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
                  color: Color(0xFF0A1E40).withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.business_outlined,
              size: 56,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Aucun client trouvé",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Aucun client ne correspond à vos critères de recherche",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _ElegantClientCard extends StatelessWidget {
  final ClientRow client;
  final VoidCallback onView;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleStatus;
  final bool isBusy;

  const _ElegantClientCard({
    required this.client,
    required this.onView,
    required this.onDelete,
    required this.onToggleStatus,
    required this.isBusy,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    final dateStr = client.derniereIntervention != null
        ? fmt.format(client.derniereIntervention!)
        : 'N/A';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Color(0xFF0A1E40).withOpacity(0.05),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Stack(
          children: [
            // Elegant status accent
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _statusColor(client.estActive),
                      _statusColor(client.estActive).withOpacity(0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Status icon with elegant background
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          _statusColor(client.estActive).withOpacity(0.2),
                          _statusColor(client.estActive).withOpacity(0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(client.estActive),
                      color: _statusColor(client.estActive),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Main content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Client name
                        Text(
                          client.nom,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Details row
                        Row(
                          children: [
                            // Client type
                            Row(
                              children: [
                                Icon(
                                  Icons.category_rounded,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _typeLabel(client.type),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),

                            // Last intervention date
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  dateStr,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status and actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(
                            client.estActive,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _statusColor(
                              client.estActive,
                            ).withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          client.estActive ? "Actif" : "Suspendu",
                          style: TextStyle(
                            color: _statusColor(client.estActive),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Elegant action buttons and toggle
                      Row(
                        children: [
                          // Status toggle with loading state
                          Column(
                            children: [
                              Container(
                                width: 44,
                                height: 24,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _statusColor(
                                      client.estActive,
                                    ).withOpacity(0.3),
                                  ),
                                ),
                                child: Switch(
                                  value: client.estActive,
                                  onChanged: isBusy ? null : onToggleStatus,
                                  activeColor: AppColors.success,
                                  activeTrackColor: AppColors.success
                                      .withOpacity(0.3),
                                  inactiveThumbColor: AppColors.danger,
                                  inactiveTrackColor: AppColors.danger
                                      .withOpacity(0.3),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (isBusy)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),

                          // View details button
                          _elegantActionButton(
                            icon: Icons.visibility_rounded,
                            color: Color(0xFF0A1E40),
                            onTap: onView,
                            tooltip: "Voir les détails",
                          ),
                          const SizedBox(width: 8),

                          // Delete button
                          _elegantActionButton(
                            icon: Icons.delete_rounded,
                            color: AppColors.danger,
                            onTap: onDelete,
                            tooltip: "Supprimer",
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _elegantActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          onPressed: onTap,
          icon: Icon(icon, size: 20, color: color),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  IconData _getStatusIcon(bool isActive) {
    return isActive ? Icons.check_circle_rounded : Icons.pause_circle_rounded;
  }

  Color _statusColor(bool isActive) {
    return isActive ? AppColors.success : AppColors.danger;
  }

  String _typeLabel(TypeClient type) {
    switch (type) {
      case TypeClient.achat:
        return 'ACHAT';
      case TypeClient.convention:
        return 'CONVENTION';
      case TypeClient.mad:
        return 'MAD';
      case TypeClient.unknown:
        return 'INCONNU';
    }
  }
}

void _openCreateClientSheet(BuildContext context, ClientController c) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return _CreateClientSheet(
        onSubmit: (payload) async {
          await c.createClient(payload); // calls repo + refresh + snackbars
        },
      );
    },
  );
}

class _CreateClientSheet extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic>) onSubmit;
  const _CreateClientSheet({required this.onSubmit});

  @override
  State<_CreateClientSheet> createState() => _CreateClientSheetState();
}

class _CreateClientSheetState extends State<_CreateClientSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  // Text fields
  final _nom = TextEditingController();
  final _telephone = TextEditingController();
  final _coordonateur = TextEditingController();
  final _adresse = TextEditingController();
  final _freqLivraison = TextEditingController();
  final _freqVisite = TextEditingController();

  // Selects
  String? _nature = ClientsScreen.natureOptions.first;
  String? _type = ClientsScreen.typeOptions.first;
  String? _importance = ClientsScreen.importanceOptions.first;
  String? _algo = ClientsScreen.algoOptions.first;

  @override
  void dispose() {
    _nom.dispose();
    _telephone.dispose();
    _coordonateur.dispose();
    _adresse.dispose();
    _freqLivraison.dispose();
    _freqVisite.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final freqLiv = int.tryParse(_freqLivraison.text.trim());
    final freqVis = int.tryParse(_freqVisite.text.trim());

    final payload = <String, dynamic>{
      "nature": _nature,
      "type": _type,
      "nom": _nom.text.trim(),
      "telephone": _telephone.text.trim(),
      "coordonateur": _coordonateur.text.trim(),
      "adresse": _adresse.text.trim(),
      if (freqLiv != null) "frequenceLivraisonParJour": freqLiv,
      if (freqVis != null) "frequenceVisiteParJour": freqVis,
      "importance": _importance,
      "algoPlan": _algo,
    };

    setState(() => _submitting = true);
    try {
      await widget.onSubmit(payload);
      if (mounted) Navigator.of(context).pop(); // close on success
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF0A1E40), width: 2),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    labelStyle: TextStyle(
      color: Colors.grey.shade600,
      fontWeight: FontWeight.w500,
      fontSize: 15,
    ),
    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
    floatingLabelBehavior: FloatingLabelBehavior.auto,
  );

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          value: value,
          hint: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          buttonStyleData: const ButtonStyleData(
            height: 56,
            padding: EdgeInsets.symmetric(horizontal: 20),
          ),
          iconStyleData: IconStyleData(
            icon: Icon(
              Icons.expand_more_rounded,
              color: Colors.grey.shade600,
              size: 24,
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x330A1E40),
                blurRadius: 32,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            child: Material(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Enhanced Drag handle
                    Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Enhanced Header
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0A1E40), Color(0xFF1E3A8A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E3A8A).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_add_alt_1_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Nouveau Client",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0A1E40),
                                  letterSpacing: -0.5,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Remplissez les informations du client",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Enhanced Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // First row - Nature and Type
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 4,
                                        bottom: 8,
                                      ),
                                      child: Text(
                                        "Nature",
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    _dropdown(
                                      label: "Sélectionner la nature",
                                      value: _nature,
                                      items: ClientsScreen.natureOptions,
                                      onChanged: (v) =>
                                          setState(() => _nature = v),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 4,
                                        bottom: 8,
                                      ),
                                      child: Text(
                                        "Type",
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    _dropdown(
                                      label: "Sélectionner le type",
                                      value: _type,
                                      items: ClientsScreen.typeOptions,
                                      onChanged: (v) =>
                                          setState(() => _type = v),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Nom field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  bottom: 8,
                                ),
                                child: Text(
                                  "Nom du client *",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: _nom,
                                decoration: _dec("Entrez le nom du client"),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? "Ce champ est requis"
                                    : null,
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Telephone and Coordonateur row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 4,
                                        bottom: 8,
                                      ),
                                      child: Text(
                                        "Téléphone *",
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _telephone,
                                      decoration: _dec(
                                        "Numéro de téléphone",
                                        hint: "ex: 70689027",
                                      ),
                                      keyboardType: TextInputType.phone,
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                          ? "Ce champ est requis"
                                          : null,
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 4,
                                        bottom: 8,
                                      ),
                                      child: Text(
                                        "Coordonateur *",
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _coordonateur,
                                      decoration: _dec("Nom du coordonateur"),
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                          ? "Ce champ est requis"
                                          : null,
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Adresse field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  bottom: 8,
                                ),
                                child: Text(
                                  "Adresse *",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: _adresse,
                                decoration: _dec(
                                  "Adresse complète ou lien Maps",
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? "Ce champ est requis"
                                    : null,
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Frequency row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 4,
                                        bottom: 8,
                                      ),
                                      child: Text(
                                        "Fréquence Livraison/jour",
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _freqLivraison,
                                      decoration: _dec(
                                        "Nombre de livraisons",
                                        hint: "ex: 30",
                                      ),
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 4,
                                        bottom: 8,
                                      ),
                                      child: Text(
                                        "Fréquence Visite/jour",
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _freqVisite,
                                      decoration: _dec(
                                        "Nombre de visites",
                                        hint: "ex: 45",
                                      ),
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Importance and Algo row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 4,
                                        bottom: 8,
                                      ),
                                      child: Text(
                                        "Importance",
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    _dropdown(
                                      label: "Niveau d'importance",
                                      value: _importance,
                                      items: ClientsScreen.importanceOptions,
                                      onChanged: (v) =>
                                          setState(() => _importance = v),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 4,
                                        bottom: 8,
                                      ),
                                      child: Text(
                                        "Algorithme de plan",
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    _dropdown(
                                      label: "Sélectionner l'algorithme",
                                      value: _algo,
                                      items: ClientsScreen.algoOptions,
                                      onChanged: (v) =>
                                          setState(() => _algo = v),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Enhanced Actions
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _submitting
                                        ? null
                                        : () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      side: BorderSide(
                                        color: const Color(
                                          0xFF0A1E40,
                                        ).withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      backgroundColor: Colors.transparent,
                                    ),
                                    child: Text(
                                      "Annuler",
                                      style: TextStyle(
                                        color: const Color(0xFF0A1E40),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _submitting ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0A1E40),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 4,
                                      shadowColor: const Color(
                                        0xFF0A1E40,
                                      ).withOpacity(0.3),
                                    ),
                                    child: _submitting
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : Text(
                                            "Créer le client",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
