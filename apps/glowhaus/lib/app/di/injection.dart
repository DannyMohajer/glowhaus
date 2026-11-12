import 'package:get_it/get_it.dart';
import 'package:glowhaus/app/di/injection.config.dart';
import 'package:glowhaus/features/settings/data/simulation_control.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The composition root. Only `main`, the router and tests touch this;
/// everything else receives its dependencies through constructors.
final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() => getIt.init();

@module
abstract class AppModule {
  @preResolve
  Future<SharedPreferences> get preferences => SharedPreferences.getInstance();

  /// Milestone 1 runs on the simulation. A real transport replaces these
  /// three registrations and nothing above the repositories changes.
  @lazySingleton
  SimulatedTransport get simulatedTransport =>
      SimulatedTransport(homeId: DemoHome.homeId, devices: DemoHome.devices());

  @lazySingleton
  Transport transport(SimulatedTransport simulated) => simulated;

  @lazySingleton
  SimulationControl simulationControl(SimulatedTransport simulated) =>
      TransportSimulationControl(simulated);
}
