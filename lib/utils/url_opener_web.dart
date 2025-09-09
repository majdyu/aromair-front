import 'package:web/web.dart' as web;

Future<void> openExternalUrl(String url) async {
  // ouvre dans un nouvel onglet (Web)
  web.window.open(url, '_blank');
}
