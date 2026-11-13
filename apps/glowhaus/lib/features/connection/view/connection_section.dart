import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowhaus/features/connection/cubit/connection_settings_cubit.dart';
import 'package:glowhaus/features/connection/data/connection_settings.dart';
import 'package:glowhaus/features/settings/view/settings_parts.dart';
import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

/// Settings: demo home or a real broker, and how to reach the broker.
class ConnectionSection extends StatefulWidget {
  const new({super.key});

  @override
  State<ConnectionSection> createState() => _ConnectionSectionState();
}

class _ConnectionSectionState extends State<ConnectionSection> {
  late final ConnectionSettingsCubit _cubit;
  late final TextEditingController _host;
  late final TextEditingController _port;
  late final TextEditingController _path;
  late final TextEditingController _home;
  late final TextEditingController _username;
  late final TextEditingController _password;
  late final TextEditingController _ca;
  late bool _tls;
  late bool _webSocket;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ConnectionSettingsCubit>();
    final draft = _cubit.brokerDraft;
    _host = TextEditingController(text: draft.host);
    _port = TextEditingController(text: draft.port?.toString() ?? '');
    _path = TextEditingController(text: draft.path);
    _home = TextEditingController(text: draft.homeId);
    _username = TextEditingController(text: draft.username);
    _password = TextEditingController();
    _ca = TextEditingController(text: draft.trustedCertificatePem ?? '');
    _tls = draft.tls;
    _webSocket = draft.webSocket;
  }

  @override
  void dispose() {
    for (final controller in [
      _host,
      _port,
      _path,
      _home,
      _username,
      _password,
      _ca,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  BrokerSettings get _draft => BrokerSettings(
    host: _host.text.trim(),
    port: int.tryParse(_port.text.trim()),
    tls: _tls,
    webSocket: _webSocket,
    path: _path.text.trim(),
    homeId: _home.text.trim(),
    username: _username.text.trim(),
    trustedCertificatePem: _ca.text.trim().isEmpty ? null : _ca.text.trim(),
  );

  /// The username follows the home id while it is still the default.
  void _onHomeChanged(String previous, String next) {
    if (_username.text == '$previous.app') _username.text = '$next.app';
  }

  void _connect() => _cubit.connect(_draft, password: _password.text);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<ConnectionSettingsCubit, ConnectionSettingsState>(
      builder: (context, state) {
        final broker = state.shown == ConnectionMode.broker;
        final web = _cubit.isWeb;
        String? invalid(BrokerField field, String message) =>
            state.invalid.contains(field) ? message : null;
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
              onSelected: _cubit.select,
            ),
            if (!broker)
              _Note(l10n.connectionDemoHint)
            else ...[
              _Note(l10n.connectionBrokerHint),
              if (web) _Note(l10n.connectionWebNote),
              _Field(
                label: l10n.connectionHost,
                hint: l10n.connectionHostHint,
                error: invalid(BrokerField.host, l10n.connectionInvalidHost),
                controller: _host,
                keyboardType: TextInputType.url,
              ),
              _Field(
                label: l10n.connectionPort,
                hint: l10n.connectionPortHint(_draft.defaultPort(web: web)),
                error: invalid(BrokerField.port, l10n.connectionInvalidPort),
                controller: _port,
                keyboardType: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
              ),
              if (!web) ...[
                SettingsSwitchRow(
                  title: l10n.connectionTls,
                  subtitle: l10n.connectionTlsHint,
                  value: _tls,
                  onChanged: (value) => setState(() => _tls = value),
                ),
                SettingsSwitchRow(
                  title: l10n.connectionWebSocket,
                  subtitle: l10n.connectionWebSocketHint,
                  value: _webSocket,
                  onChanged: (value) => setState(() => _webSocket = value),
                ),
              ],
              if (web || _webSocket)
                _Field(
                  label: l10n.connectionPath,
                  error: invalid(BrokerField.path, l10n.connectionInvalidPath),
                  controller: _path,
                  keyboardType: TextInputType.url,
                ),
              _HomeField(
                label: l10n.connectionHome,
                error: invalid(BrokerField.homeId, l10n.connectionInvalidHome),
                controller: _home,
                onChanged: _onHomeChanged,
              ),
              _Field(
                label: l10n.connectionUsername,
                error: invalid(
                  BrokerField.username,
                  l10n.connectionInvalidUsername,
                ),
                controller: _username,
                autofill: const [AutofillHints.username],
              ),
              _Field(
                label: l10n.connectionPassword,
                hint: l10n.connectionPasswordHint,
                controller: _password,
                obscure: true,
                autofill: const [AutofillHints.password],
                action: TextInputAction.go,
                onSubmitted: (_) => _connect(),
              ),
              if (!web)
                _Field(
                  label: l10n.connectionCa,
                  hint: l10n.connectionCaHint,
                  controller: _ca,
                  maxLines: 4,
                ),
              GlowButton(
                label: l10n.connectionConnect,
                icon: GlowIcons.wifi,
                expand: true,
                onTap: _connect,
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

/// Host names, ports, ids and certificates read left to right everywhere.
class _Field extends StatelessWidget {
  const new({
    required this.label,
    required this.controller,
    this.hint,
    this.error,
    this.obscure = false,
    this.keyboardType,
    this.formatters,
    this.autofill,
    this.action,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? error;
  final bool obscure;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final List<String>? autofill;
  final TextInputAction? action;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => GlowTextField(
    label: label,
    hint: hint,
    error: error,
    controller: controller,
    obscure: obscure,
    keyboardType:
        keyboardType ?? (maxLines > 1 ? TextInputType.multiline : null),
    inputFormatters: formatters,
    autofillHints: autofill,
    textInputAction: action,
    maxLines: maxLines,
    textDirection: TextDirection.ltr,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
  );
}

/// The home id field, which tells its listener the old and the new value.
class _HomeField extends StatefulWidget {
  const new({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.error,
  });

  final String label;
  final TextEditingController controller;
  final String? error;
  final void Function(String previous, String next) onChanged;

  @override
  State<_HomeField> createState() => _HomeFieldState();
}

class _HomeFieldState extends State<_HomeField> {
  late String _last = widget.controller.text;

  @override
  Widget build(BuildContext context) => _Field(
    label: widget.label,
    error: widget.error,
    controller: widget.controller,
    onChanged: (next) {
      widget.onChanged(_last, next);
      _last = next;
    },
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
