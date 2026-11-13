import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowhaus/features/connection/cubit/connection_settings_cubit.dart';
import 'package:glowhaus/features/connection/data/connection_settings.dart';
import 'package:glowhaus/features/connection/view/broker_form.dart'
    deferred as broker_form;
import 'package:glowhaus/features/settings/view/settings_parts.dart';
import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

/// Settings: demo home or a real broker, and how to reach the broker.
///
/// The broker form is a deferred library, fetched the first time "My broker"
/// is picked, so a visitor who stays on the demo never downloads it.
class ConnectionSection extends StatefulWidget {
  const new({super.key});

  @override
  State<ConnectionSection> createState() => _ConnectionSectionState();
}

class _ConnectionSectionState extends State<ConnectionSection> {
  Future<void>? _formLoaded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ConnectionSettingsCubit>();
    return BlocBuilder<ConnectionSettingsCubit, ConnectionSettingsState>(
      builder: (context, state) {
        final broker = state.shown == ConnectionMode.broker;
        final web = cubit.isWeb;
        if (broker) _formLoaded ??= broker_form.loadLibrary();
        return SettingsSection(
          title: l10n.settingsConnection,
          subtitle: l10n.settingsConnectionHint,
          children: [
            SettingsChoices<ConnectionMode>(
              values: ConnectionMode.values,
              selected: state.shown,
              label: (mode) => switch (mode) {
                ConnectionMode.demo => l10n.connectionModeDemo,
                ConnectionMode.broker => l10n.connectionModeBroker,
              },
              icon: (mode) => switch (mode) {
                ConnectionMode.demo => GlowIcons.sparkles,
                ConnectionMode.broker => GlowIcons.wifi,
              },
              onSelected: cubit.select,
            ),
            if (!broker)
              _Note(l10n.connectionDemoHint)
            else ...[
              _Note(l10n.connectionBrokerHint),
              if (web) _Note(l10n.connectionWebNote),
              FutureBuilder<void>(
                future: _formLoaded,
                builder: (context, snapshot) =>
                    snapshot.connectionState == ConnectionState.done
                    ? broker_form.BrokerForm()
                    : const Center(child: GlowSpinner(size: 20)),
              ),
            ],
            if (state.active == ConnectionMode.broker)
              _BrokerStatus(
                state: state,
                address: '${state.settings.broker.endpoint(web: web)}',
                web: web,
              ),
          ],
        );
      },
    );
  }
}

class _Note extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.type.caption.copyWith(color: context.colors.textMuted),
  );
}

class _BrokerStatus extends StatelessWidget {
  const new({required this.state, required this.address, required this.web});

  final ConnectionSettingsState state;
  final String address;
  final bool web;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final problem = state.problem;
    final (badge, label, text, isError) = switch (state.status) {
      _ when state.needsPassword => (
        ConnectionBadgeState.offline,
        l10n.connectionOffline,
        l10n.connectionStatusNeedsPassword(address),
        false,
      ),
      TransportStatus.connected => (
        ConnectionBadgeState.online,
        l10n.connectionOnline,
        l10n.connectionStatusConnected(address),
        false,
      ),
      TransportStatus.connecting || TransportStatus.reconnecting => (
        ConnectionBadgeState.connecting,
        state.status == TransportStatus.reconnecting
            ? l10n.connectionReconnecting
            : l10n.connectionConnecting,
        switch (problem) {
          null => l10n.connectionStatusConnecting(address),
          MqttConnectFailure.unreachable =>
            web
                ? l10n.connectionProblemUnreachableWeb
                : l10n.connectionProblemUnreachable,
          MqttConnectFailure.untrusted => l10n.connectionProblemUntrusted,
          MqttConnectFailure.unauthorized => l10n.connectionProblemUnauthorized,
          MqttConnectFailure.refused => l10n.connectionProblemRefused,
        },
        problem != null,
      ),
      TransportStatus.disconnected => (
        ConnectionBadgeState.offline,
        l10n.connectionOffline,
        null,
        false,
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConnectionBadge(state: badge, label: label),
        if (text != null) ...[
          const SizedBox(height: GlowSpace.x2),
          Semantics(
            liveRegion: true,
            child: Text(
              text,
              style: context.type.caption.copyWith(
                color: isError ? colors.error : colors.textMuted,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
