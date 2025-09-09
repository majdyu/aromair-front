import 'url_opener_io.dart'
  if (dart.library.html) 'url_opener_web.dart' as impl;

/// Ouvre une URL en externe (Web: nouvel onglet, Mobile/Desktop: app par défaut)
Future<void> openExternalUrl(String url) => impl.openExternalUrl(url);
