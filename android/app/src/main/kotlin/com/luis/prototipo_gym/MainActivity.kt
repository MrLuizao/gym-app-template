package com.luis.prototipo_gym

import io.flutter.embedding.android.FlutterFragmentActivity

/// FlutterFragmentActivity es requisito de flutter_stripe — el Payment
/// Sheet usa Fragments y crashea con FlutterActivity plano.
class MainActivity : FlutterFragmentActivity()
