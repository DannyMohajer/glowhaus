import 'package:web/web.dart' as web;

/// A new tab, with `noopener` so the page it opens cannot reach back here.
void openExternalLink(String url) =>
    web.window.open(url, '_blank', 'noopener,noreferrer');
