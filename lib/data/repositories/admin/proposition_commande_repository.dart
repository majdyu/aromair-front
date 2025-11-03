import 'package:front_erp_aromair/data/enums/status_commandes.dart';
import 'package:front_erp_aromair/data/models/commande_potentielle.dart';
import 'package:front_erp_aromair/data/services/proposition_commande_service.dart';
import 'package:intl/intl.dart';

class CommandesPotentiellesRepository {
  final CommandesPotentiellesService _service;

  CommandesPotentiellesRepository(this._service);

  Future<List<CommandePotentielleRow>> fetch({StatusCommande? status}) {
    return _service.list(status: status);
  }

  Future<CommandePotentielleRow> toggleEtatBouteille(int id) {
    return _service.toggleBouteilleVide(id);
  }

  Future<CommandePotentielleRow> validateCommande(int id, int? interventionId) {
    return _service.validateCommande(id, interventionId: interventionId);
  }

  Future<CommandePotentielleRow> updatePartiellement(
    int id, {
    int? parfumId,
    int? quantite,
    int? nbrBouteilles,
    String? typeTete,
    DateTime? datePlanification,
  }) {
    String? datePlanifFormatted;
    if (datePlanification != null) {
      final fmt = DateFormat("dd-MM-yyyy'T'HH:mm:ss");
      datePlanifFormatted = fmt.format(datePlanification);
    }
    return _service.patchUpdate(
      id,
      parfumId: parfumId,
      quantite: quantite,
      nbrBouteilles: nbrBouteilles,
      typeTete: typeTete,
      datePlanification: datePlanifFormatted,
    );
  }

  Future<CommandePotentielleRow> createManuelle({
    required int clientDiffuseurId,
    required int? quantiteMl,
    required int? parfumId,
    required bool force,
    int? nbrBouteilles,
    String? typeTete,
  }) {
    // Mappe proprement vers le payload attendu par le backend:
    return _service.createManualy(
      clientDiffuseurId: clientDiffuseurId,
      quantiteOpt: quantiteMl,
      parfumIdOpt: parfumId,
      force: force,
      nbrBouteilles: nbrBouteilles ?? 1,
      typeTete: typeTete,
    );
  }
}
