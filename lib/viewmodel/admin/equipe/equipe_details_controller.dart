import 'package:flutter/material.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/data/repositories/admin/equipe_repository.dart';
import 'package:front_erp_aromair/data/services/equipe_service.dart';
import 'package:front_erp_aromair/data/models/equipe.dart';
import 'package:front_erp_aromair/routes/app_routes.dart';
import 'package:get/get.dart';

class EquipeDetailsController extends GetxController {
  late final EquipesRepository _repo = EquipesRepository(
    EquipesService(buildDio()),
  );

  final equipe = Rx<Equipe?>(null);
  final isLoading = false.obs;

  int? _equipeId;

  @override
  void onInit() {
    super.onInit();
    _loadFromArgs();
  }

  void consultTechnicien(BuildContext context, dynamic technicienId) {
    Get.toNamed(
      AppRoutes.technicienConsultation,
      arguments: {'technicienId': technicienId},
    );
  }

  void _loadFromArgs() async {
    final args = Get.arguments as Map<String, dynamic>?;

    if (args != null && args['equipeId'] != null) {
      _equipeId = args['equipeId'] as int?;
      if (_equipeId != null) await fetch(_equipeId!);
    }
  }

  Future<void> refreshFromServer() async {
    if (_equipeId == null) {
      Get.snackbar(
        'Info',
        'Identifiant d\'équipe introuvable pour rafraîchir.',
      );
      return;
    }
    await fetch(_equipeId!);
  }

  Future<void> fetch(int id) async {
    try {
      isLoading.value = true;
      update();
      final res = await _repo.getById(id);
      equipe.value = res;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger l\'équipe: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // ========= ELEGANT EDIT DIALOG =========

  Future<void> openEditEquipeDialog(BuildContext context) async {
    final e = equipe.value;
    if (e == null) return;

    final nameCtrl = TextEditingController(text: e.nom);
    final descCtrl = TextEditingController(text: e.description ?? '');
    int? selectedChefId = e.chefId;

    final saved = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Elegant Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Modifier l'équipe",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Mettez à jour les informations de l'équipe",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      // Team Name Field
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: nameCtrl,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            labelText: "Nom de l'équipe",
                            labelStyle: TextStyle(color: Colors.grey.shade600),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(12),
                              child: Icon(
                                Icons.badge_rounded,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Description Field
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: descCtrl,
                          minLines: 3,
                          maxLines: 4,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            labelText: "Description",
                            labelStyle: TextStyle(color: Colors.grey.shade600),
                            alignLabelWithHint: true,
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(12),
                              child: Icon(
                                Icons.description_outlined,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Team Leader Selection
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "CHEF D'ÉQUIPE",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: DropdownButtonFormField<int>(
                              value: selectedChefId,
                              isExpanded: true,
                              dropdownColor: Colors.white,
                              icon: Icon(
                                Icons.arrow_drop_down_rounded,
                                color: Colors.grey.shade600,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                prefixIcon: Icon(Icons.verified_user_rounded),
                              ),
                              items: [
                                DropdownMenuItem<int>(
                                  value: null,
                                  child: Text(
                                    '— Aucun chef —',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                                ...e.membres.map<DropdownMenuItem<int>>(
                                  (m) => DropdownMenuItem(
                                    value: m.id,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF667eea,
                                            ).withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.person_rounded,
                                            size: 16,
                                            color: const Color(0xFF667eea),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          m.nom,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (v) => selectedChefId = v,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Elegant Footer
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade100)),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(result: false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          "Annuler",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667eea),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          shadowColor: const Color(0xFF667eea).withOpacity(0.3),
                        ),
                        child: const Text(
                          "Enregistrer",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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
      ),
    );

    if (saved == true) {
      final nom = nameCtrl.text.trim();
      if (nom.isEmpty) {
        _showElegantSnackbar('Validation', 'Le nom est obligatoire', false);
        return;
      }
      await _applyPatch(
        e.id,
        nom: nom,
        description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
        chefId: selectedChefId,
        successMsg: 'Équipe mise à jour avec succès',
      );
    }
  }

  // ========= ELEGANT CHEF SELECTION =========
  // ========= ELEGANT CHEF SELECTION =========

  Future<void> pickChefFlow(BuildContext context) async {
    final e = equipe.value;
    if (e == null || e.membres.isEmpty) return;

    int? selectedId = e.chefId;

    final res = await showDialog<int?>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
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
                          child: const Icon(
                            Icons.verified_user_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Choisir un chef",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            "Sélectionnez le chef d'équipe parmi les membres",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: e.membres.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (_, i) {
                                final m = e.membres[i];
                                final isSelected = selectedId == m.id;
                                return _ElegantMemberTile(
                                  member: m,
                                  isSelected: isSelected,
                                  isCurrentChef: e.chefId == m.id,
                                  onTap: () {
                                    setState(() {
                                      selectedId = m.id;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade100),
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(result: null),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Annuler"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Get.back(result: selectedId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFf5576c),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Confirmer",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (res != null) {
      await _applyPatch(
        e.id,
        chefId: res,
        successMsg: "Chef d'équipe mis à jour",
      );
    }
  }

  // ========= ELEGANT ADD MEMBERS =========
  Future<void> addMembersFlow(BuildContext context) async {
    final e = equipe.value;
    if (e == null) return;

    final isLoadingMembers = false.obs;
    final selectable = <UserLite>[].obs;
    final selected = <int>{}.obs;

    // Load members function
    Future<void> loadSelectableMembers() async {
      try {
        isLoadingMembers.value = true;
        final raw = await _repo.listTechniciensEl();

        final currentIds = _currentMemberIds().toSet();
        selectable.value = raw
            .map(
              (m) => UserLite(
                id: (m['id'] as num).toInt(),
                nom: (m['nom'] ?? '').toString(),
              ),
            )
            .where((u) => !currentIds.contains(u.id))
            .toList();
      } catch (err) {
        _showElegantSnackbar(
          'Erreur',
          'Impossible de charger les techniciens: $err',
          false,
        );
      } finally {
        isLoadingMembers.value = false;
      }
    }

    // Initial load
    await loadSelectableMembers();

    // Show the bottom sheet
    final ids = await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              height: MediaQuery.of(context).size.height * 0.85,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Header
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Ajouter des membres",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          // Refresh button
                          Obx(
                            () => isLoadingMembers.value
                                ? const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    onPressed: loadSelectableMembers,
                                    icon: Icon(
                                      Icons.refresh_rounded,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Rechercher un technicien...",
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Colors.grey.shade500,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onChanged: (value) {
                            // You can implement search functionality here
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Selection Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selected.isEmpty
                              ? Colors.blue.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected.isEmpty
                                ? Colors.blue.shade100
                                : Colors.green.shade100,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selected.isEmpty
                                  ? Icons.info_outline_rounded
                                  : Icons.check_circle_rounded,
                              color: selected.isEmpty
                                  ? Colors.blue.shade600
                                  : Colors.green.shade600,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selected.isEmpty
                                    ? "Sélectionnez les techniciens à ajouter"
                                    : "${selected.length} technicien(s) sélectionné(s)",
                                style: TextStyle(
                                  color: selected.isEmpty
                                      ? Colors.blue.shade700
                                      : Colors.green.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (selected.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selected.clear();
                                  });
                                },
                                child: Text(
                                  "Tout effacer",
                                  style: TextStyle(
                                    color: Colors.green.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Members List
                      Expanded(
                        child: Obx(() {
                          if (isLoadingMembers.value) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "Chargement des techniciens...",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (selectable.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline_rounded,
                                    size: 64,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Aucun technicien disponible",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Tous les techniciens sont déjà membres de cette équipe",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: loadSelectableMembers,
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: const Text("Actualiser"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade50,
                                      foregroundColor: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                // List Header
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Techniciens disponibles (${selectable.length})",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        "${selected.length} sélectionné(s)",
                                        style: TextStyle(
                                          color: Colors.green.shade600,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Members List
                                Expanded(
                                  child: ListView.separated(
                                    padding: const EdgeInsets.all(0),
                                    itemCount: selectable.length,
                                    separatorBuilder: (_, __) => Divider(
                                      height: 1,
                                      color: Colors.grey.shade100,
                                    ),
                                    itemBuilder: (_, i) {
                                      final u = selectable[i];
                                      final checked = selected.contains(u.id);
                                      return Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              if (checked) {
                                                selected.remove(u.id);
                                              } else {
                                                selected.add(u.id);
                                              }
                                            });
                                          },
                                          child: Container(
                                            color: checked
                                                ? Colors.blue.shade50
                                                : Colors.white,
                                            child: ListTile(
                                              leading: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  gradient: checked
                                                      ? const LinearGradient(
                                                          colors: [
                                                            Color(0xFF4facfe),
                                                            Color(0xFF00f2fe),
                                                          ],
                                                        )
                                                      : LinearGradient(
                                                          colors: [
                                                            Colors
                                                                .grey
                                                                .shade300,
                                                            Colors
                                                                .grey
                                                                .shade400,
                                                          ],
                                                        ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    _getUserInitials(u.nom),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              title: Text(
                                                u.nom,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: checked
                                                      ? Colors.blue.shade800
                                                      : Colors.black87,
                                                ),
                                              ),
                                              trailing: Checkbox(
                                                value: checked,
                                                onChanged: (v) {
                                                  setState(() {
                                                    if (v == true) {
                                                      selected.add(u.id);
                                                    } else {
                                                      selected.remove(u.id);
                                                    }
                                                  });
                                                },
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                fillColor:
                                                    MaterialStateProperty.resolveWith<
                                                      Color
                                                    >((states) {
                                                      if (states.contains(
                                                        MaterialState.selected,
                                                      )) {
                                                        return const Color(
                                                          0xFF4facfe,
                                                        );
                                                      }
                                                      return Colors
                                                          .grey
                                                          .shade400;
                                                    }),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                "Annuler",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: selected.isEmpty
                                  ? null
                                  : () => Get.back(result: selected.toList()),
                              icon: const Icon(
                                Icons.person_add_alt_1_rounded,
                                size: 20,
                              ),
                              label: Text(
                                "Ajouter (${selected.length})",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selected.isEmpty
                                    ? Colors.grey.shade300
                                    : const Color(0xFF4facfe),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: selected.isEmpty ? 0 : 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    // Process the selection
    if (ids != null && ids.isNotEmpty) {
      try {
        isLoading.value = true;
        update();

        final currentIds = _currentMemberIds().toSet();
        final next = {...currentIds, ...ids}.toList();

        await _applyPatch(
          e.id,
          userIds: next,
          successMsg: '${ids.length} membre(s) ajouté(s) à l\'équipe',
        );
      } catch (err) {
        _showElegantSnackbar(
          'Erreur',
          'Impossible d\'ajouter les membres: $err',
          false,
        );
      } finally {
        isLoading.value = false;
        update();
      }
    }
  }

  // Helper function for user initials
  String _getUserInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final s = parts.first;
      return s.isEmpty
          ? '?'
          : s.substring(0, s.length < 2 ? s.length : 2).toUpperCase();
    }
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.last.isNotEmpty ? parts.last[0] : '';
    return '${first}${last}'.toUpperCase();
  }

  Future<void> memberMenuAction(
    BuildContext context,
    String action,
    int memberId,
  ) async {
    final e = equipe.value;
    if (e == null) return;

    if (action == 'remove') {
      final member = e.membres.firstWhere((m) => m.id == memberId);
      final ok = await _showElegantConfirmDialog(
        context,
        title: "Retirer le membre",
        message: "Voulez-vous vraiment retirer ${member.nom} de l'équipe ?",
        confirmText: "Retirer",
        isDestructive: true,
      );
      if (!ok) return;

      final currentIds = _currentMemberIds();
      final nextIds = currentIds.where((id) => id != memberId).toList();
      final newChefId = (e.chefId != null && e.chefId == memberId)
          ? null
          : e.chefId;

      await _applyPatch(
        e.id,
        userIds: nextIds,
        chefId: newChefId,
        successMsg: 'Membre retiré de l\'équipe',
      );
      return;
    }

    if (action == 'chef') {
      await _applyPatch(
        e.id,
        chefId: memberId,
        successMsg: "Chef d'équipe désigné",
      );
    }
  }

  // ========= ELEGANT HELPERS =========

  Future<bool> _showElegantConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    bool isDestructive = false,
  }) async {
    final r = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? const Color(0xFFfee2e2)
                      : const Color(0xFFdbeafe),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDestructive
                      ? Icons.warning_amber_rounded
                      : Icons.help_rounded,
                  color: isDestructive
                      ? const Color(0xFFdc2626)
                      : const Color(0xFF2563eb),
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Annuler",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDestructive
                            ? const Color(0xFFdc2626)
                            : const Color(0xFF2563eb),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        confirmText,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return r == true;
  }

  void _showElegantSnackbar(String title, String message, bool isSuccess) {
    Get.snackbar(
      title,
      message,
      backgroundColor: isSuccess
          ? const Color(0xFF10b981)
          : const Color(0xFFef4444),
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      icon: Icon(
        isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
        color: Colors.white,
      ),
    );
  }

  List<int> _currentMemberIds() {
    final e = equipe.value;
    if (e == null) return [];
    return e.membres.map((m) => m.id).toList();
  }

  Future<void> _applyPatch(
    int equipeId, {
    String? nom,
    String? description,
    int? chefId,
    List<int>? userIds,
    String successMsg = 'Équipe mise à jour',
  }) async {
    try {
      isLoading.value = true;
      update();

      final updated = await _repo.updateMeta(
        equipeId,
        nom: nom,
        description: description,
        chefId: chefId,
        userIds: userIds,
      );

      equipe.value = updated;
      _showElegantSnackbar('Succès', successMsg, true);
    } catch (e) {
      _showElegantSnackbar('Erreur', '$e', false);
    } finally {
      isLoading.value = false;
      update();
    }
  }
}

class _ElegantMemberTile extends StatelessWidget {
  final dynamic member;
  final bool isSelected;
  final bool isCurrentChef;
  final VoidCallback onTap;

  const _ElegantMemberTile({
    required this.member,
    required this.isSelected,
    required this.isCurrentChef,
    required this.onTap,
  });

  String get _initials {
    final parts = member.nom.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final s = parts.first;
      return s.isEmpty
          ? '?'
          : s.substring(0, s.length < 2 ? s.length : 2).toUpperCase();
    }
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.last.isNotEmpty ? parts.last[0] : '';
    return '${first}${last}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFf5576c).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFf5576c) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFf5576c), Color(0xFFf093fb)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _initials,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name and Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.nom,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFFf5576c)
                          : Colors.black87,
                    ),
                  ),
                  if (isCurrentChef)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf59e0b).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Chef actuel',
                        style: TextStyle(
                          color: const Color(0xFFf59e0b),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Selection Indicator
            if (isSelected)
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFf5576c),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class UserLite {
  final int id;
  final String nom;

  UserLite({required this.id, required this.nom});
}
