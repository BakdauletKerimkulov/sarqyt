import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:sarqyt/env.dart';
import 'package:sarqyt/src/app_bootstrap.dart';

extension AppBootstrapStripe on AppBootstrap {
  Future<void> setupStripe() async {
    if (kIsWeb || Platform.isIOS || Platform.isAndroid) {
      Stripe.publishableKey = Env.stripePublishableKey;
      Stripe.merchantIdentifier = 'merchant.sarqyt.app';
      Stripe.urlScheme = 'sarqyt';
      await Stripe.instance.applySettings();
    }
  }
}
