enum StatusCommande {
  EN_ATTENTE,
  VALIDE,
  PRODUIS,
  INCONNU, // fallback
}

extension StatusCommandeX on StatusCommande {
  static StatusCommande fromString(dynamic v) {
    final s = (v ?? '').toString().toUpperCase().trim();
    switch (s) {
      case 'EN_ATTENTE':
        return StatusCommande.EN_ATTENTE;
      case 'VALIDE':
        return StatusCommande.VALIDE;
      case 'PRODUIS':
        return StatusCommande.PRODUIS;
      default:
        return StatusCommande.INCONNU;
    }
  }
}
