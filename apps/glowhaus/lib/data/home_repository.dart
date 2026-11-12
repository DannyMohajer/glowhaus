import 'package:glowhaus_domain/glowhaus_domain.dart';

/// Homes, rooms and scenes: the layout the app owns.
///
/// One demo home for now; multiple homes arrive in milestone 5.
class HomeRepository {
  const new(this.currentHome);

  final Home currentHome;
}
