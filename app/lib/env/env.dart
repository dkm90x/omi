import 'package:flutter/foundation.dart';

import 'package:omi/flavors.dart';

import 'environment_profile.dart';

abstract class Env {
  static const productionApiBaseUrl = 'https://api.omi.me/';
  static const _apiBaseUrlFromDefine = String.fromEnvironment('OMI_API_BASE_URL');
  static const firebaseAuthEmulatorHost = String.fromEnvironment(
    'OMI_FIREBASE_AUTH_EMULATOR_HOST',
    defaultValue: '127.0.0.1',
  );
  static const _firebaseAuthEmulatorPort = String.fromEnvironment(
    'OMI_FIREBASE_AUTH_EMULATOR_PORT',
    defaultValue: '9099',
  );
  static late final EnvFields _instance;
  static String? _apiBaseUrlOverride;
  static bool isTestFlight = false;

  static AppEnvironmentProfile get profile =>
      AppEnvironmentProfile.forFlavor(productionFlavor: F.env == Environment.prod);

  static void init(EnvFields instance) {
    _instance = instance;
  }

  static void overrideApiBaseUrl(String url) {
    _apiBaseUrlOverride = url;
  }

  static void clearApiBaseUrlOverrideForTesting() {
    _apiBaseUrlOverride = null;
  }

  static String? get posthogApiKey => _instance.posthogApiKey;

  static String? get apiBaseUrl {
    if (_apiBaseUrlOverride != null) return _apiBaseUrlOverride;
    if (_apiBaseUrlFromDefine.isNotEmpty) return _apiBaseUrlFromDefine;
    final configuredApiBaseUrl = _instance.apiBaseUrl;
    if (configuredApiBaseUrl != null && configuredApiBaseUrl.isNotEmpty) {
      return configuredApiBaseUrl;
    }
    return profile.defaultApiBaseUrl;
  }

  static int get firebaseAuthEmulatorPort => int.tryParse(_firebaseAuthEmulatorPort) ?? 9099;

  static String get authCallbackScheme => profile.authCallbackScheme;

  static String get authRedirectUri => '$authCallbackScheme://auth/callback';

  /// OAuth remains on the production identity plane even when mobile Beta
  /// uses the development serving API for product traffic.
  static String get authApiBaseUrl => authApiBaseUrlForProfile(profile, servingApiBaseUrl: apiBaseUrl);

  static String authApiBaseUrlForProfile(AppEnvironmentProfile configuredProfile, {String? servingApiBaseUrl}) {
    if (configuredProfile == AppEnvironmentProfile.mobileBeta) {
      return productionApiBaseUrl;
    }
    return servingApiBaseUrl ?? configuredProfile.defaultApiBaseUrl;
  }

  static void validateProfilePairing() {
    final productionFlavor = F.env == Environment.prod;
    if (!productionFlavor && profile != AppEnvironmentProfile.localDev) {
      throw StateError('Profile ${profile.name} must be built with the prod flavor.');
    }
    if (productionFlavor && profile == AppEnvironmentProfile.localDev) {
      throw StateError('The prod flavor cannot use the local_dev profile.');
    }
  }

  static void validateFirebaseProject({required String projectId, AppEnvironmentProfile? configuredProfile}) {
    final effectiveProfile = configuredProfile ?? profile;
    if (projectId != effectiveProfile.firebaseProjectId) {
      throw StateError(
        'Mobile profile ${effectiveProfile.name} requires Firebase project ${effectiveProfile.firebaseProjectId}, '
        'but the app was initialized with $projectId.',
      );
    }
  }

  /// Production-family packages have a pinned backend authority. LifeOS is an
  /// explicit production-family profile whose authority is supplied at build
  /// time so our signed app can talk to our own HTTPS backend.
  static void validateStartupRouting({
    required bool productionFamily,
    String? configuredApiBaseUrl,
    AppEnvironmentProfile? configuredProfile,
    bool releaseBuild = kReleaseMode,
  }) {
    final effectiveProfile = configuredProfile ?? (productionFamily ? AppEnvironmentProfile.production : profile);
    final normalized = (configuredApiBaseUrl ?? apiBaseUrl ?? '').trim().replaceFirst(RegExp(r'/+$'), '');
    final expected = effectiveProfile.defaultApiBaseUrl.replaceFirst(RegExp(r'/+$'), '');

    if (effectiveProfile == AppEnvironmentProfile.localDev) {
      if (!_isLocalDevelopmentApi(normalized)) {
        throw StateError(
          'Profile local_dev requires a loopback or private-network API endpoint; '
          'use lifeos for the self-hosted HTTPS backend or mobile_beta for https://api.omiapi.com/.',
        );
      }
      return;
    }

    if (effectiveProfile == AppEnvironmentProfile.localProd) {
      if (releaseBuild) {
        throw StateError('Profile local_prod is only available in debug builds.');
      }
      final uri = Uri.tryParse(normalized);
      if (uri == null || uri.host.isEmpty || (uri.scheme != 'http' && uri.scheme != 'https')) {
        throw StateError('Profile local_prod requires a valid http(s) API endpoint.');
      }
      return;
    }

    if (effectiveProfile == AppEnvironmentProfile.lifeOs) {
      final uri = Uri.tryParse(normalized);
      if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
        throw StateError('Profile lifeos requires a valid HTTPS API endpoint.');
      }
      final host = uri.host.toLowerCase();
      if (host == 'lifeos.invalid' || host == 'api.omi.me' || host == 'api.omiapi.com') {
        throw StateError('Profile lifeos must point to the LifeOS-owned backend, not an Omi managed-cloud endpoint.');
      }
      return;
    }

    if (normalized != expected) {
      throw StateError('Profile ${effectiveProfile.name} requires API_BASE_URL=${effectiveProfile.defaultApiBaseUrl}');
    }
  }

  static void requireProductionRouting() => validateStartupRouting(productionFamily: true);

  static bool _isLocalDevelopmentApi(String base) {
    final uri = Uri.tryParse(base);
    if (uri == null || uri.host.isEmpty || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return false;
    }
    final host = uri.host.toLowerCase();
    if (host == 'localhost' || host == 'host.docker.internal' || host == '::1') {
      return true;
    }
    final octets = host.split('.').map(int.tryParse).toList();
    if (octets.length != 4 || octets.any((octet) => octet == null || octet < 0 || octet > 255)) {
      return false;
    }
    final first = octets[0]!;
    final second = octets[1]!;
    return first == 10 ||
        (first == 172 && second >= 16 && second <= 31) ||
        (first == 192 && second == 168) ||
        (first == 100 && second >= 64 && second <= 127) ||
        (first == 127);
  }

  static String? get intercomAppId => _instance.intercomAppId;

  static String? get intercomIOSApiKey => _instance.intercomIOSApiKey;

  static String? get intercomAndroidApiKey => _instance.intercomAndroidApiKey;

  static String? get googleClientId => _instance.googleClientId;

  static String? get googleClientSecret => _instance.googleClientSecret;

  static bool? get useWebAuth => _instance.useWebAuth ?? false;

  static bool? get useAuthCustomToken => _instance.useAuthCustomToken ?? false;
}

abstract class EnvFields {
  String? get posthogApiKey;

  String? get apiBaseUrl;

  String? get intercomAppId;

  String? get intercomIOSApiKey;

  String? get intercomAndroidApiKey;

  String? get googleClientId;

  String? get googleClientSecret;

  bool? get useWebAuth;

  bool? get useAuthCustomToken;
}
