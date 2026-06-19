import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied()
final class Env {
  @EnviedField(varName: 'STADIA_MAPS_API_KEY', obfuscate: true)
  static final String stadiaMapsApiKey = _Env.stadiaMapsApiKey;
}
