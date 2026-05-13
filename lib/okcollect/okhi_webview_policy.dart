import '../models/okhi_constant.dart';

final Set<String> _trustedLocationManagerHosts = {
  Uri.parse(OkHiConstant.devLocationManagerUrl).host,
  Uri.parse(OkHiConstant.sandboxLocationManagerUrl).host,
  Uri.parse(OkHiConstant.prodLocationManagerUrl).host,
  Uri.parse(OkHiConstant.legacyDevLocationManagerUrl).host,
  Uri.parse(OkHiConstant.legacyProdLocationManagerUrl).host,
  Uri.parse(OkHiConstant.legacySandboxLocationManagerUrl).host,
};

/// Returns true only for the OkHi-managed WebView entrypoints.
///
/// The location manager executes privileged JavaScript and exposes a Flutter
/// bridge, so we keep navigation tightly scoped to the known OkHi hosts.
bool isAllowedOkHiWebViewNavigation(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    return false;
  }

  if (uri.scheme == 'about' && uri.path == 'blank') {
    return true;
  }

  if (uri.scheme != 'https' && uri.scheme != 'http') {
    return false;
  }

  return _trustedLocationManagerHosts.contains(uri.host);
}
