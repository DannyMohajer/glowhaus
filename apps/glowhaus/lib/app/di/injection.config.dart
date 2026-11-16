// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:glowhaus/app/di/injection.dart' as _i348;
import 'package:glowhaus/data/device_repository.dart' as _i284;
import 'package:glowhaus/data/home_repository.dart' as _i851;
import 'package:glowhaus/features/connection/cubit/connection_settings_cubit.dart'
    as _i171;
import 'package:glowhaus/features/connection/data/broker_transports.dart'
    as _i741;
import 'package:glowhaus/features/connection/data/connection_store.dart'
    as _i528;
import 'package:glowhaus/features/settings/cubit/settings_cubit.dart' as _i849;
import 'package:glowhaus/features/settings/data/app_platform.dart' as _i920;
import 'package:glowhaus/features/settings/data/language_preparer.dart'
    as _i693;
import 'package:glowhaus/features/settings/data/settings_store.dart' as _i1068;
import 'package:glowhaus/features/settings/data/simulation_control.dart'
    as _i893;
import 'package:glowhaus_transport/glowhaus_transport.dart' as _i319;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => appModule.preferences,
      preResolve: true,
    );
    gh.lazySingleton<_i319.SimulatedTransport>(
      () => appModule.simulatedTransport,
    );
    gh.lazySingleton<_i851.HomeRepository>(() => appModule.homeRepository);
    gh.lazySingleton<_i920.AppPlatform>(() => const _i920.AppPlatform());
    gh.lazySingleton<_i693.LanguagePreparer>(
      () => _i693.FontLanguagePreparer(),
    );
    gh.lazySingleton<_i741.BrokerTransports>(
      () => _i741.DeferredBrokerTransports(gh<_i920.AppPlatform>()),
    );
    gh.lazySingleton<_i319.Transport>(
      () => appModule.transport(gh<_i319.SimulatedTransport>()),
    );
    gh.lazySingleton<_i893.SimulationControl>(
      () => appModule.simulationControl(gh<_i319.SimulatedTransport>()),
    );
    gh.lazySingleton<_i528.ConnectionStore>(
      () => _i528.PrefsConnectionStore(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i284.DeviceRepository>(
      () => appModule.deviceRepository(gh<_i319.Transport>()),
    );
    gh.lazySingleton<_i1068.SettingsStore>(
      () => _i1068.PrefsSettingsStore(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i171.ConnectionSettingsCubit>(
      () => appModule.connectionSettings(
        gh<_i284.DeviceRepository>(),
        gh<_i319.SimulatedTransport>(),
        gh<_i741.BrokerTransports>(),
        gh<_i528.ConnectionStore>(),
        gh<_i920.AppPlatform>(),
      ),
    );
    gh.factory<_i849.SettingsCubit>(
      () => _i849.SettingsCubit(
        gh<_i1068.SettingsStore>(),
        gh<_i893.SimulationControl>(),
        gh<_i693.LanguagePreparer>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i348.AppModule {}
