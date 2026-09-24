import 'package:flutter_test/flutter_test.dart';
import 'package:omi/env/env.dart';
import 'package:omi/env/environment_profile.dart';

void main() {
  group('LifeOS mobile profile', () {
    test('is a production-family profile for the LifeOS-owned backend', () {
      expect(AppEnvironmentProfile.lifeOs.name, 'lifeos');
      expect(AppEnvironmentProfile.lifeOs.authCallbackScheme, 'lifeos-omi');
      expect(AppEnvironmentProfile.lifeOs.usesFirebaseAuthEmulator, isFalse);
      expect(AppEnvironmentProfile.lifeOs.allowsProductionData, isTrue);
    });

    test('keeps auth on the LifeOS serving plane', () {
      expect(
        Env.authApiBaseUrlForProfile(
          AppEnvironmentProfile.lifeOs,
          servingApiBaseUrl: 'https://omi.lifeos.example/',
        ),
        'https://omi.lifeos.example/',
      );
    });

    test('accepts a LifeOS-owned HTTPS endpoint', () {
      expect(
        () => Env.validateStartupRouting(
          productionFamily: true,
          configuredProfile: AppEnvironmentProfile.lifeOs,
          configuredApiBaseUrl: 'https://omi.lifeos.example/',
          releaseBuild: true,
        ),
        returnsNormally,
      );
    });

    test('rejects insecure and Omi-managed endpoints', () {
      for (final endpoint in [
        'http://omi.lifeos.example/',
        'https://api.omi.me/',
        'https://api.omiapi.com/',
        'https://lifeos.invalid/',
      ]) {
        expect(
          () => Env.validateStartupRouting(
            productionFamily: true,
            configuredProfile: AppEnvironmentProfile.lifeOs,
            configuredApiBaseUrl: endpoint,
            releaseBuild: true,
          ),
          throwsStateError,
          reason: endpoint,
        );
      }
    });
  });
}
