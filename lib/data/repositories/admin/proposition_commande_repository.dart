import 'package:front_erp_aromair/data/enums/status_commandes.dart';
import 'package:front_erp_aromair/data/models/commande_potentielle.dart';

import 'package:front_erp_aromair/data/services/proposition_commande_service.dart';

class CommandesPotentiellesRepository {
  final CommandesPotentiellesService _service;

  CommandesPotentiellesRepository(this._service);

  Future<List<CommandePotentielleRow>> fetch({StatusCommande? status}) {
    return _service.list(status: status);
  }
}
