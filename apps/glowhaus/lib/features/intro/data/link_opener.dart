import 'package:glowhaus/features/intro/data/link_opener_stub.dart'
    if (dart.library.js_interop) 'package:glowhaus/features/intro/data/link_opener_web.dart'
    as platform;

/// Opens [url] outside the app: a new browser tab on the web, nothing
/// anywhere else (no plugin is bundled, so a native build stays plugin-free).
void openExternalLink(String url) => platform.openExternalLink(url);
