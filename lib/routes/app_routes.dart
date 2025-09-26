class AppRoutes {
  static const login = '/login';
  // Admin routes
  static const adminOverview = '/admin-overview';

  static const adminInterventions = '/admin-interventions';
  // Détails intervention (paramétrée)
  static const interventionDetail = '/interventions';
  // État clientDiffuseur dans une intervention (paramétrée)
  static const interventionClientDiffuseur =
      '/interventions/client-diffuseurs/detail';
  static const detailClient = '/clients/detail';
  // Détails alerte
  static const alerteDetail = '/alertes/detail';
  // Détails bouteille
  static const bouteilleDetail = '/bouteilles';
  //client diffuseur detail
  static const clientDiffuseurDetail = '/client-diffuseurs/detail';
  // Détails réclamation
  static const reclamationDetail = '/reclamations/details';
  static const adminClients = '/admin-clients';
  static const adminDiffuseurs = '/admin-diffuseurs';
  static const adminAlertes = '/admin-alertes';
  static const adminReclamations = '/admin-reclamations';
  static const adminUtilisateurs = '/admin-utilisateurs';
  static const adminRapports = '/admin-rapports';

  // Technicien routes
  static const techHome = '/techHome';
  // Production routes
  static const prodHome = '/prodHome';
  // Client routes
  static const clientHome = '/clientHome';
}
