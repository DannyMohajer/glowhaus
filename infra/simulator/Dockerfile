# Device simulator: the Glowhaus demo home as one small native binary.
# Build context is the repository root (see docker-compose.yml).

FROM dart:stable AS build
WORKDIR /src

# The repository is a pub workspace that also holds Flutter packages. Resolve
# only the pure-Dart members the simulator needs, with a workspace root of its
# own, so the image needs no Flutter SDK.
COPY packages/glowhaus_domain packages/glowhaus_domain
COPY packages/glowhaus_mqtt packages/glowhaus_mqtt
COPY packages/glowhaus_device packages/glowhaus_device
COPY simulator simulator
RUN printf '%s\n' \
  'name: glowhaus_simulator_workspace' \
  'publish_to: none' \
  'environment:' \
  '  sdk: ^3.13.5' \
  'workspace:' \
  '  - packages/glowhaus_domain' \
  '  - packages/glowhaus_mqtt' \
  '  - packages/glowhaus_device' \
  '  - simulator' \
  > pubspec.yaml \
  && dart pub get \
  && dart compile exe simulator/bin/simulator.dart -o /simulator

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /simulator /simulator
ENTRYPOINT ["/simulator"]
