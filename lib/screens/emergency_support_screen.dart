import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../localization/app_language.dart';
import 'report_flow_screen.dart';

const _emergencyRed = Color(0xFFCE3434);
const _emergencyNavy = Color(0xFF20365D);
const _emergencyCanvas = Color(0xFFF4F6FA);
const _configuredSupportPhoneNumber = '+91 8709453483';

class EmergencySupportScreen extends StatefulWidget {
  const EmergencySupportScreen({
    this.supportPhoneNumber = _configuredSupportPhoneNumber,
    super.key,
  });

  final String supportPhoneNumber;

  @override
  State<EmergencySupportScreen> createState() => _EmergencySupportScreenState();
}

class _EmergencySupportScreenState extends State<EmergencySupportScreen> {
  Future<void> _confirmSos() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: _emergencyRed),
        title: Text(AppLanguage.translate('Confirm SOS')),
        content: Text(
          AppLanguage.translate(
            'This is a demo. No alert will be sent and your location will not be shared.',
          ),
        ),
        actions: [
          TextButton(
            key: const Key('emergency-sos-cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLanguage.translate('Cancel')),
          ),
          FilledButton(
            key: const Key('emergency-sos-confirm'),
            style: FilledButton.styleFrom(backgroundColor: _emergencyRed),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLanguage.translate('Continue demo')),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EmergencyAlertDemoScreen(
          alertId: _generateDemoAlertId(),
          supportPhoneNumber: widget.supportPhoneNumber,
        ),
      ),
    );
  }

  void _openNonUrgentReport() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ReportProblemScreen(demoOnly: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _emergencyCanvas,
      appBar: AppBar(
        backgroundColor: _emergencyCanvas,
        foregroundColor: _emergencyNavy,
        title: Text(AppLanguage.translate('Emergency & Support')),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                const _DemoNotice(),
                const SizedBox(height: 22),
                Text(
                  AppLanguage.translate('How can we help?'),
                  style: const TextStyle(
                    color: _emergencyNavy,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLanguage.translate(
                    'For immediate danger, use SOS. For other concerns, send a non-urgent report.',
                  ),
                  style: const TextStyle(
                    color: Color(0xFF66758D),
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Color(0xFFE1E6EF)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.emergency_rounded,
                          color: _emergencyRed,
                          size: 42,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLanguage.translate('Need urgent help?'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _emergencyNavy,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLanguage.translate(
                            'The SOS flow is a local demo and does not contact emergency services.',
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF66758D),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          key: const Key('emergency-sos'),
                          onPressed: _confirmSos,
                          icon: const Icon(Icons.sos_rounded),
                          label: Text(AppLanguage.translate('SOS Emergency')),
                          style: FilledButton.styleFrom(
                            backgroundColor: _emergencyRed,
                            minimumSize: const Size.fromHeight(54),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Color(0xFFE1E6EF)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.edit_note_rounded,
                              color: _emergencyNavy,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                AppLanguage.translate(
                                  'Report a non-urgent issue',
                                ),
                                style: const TextStyle(
                                  color: _emergencyNavy,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLanguage.translate(
                            'Describe a safety, cleanliness, or facility concern.',
                          ),
                          style: const TextStyle(
                            color: Color(0xFF66758D),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          key: const Key('emergency-nonurgent-report'),
                          onPressed: _openNonUrgentReport,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _emergencyNavy,
                            minimumSize: const Size.fromHeight(50),
                            side: const BorderSide(color: Color(0xFFCBD4E2)),
                          ),
                          child: Text(
                            AppLanguage.translate('Start a report'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmergencyAlertDemoScreen extends StatelessWidget {
  const EmergencyAlertDemoScreen({
    required this.alertId,
    required this.supportPhoneNumber,
    super.key,
  });

  final String alertId;
  final String supportPhoneNumber;

  Future<void> _callConfiguredContact(BuildContext context) async {
    final dialNumber = supportPhoneNumber.replaceAll(RegExp(r'\s'), '');
    final digitsOnly = RegExp(r'^\+?[0-9]+$').hasMatch(dialNumber);
    if (!digitsOnly) {
      _showCallError(context);
      return;
    }

    try {
      final opened = await launchUrl(
        Uri(scheme: 'tel', path: dialNumber),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && context.mounted) _showCallError(context);
    } on PlatformException {
      if (context.mounted) _showCallError(context);
    } on MissingPluginException {
      if (context.mounted) _showCallError(context);
    }
  }

  void _showCallError(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${AppLanguage.translate('Could not open the phone app. Dial manually:')} $supportPhoneNumber',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(DateTime.now()),
    );
    return Scaffold(
      backgroundColor: _emergencyCanvas,
      appBar: AppBar(
        backgroundColor: _emergencyCanvas,
        foregroundColor: _emergencyNavy,
        title: Text(AppLanguage.translate('Emergency Alert Demo')),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
            children: [
              const _DemoNotice(),
              const SizedBox(height: 24),
              const Icon(
                Icons.info_outline_rounded,
                size: 72,
                color: _emergencyRed,
              ),
              const SizedBox(height: 18),
              Text(
                AppLanguage.translate('Demo alert created'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _emergencyNavy,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLanguage.translate(
                  'No emergency alert was sent and no location was shared.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF66758D),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE1E6EF)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _AlertDetail(
                        label: AppLanguage.translate('DEMO REQUEST ID'),
                        value: alertId,
                        valueKey: const Key('emergency-demo-request-id'),
                      ),
                      const Divider(height: 26),
                      _AlertDetail(
                        label: AppLanguage.translate('STATUS'),
                        value: AppLanguage.translate('Not sent (demo)'),
                        valueKey: const Key('emergency-demo-status'),
                      ),
                      const Divider(height: 26),
                      _AlertDetail(
                        label: AppLanguage.translate('LOCATION'),
                        value: AppLanguage.translate('Not shared'),
                      ),
                      const Divider(height: 26),
                      _AlertDetail(
                        label: AppLanguage.translate('TIME'),
                        value: timestamp,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                key: const Key('emergency-call-contact'),
                onPressed: () => _callConfiguredContact(context),
                icon: const Icon(Icons.call_outlined),
                label: Text(
                  AppLanguage.translate('Call configured contact'),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _emergencyRed,
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${AppLanguage.translate('Configured contact')}: $supportPhoneNumber',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF66758D),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoNotice extends StatelessWidget {
  const _DemoNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('emergency-demo-notice'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3DC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF2D7A7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF8A5A00),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppLanguage.translate(
                'Demo only: requests are not sent and location is not shared.',
              ),
              style: const TextStyle(
                color: Color(0xFF684700),
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertDetail extends StatelessWidget {
  const _AlertDetail({
    required this.label,
    required this.value,
    this.valueKey,
  });

  final String label;
  final String value;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF66758D),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            key: valueKey,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: _emergencyNavy,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

String _generateDemoAlertId() =>
    'DEMO-${DateTime.now().millisecondsSinceEpoch.toString()}';
