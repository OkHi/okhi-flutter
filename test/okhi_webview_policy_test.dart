import 'package:flutter_test/flutter_test.dart';
import 'package:okhi_flutter/okcollect/okhi_webview_policy.dart';

void main() {
  test('allows trusted OkHi manager urls', () {
    expect(
      isAllowedOkHiWebViewNavigation(
        'https://manager-v5.okhi.io/address/new',
      ),
      isTrue,
    );
    expect(
      isAllowedOkHiWebViewNavigation(
        'https://sandbox-manager-v5.okhi.io/session/123',
      ),
      isTrue,
    );
  });

  test('blocks external and script urls', () {
    expect(
      isAllowedOkHiWebViewNavigation('https://example.com'),
      isFalse,
    );
    expect(
      isAllowedOkHiWebViewNavigation('javascript:alert(1)'),
      isFalse,
    );
  });
}
