import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../auth/demo_auth_service.dart';
import 'guide_screen.dart';
import 'profile_screens.dart';
import 'safety_screen.dart';

enum _RegistrationStage { details, otp, qr, success }

class RegistrationFlowScreen extends StatefulWidget {
  const RegistrationFlowScreen({
    required this.isHindi,
    required this.phoneNumber,
    required this.countryCode,
    super.key,
  });

  final bool isHindi;
  final String phoneNumber;
  final String countryCode;

  @override
  State<RegistrationFlowScreen> createState() => _RegistrationFlowScreenState();
}

class _RegistrationFlowScreenState extends State<RegistrationFlowScreen> {
  static const _documents = [
    'Aadhaar Card',
    'PAN Card',
    'Voter ID Card',
    'Driving Licence',
    'Other Government ID',
  ];
  static const _qrCharacters = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  final _idNumberController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _otpController = TextEditingController();

  _RegistrationStage _stage = _RegistrationStage.details;
  String? _documentType;
  DateTime? _dateOfBirth;
  String? _qrPayload;
  String? _otpError;
  bool _submitted = false;
  int _selectedTab = 0;

  String _text(String english, String hindi) =>
      widget.isHindi ? hindi : english;

  @override
  void dispose() {
    _idNumberController.dispose();
    _fullNameController.dispose();
    _addressController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_stage == _RegistrationStage.details) return _buildDetailsScreen();
    if (_stage == _RegistrationStage.otp) return _buildOtpScreen();
    if (_stage == _RegistrationStage.qr) return _buildQrScreen();
    return _buildSuccessScreen();
  }

  Widget _buildDetailsScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      bottomNavigationBar: _buildBottomNavigation(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 5, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                key: const Key('registration-back'),
                tooltip: _text('Back', 'वापस'),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                constraints: const BoxConstraints.tightFor(
                  width: 36,
                  height: 36,
                ),
                icon: const Icon(Icons.arrow_back_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFE4E5E8),
                  shape: const CircleBorder(),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'YatraFlow',
                style: TextStyle(
                  color: Color(0xFF2864ED),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _text('Complete your registration', 'अपना पंजीकरण पूरा करें'),
                style: const TextStyle(
                  color: Color(0xFF1E355B),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _text(
                  'Verify your identity to continue your yatra',
                  'अपनी यात्रा जारी रखने के लिए पहचान सत्यापित करें',
                ),
                style: const TextStyle(color: Color(0xFF72809A), fontSize: 10),
              ),
              const SizedBox(height: 12),
              const LinearProgressIndicator(
                value: 1,
                minHeight: 3,
                backgroundColor: Color(0xFFDCE4F3),
                color: Color(0xFF2864ED),
                borderRadius: BorderRadius.all(Radius.circular(3)),
              ),
              const SizedBox(height: 7),
              Text(
                _text(
                  'STEP 2 OF 2  •  IDENTITY DETAILS',
                  'चरण 2/2  •  पहचान विवरण',
                ),
                style: const TextStyle(
                  color: Color(0xFF2864ED),
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 10),
              _buildDocumentPicker(),
              const SizedBox(height: 9),
              _buildTextField(
                key: const Key('registration-id'),
                label: _text('ID Number', 'पहचान पत्र संख्या'),
                hint: _text(
                  'Enter your ID number',
                  'अपनी पहचान पत्र संख्या लिखें',
                ),
                controller: _idNumberController,
              ),
              const SizedBox(height: 9),
              _buildTextField(
                key: const Key('registration-name'),
                label: _text('Full Name', 'पूरा नाम'),
                hint: _text('Enter your full name', 'अपना पूरा नाम लिखें'),
                controller: _fullNameController,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 9),
              _buildDatePicker(),
              const SizedBox(height: 9),
              _buildTextField(
                key: const Key('registration-address'),
                label: _text('Current Address', 'वर्तमान पता'),
                hint: _text(
                  'Enter your current address',
                  'अपना वर्तमान पता लिखें',
                ),
                controller: _addressController,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 13),
              _primaryButton(
                key: const Key('registration-continue'),
                label: _text('Continue', 'जारी रखें'),
                onPressed: _continueFromDetails,
              ),
              const SizedBox(height: 5),
              Text(
                _text(
                  'Your information is used only for identity verification.',
                  'आपकी जानकारी केवल पहचान सत्यापन के लिए उपयोग की जाएगी।',
                ),
                style: const TextStyle(color: Color(0xFF8490A5), fontSize: 8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentPicker() {
    final error = _submitted && _documentType == null
        ? _text('Select an ID type', 'पहचान पत्र का प्रकार चुनें')
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(_text('Government ID Type', 'सरकारी पहचान पत्र का प्रकार')),
        const SizedBox(height: 5),
        InkWell(
          key: const Key('document-type'),
          borderRadius: BorderRadius.circular(7),
          onTap: _selectDocument,
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: error == null
                    ? const Color(0xFFD8E0ED)
                    : const Color(0xFFB3261E),
              ),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _documentType == null
                        ? _text(
                            'Select your ID document',
                            'अपना पहचान पत्र चुनें',
                          )
                        : _documentLabel(_documentType!),
                    style: TextStyle(
                      color: _documentType == null
                          ? const Color(0xFF8190A9)
                          : const Color(0xFF25395B),
                      fontSize: 10,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF687895),
                  size: 17,
                ),
              ],
            ),
          ),
        ),
        if (error != null) _errorLabel(error),
      ],
    );
  }

  Future<void> _selectDocument() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _text('Select ID document', 'पहचान पत्र चुनें'),
                    style: const TextStyle(
                      color: Color(0xFF1E355B),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _text(
                      'Choose one government-issued identity',
                      'सरकार द्वारा जारी पहचान पत्र चुनें',
                    ),
                    style: const TextStyle(
                      color: Color(0xFF72809A),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            for (final document in _documents)
              ListTile(
                dense: true,
                title: Text(
                  _documentLabel(document),
                  style: const TextStyle(fontSize: 13),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF8190A9),
                  size: 18,
                ),
                onTap: () => Navigator.of(context).pop(document),
              ),
          ],
        ),
      ),
    );
    if (selected != null && mounted) {
      setState(() {
        _documentType = selected;
        _submitted = false;
      });
    }
  }

  String _documentLabel(String document) {
    if (!widget.isHindi) return document;
    return switch (document) {
      'Aadhaar Card' => 'आधार कार्ड',
      'PAN Card' => 'पैन कार्ड',
      'Voter ID Card' => 'मतदाता पहचान पत्र',
      'Driving Licence' => 'ड्राइविंग लाइसेंस',
      _ => 'अन्य सरकारी पहचान पत्र',
    };
  }

  Widget _buildTextField({
    required Key key,
    required String label,
    required String hint,
    required TextEditingController controller,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    final error = _submitted && controller.text.trim().isEmpty
        ? _text('This field is required', 'यह जानकारी आवश्यक है')
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 5),
        SizedBox(
          height: 38,
          child: TextField(
            key: key,
            controller: controller,
            onChanged: (_) => setState(() {}),
            textCapitalization: textCapitalization,
            style: const TextStyle(color: Color(0xFF25395B), fontSize: 11),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF8190A9),
                fontSize: 10,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(
                  color: error == null
                      ? const Color(0xFFD8E0ED)
                      : const Color(0xFFB3261E),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(
                  color: error == null
                      ? const Color(0xFFD8E0ED)
                      : const Color(0xFFB3261E),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(
                  color: Color(0xFF2864ED),
                  width: 1.3,
                ),
              ),
            ),
          ),
        ),
        if (error != null) _errorLabel(error),
      ],
    );
  }

  Widget _buildDatePicker() {
    final error = _submitted && _dateOfBirth == null
        ? _text('Select your date of birth', 'जन्म तिथि चुनें')
        : null;
    final date = _dateOfBirth;
    final value = date == null
        ? _text('DD / MM / YYYY', 'दिन / माह / वर्ष')
        : '${date.day.toString().padLeft(2, '0')} / '
              '${date.month.toString().padLeft(2, '0')} / ${date.year}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(_text('Date of Birth', 'जन्म तिथि')),
        const SizedBox(height: 5),
        InkWell(
          key: const Key('registration-dob'),
          borderRadius: BorderRadius.circular(7),
          onTap: _chooseDateOfBirth,
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: error == null
                    ? const Color(0xFFD8E0ED)
                    : const Color(0xFFB3261E),
              ),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: date == null
                          ? const Color(0xFF8190A9)
                          : const Color(0xFF25395B),
                      fontSize: 10,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_month_outlined,
                  color: Color(0xFF687895),
                  size: 15,
                ),
              ],
            ),
          ),
        ),
        if (error != null) _errorLabel(error),
      ],
    );
  }

  Future<void> _chooseDateOfBirth() async {
    final today = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate:
          _dateOfBirth ?? DateTime(today.year - 20, today.month, today.day),
      firstDate: DateTime(1900),
      lastDate: today,
    );
    if (date != null && mounted) setState(() => _dateOfBirth = date);
  }

  void _continueFromDetails() {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (_documentType == null ||
        _idNumberController.text.trim().isEmpty ||
        _fullNameController.text.trim().isEmpty ||
        _dateOfBirth == null ||
        _addressController.text.trim().isEmpty) {
      return;
    }
    setState(() => _stage = _RegistrationStage.otp);
  }

  Widget _buildOtpScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      bottomNavigationBar: _buildBottomNavigation(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                key: const Key('registration-otp-back'),
                tooltip: _text('Back', 'वापस'),
                onPressed: () => setState(() {
                  _otpError = null;
                  _stage = _RegistrationStage.details;
                }),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                constraints: const BoxConstraints.tightFor(
                  width: 36,
                  height: 36,
                ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(height: 20),
              Text(
                _text(
                  'Enter the OTP sent to the registered mobile number.',
                  'पंजीकृत मोबाइल नंबर पर भेजा गया OTP दर्ज करें।',
                ),
                style: const TextStyle(
                  color: Color(0xFF252137),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                _maskedPhoneNumber,
                style: const TextStyle(color: Color(0xFF687895), fontSize: 12),
              ),
              const SizedBox(height: 20),
              TextField(
                key: const Key('registration-otp-code'),
                controller: _otpController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                style: const TextStyle(
                  color: Color(0xFF252137),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 12,
                ),
                decoration: InputDecoration(
                  hintText: '• • • • • •',
                  hintStyle: const TextStyle(
                    color: Color(0xFFAAA5B2),
                    fontSize: 17,
                    letterSpacing: 5,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFD8E0ED)),
                  ),
                ),
              ),
              if (_otpError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _otpError!,
                  style: const TextStyle(
                    color: Color(0xFFB3261E),
                    fontSize: 11,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                _text('Demo mode: use 123456.', 'डेमो मोड: 123456 दर्ज करें।'),
                style: const TextStyle(color: Color(0xFF687895), fontSize: 10),
              ),
              const SizedBox(height: 12),
              Text(
                _text(
                  'By proceeding, you agree to YatraFlow’s Terms and Conditions and Privacy Policy.',
                  'आगे बढ़कर आप YatraFlow की शर्तों और गोपनीयता नीति से सहमत होते हैं।',
                ),
                style: const TextStyle(color: Color(0xFF72809A), fontSize: 9),
              ),
              const SizedBox(height: 12),
              _primaryButton(
                key: const Key('registration-verify-otp'),
                label: _text('Continue', 'जारी रखें'),
                onPressed: _verifyRegistrationOtp,
                trailingIcon: Icons.arrow_forward_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _maskedPhoneNumber {
    if (widget.phoneNumber.length < 4) {
      return '${widget.countryCode} ${widget.phoneNumber}';
    }
    final masked = '*' * (widget.phoneNumber.length - 4);
    return '${widget.countryCode} $masked'
        '${widget.phoneNumber.substring(widget.phoneNumber.length - 4)}';
  }

  void _verifyRegistrationOtp() {
    FocusScope.of(context).unfocus();
    if (_otpController.text != DemoAuthService.demoOtp) {
      setState(
        () => _otpError = _text(
          'Enter the valid 6-digit OTP 123456.',
          'सही 6 अंकों का OTP 123456 दर्ज करें।',
        ),
      );
      return;
    }
    setState(() {
      _otpError = null;
      _qrPayload = _createQrPayload();
      _stage = _RegistrationStage.qr;
    });
  }

  String _createQrPayload() {
    final random = Random.secure();
    final code = List.generate(
      14,
      (_) => _qrCharacters[random.nextInt(_qrCharacters.length)],
    ).join();
    return 'YATRAFLOW-$code';
  }

  Widget _buildQrScreen() {
    final qrPayload = _qrPayload;
    if (qrPayload == null) {
      throw StateError('A registration QR payload must exist at the QR step.');
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      bottomNavigationBar: _buildBottomNavigation(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: QrImageView(
                          key: const Key('registration-qr'),
                          data: qrPayload,
                          version: QrVersions.auto,
                          backgroundColor: Colors.white,
                          size: 192,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _text('Scan me', 'मुझे स्कैन करें'),
                        style: const TextStyle(
                          color: Color(0xFF252137),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _text('Demo ID: $qrPayload', 'डेमो आईडी: $qrPayload'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF72809A),
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _primaryButton(
                key: const Key('registration-qr-continue'),
                label: _text('Continue', 'जारी रखें'),
                onPressed: () =>
                    setState(() => _stage = _RegistrationStage.success),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      bottomNavigationBar: _buildBottomNavigation(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFD9F0E4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF21845D),
                  size: 38,
                ),
              ),
              const SizedBox(height: 13),
              Text(
                _text('You can enter now', 'अब आप प्रवेश कर सकते हैं'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF302D43),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _primaryButton(
                key: const Key('registration-back-home'),
                label: _text('Back to Home', 'होम पर वापस जाएं'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final tabs = [
      (icon: Icons.home_outlined, label: _text('Home', 'होम')),
      (icon: Icons.chat_bubble_outline_rounded, label: _text('Guide', 'गाइड')),
      (icon: Icons.verified_user_outlined, label: _text('Safety', 'सुरक्षा')),
      (icon: Icons.person_outline_rounded, label: _text('You', 'आप')),
    ];
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Color(0xFFF0ECF3),
        border: Border(top: BorderSide(color: Color(0xFFE4E0E8))),
      ),
      child: Row(
        children: [
          for (var index = 0; index < tabs.length; index++)
            Expanded(
              child: InkWell(
                key: Key('registration-tab-$index'),
                onTap: () {
                  if (index == 0) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else if (index == 1) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => GuideScreen(
                          phoneNumber: widget.phoneNumber,
                          countryCode: widget.countryCode,
                        ),
                      ),
                    );
                  } else if (index == 2) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SafetyScreen(
                          phoneNumber: widget.phoneNumber,
                          countryCode: widget.countryCode,
                        ),
                      ),
                    );
                  } else if (index == 3) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => MyProfileScreen(
                          phoneNumber: widget.phoneNumber,
                          countryCode: widget.countryCode,
                        ),
                      ),
                    );
                  } else {
                    setState(() => _selectedTab = index);
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tabs[index].icon,
                      size: 17,
                      color: _selectedTab == index
                          ? const Color(0xFF6650B6)
                          : const Color(0xFF777180),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tabs[index].label,
                      style: TextStyle(
                        fontSize: 9,
                        color: _selectedTab == index
                            ? const Color(0xFF6650B6)
                            : const Color(0xFF777180),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: Color(0xFF263B5D),
      fontSize: 9,
      fontWeight: FontWeight.w700,
    ),
  );

  Widget _errorLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 3),
    child: Text(
      text,
      style: const TextStyle(color: Color(0xFFB3261E), fontSize: 9),
    ),
  );

  Widget _primaryButton({
    required Key key,
    required String label,
    required VoidCallback onPressed,
    IconData? trailingIcon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: FilledButton(
        key: key,
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF2864ED),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              Icon(trailingIcon, size: 17),
            ],
          ],
        ),
      ),
    );
  }
}
