import 'package:material_ui/material_ui.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/emergency_service.dart';

class EmergencySupportScreen extends StatefulWidget {
  const EmergencySupportScreen({this.repository, super.key});
  final EmergencyRepository? repository;

  @override
  State<EmergencySupportScreen> createState() => _EmergencySupportScreenState();
}

class _EmergencySupportScreenState extends State<EmergencySupportScreen> {
  late final EmergencyRepository repository =
      widget.repository ?? MockEmergencyRepository();
  final locationService = LocationService();
  final description = TextEditingController();
  final picker = ImagePicker();
  String? issueType;
  XFile? photo;
  Position? incidentLocation;
  bool submittingIncident = false;

  static const issueTypes = [
    'Unsafe area or crowding',
    'Medical assistance',
    'Lost and found',
    'Infrastructure problem',
    'Other',
  ];

  @override
  void dispose() {
    description.dispose();
    super.dispose();
  }

  Future<void> sendSos() async {
    try {
      final position = await locationService.currentPosition();
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => SosConfirmationDialog(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
      if (confirmed != true || !mounted) return;
      final request = await repository.submitSos(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SosActiveScreen(request: request),
        ),
      );
    } on LocationException catch (error) {
      if (mounted) showMessage(error.message);
    } catch (_) {
      if (mounted) {
        showMessage('The SOS could not be submitted. Please try again.');
      }
    }
  }

  Future<void> pickPhoto() async {
    final selected = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (selected != null && mounted) setState(() => photo = selected);
  }

  Future<void> submitIncident() async {
    if (issueType == null) {
      showMessage('Select an issue type.');
      return;
    }
    if (description.text.trim().isEmpty) {
      showMessage('Describe what happened.');
      return;
    }
    if (submittingIncident) return;
    setState(() => submittingIncident = true);
    try {
      final position =
          incidentLocation ?? await locationService.currentPosition();
      final id = await repository.submitIncident(
        issueType: issueType!,
        description: description.text.trim(),
        latitude: position.latitude,
        longitude: position.longitude,
        photoPath: photo?.path,
      );
      if (!mounted) return;
      setState(() {
        submittingIncident = false;
        issueType = null;
        photo = null;
        incidentLocation = position;
      });
      description.clear();
      showMessage('Demo incident recorded: $id');
    } on LocationException catch (error) {
      if (!mounted) return;
      setState(() => submittingIncident = false);
      showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => submittingIncident = false);
      showMessage('Incident could not be submitted. Please try again.');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration fieldDecoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    labelStyle: const TextStyle(color: Color(0xFF777280), fontSize: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE2DEE5)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE2DEE5)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: SafeArea(
        child: Column(
          children: [
            EmergencyHeader(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EmergencyCard(onSend: sendSos),
                    const SizedBox(height: 18),
                    const Text(
                      'Report a non-urgent issue',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: const Key('incident-type'),
                      initialValue: issueType,
                      decoration: fieldDecoration('Issue type'),
                      items: issueTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(
                                type,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => issueType = value),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      key: const Key('incident-description'),
                      controller: description,
                      minLines: 3,
                      maxLines: 5,
                      decoration: fieldDecoration('Describe what happened')
                          .copyWith(hintText: 'Tell us what happened'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      key: const Key('incident-photo'),
                      onPressed: pickPhoto,
                      icon: Icon(
                        photo == null
                            ? Icons.add_photo_alternate_outlined
                            : Icons.check_circle_outline,
                        size: 18,
                      ),
                      label: Text(
                        photo == null
                            ? 'Add photo (optional)'
                            : 'Photo attached',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5F5A64),
                        minimumSize: const Size.fromHeight(44),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2DEE5)),
                      ),
                      child: Text(
                        incidentLocation == null
                            ? 'Current location: obtained when submitted'
                            : 'Location: ${incidentLocation!.latitude.toStringAsFixed(5)}, ${incidentLocation!.longitude.toStringAsFixed(5)}',
                        style: const TextStyle(
                          color: Color(0xFF68646D),
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton(
                      key: const Key('submit-incident'),
                      onPressed: submittingIncident ? null : submitIncident,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF6650B6),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: submittingIncident
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Submit incident report'),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'Your report goes to the site administrator.',
                        style: TextStyle(color: Color(0xFF777280), fontSize: 9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const EmergencyBottomNavigation(),
          ],
        ),
      ),
    );
  }
}

class EmergencyHeader extends StatelessWidget {
  const EmergencyHeader({required this.onBack, super.key});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Row(
      children: [
        IconButton(
          key: const Key('emergency-back'),
          tooltip: 'Back',
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
        ),
        const Text(
          'EMERGENCY & SUPPORT',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class EmergencyCard extends StatelessWidget {
  const EmergencyCard({required this.onSend, super.key});
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 184),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFB13F48),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
            SizedBox(width: 6),
            Text(
              'EMERGENCY SUPPORT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Need urgent help?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Send your location and an emergency request to the site safety team.',
          style: TextStyle(
            color: Color(0xFFFFF7F7),
            fontSize: 11,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            key: const Key('send-sos'),
            onPressed: onSend,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFB13F48),
            ),
            child: const Text(
              'Send SOS request',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    ),
  );
}

class SosConfirmationDialog extends StatelessWidget {
  const SosConfirmationDialog({
    required this.latitude,
    required this.longitude,
    super.key,
  });
  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.white,
    insetPadding: const EdgeInsets.symmetric(horizontal: 18),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EMERGENCY ALERT',
            style: TextStyle(
              color: Color(0xFFE24A52),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Confirm SOS Request?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your current GPS location will be shared with the site safety team to request immediate assistance.',
            style: TextStyle(fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please confirm only if you need emergency assistance.',
            style: TextStyle(color: Color(0xFF777280), fontSize: 10),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              key: const Key('confirm-sos'),
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB13F48),
              ),
              child: const Text('Confirm SOS'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              key: const Key('cancel-sos'),
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF625D65),
                backgroundColor: const Color(0xFFEFEDEF),
                side: BorderSide.none,
              ),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    ),
  );
}

class SosActiveScreen extends StatelessWidget {
  const SosActiveScreen({required this.request, super.key});
  final SosRequest request;

  String get statusLabel => switch (request.status) {
    SosStatus.submitted => 'Submitted',
    SosStatus.awaitingAcknowledgement => 'Awaiting Acknowledgement',
    SosStatus.acknowledged => 'Acknowledged',
    SosStatus.assistanceDispatched => 'Assistance Dispatched',
    SosStatus.resolved => 'Resolved',
    SosStatus.failed => 'Failed',
  };

  Future<void> callEmergencyServices(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: '112');
    if (!await canLaunchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A telephone dialer is unavailable on this device.'),
          ),
        );
      }
      return;
    }
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final time =
        '${request.submittedAt.hour.toString().padLeft(2, '0')}:${request.submittedAt.minute.toString().padLeft(2, '0')}';
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: SafeArea(
        child: Column(
          children: [
            EmergencyHeader(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SOS ACTIVE',
                      style: TextStyle(
                        color: Color(0xFFE24A52),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Emergency Alert Sent',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Your SOS request has been submitted to the site safety team.',
                      style: TextStyle(color: Color(0xFF66616B), fontSize: 12),
                    ),
                    if (request.isMock) ...[
                      const SizedBox(height: 6),
                      const Text(
                        'Development demo only: no request was sent to a safety team.',
                        style: TextStyle(
                          color: Color(0xFF9B4A50),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE8E4EA)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Request Details',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Divider(height: 20),
                          detail('Request ID', request.id),
                          detail('Status', statusLabel),
                          detail(
                            'Location',
                            'GPS shared: ${request.latitude.toStringAsFixed(5)}, ${request.longitude.toStringAsFixed(5)}',
                          ),
                          detail('Time', time),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        key: const Key('call-emergency-services'),
                        onPressed: () => callEmergencyServices(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFB13F48),
                        ),
                        child: const Text('Call Emergency Services'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const EmergencyBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget detail(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      children: [
        SizedBox(
          width: 82,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF777280), fontSize: 11),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: label == 'Status'
                  ? const Color(0xFFFF8A00)
                  : const Color(0xFF29262D),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class EmergencyBottomNavigation extends StatelessWidget {
  const EmergencyBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) => Container(
    height: 58,
    decoration: const BoxDecoration(
      color: Color(0xFFF8F5F9),
      border: Border(top: BorderSide(color: Color(0xFFE7E1E9))),
    ),
    child: const Row(
      children: [
        BottomItem(icon: Icons.home_outlined, label: 'Home'),
        BottomItem(icon: Icons.chat_bubble_outline_rounded, label: 'Guide'),
        BottomItem(
          icon: Icons.verified_user_outlined,
          label: 'Safety',
          active: true,
        ),
        BottomItem(icon: Icons.person_outline_rounded, label: 'You'),
      ],
    ),
  );
}

class BottomItem extends StatelessWidget {
  const BottomItem({
    required this.icon,
    required this.label,
    this.active = false,
    super.key,
  });
  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 18,
          color: active ? const Color(0xFF6650B6) : const Color(0xFF777180),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: active ? const Color(0xFF6650B6) : const Color(0xFF777180),
          ),
        ),
      ],
    ),
  );
}
