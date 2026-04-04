import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied()
final class Env {
  @EnviedField(varName: 'STRIPE_PUBLISHABLE_KEY', obfuscate: true)
  static final String stripePublishableKey = _Env.stripePublishableKey;

  @EnviedField(varName: 'STADIA_MAPS_API_KEY', obfuscate: true)
  static final String stadiaMapsApiKey = _Env.stadiaMapsApiKey;

  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  static final String supabaseUrl = _Env.supabaseUrl;
}
