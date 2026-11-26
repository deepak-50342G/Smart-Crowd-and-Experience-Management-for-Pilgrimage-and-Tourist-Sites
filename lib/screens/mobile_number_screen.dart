import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../auth/demo_auth_service.dart';
import '../localization/app_language.dart';
import '../widgets/auth_background.dart';
import '../widgets/primary_button.dart';
import 'otp_verification_screen.dart';

class MobileNumberScreen extends StatefulWidget {
  const MobileNumberScreen({super.key});

  @override
  State<MobileNumberScreen> createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen> {
  static const _countries =
      <({String name, String code, String flag, int numberLength})>[
        (name: 'India', code: '+91', flag: '🇮🇳', numberLength: 10),
        (name: 'United States', code: '+1', flag: '🇺🇸', numberLength: 10),
        (name: 'United Kingdom', code: '+44', flag: '🇬🇧', numberLength: 10),
        (name: 'Australia', code: '+61', flag: '🇦🇺', numberLength: 9),
        (
          name: 'United Arab Emirates',
          code: '+971',
          flag: '🇦🇪',
          numberLength: 9,
        ),
      ];

  final _phoneController = TextEditingController();
  final _authService = const DemoAuthService();
  ({String name, String code, String flag, int numberLength}) _country =
      _countries.first;
  bool _isLoading = false;
  bool _submitted = false;
  bool _requestFailed = false;

  bool get _hasValidNumber {
    final number = _phoneController.text;
    if (number.length != _country.numberLength ||
        !RegExp(r'^\d+$').hasMatch(number)) {
      return false;
    }
    return _country.code != '+91' || RegExp(r'^[6-9]\d{9}$').hasMatch(number);
  }

  bool get _canSubmit => _phoneController.text.length == _country.numberLength;

  String? get _phoneError {
    if (!_submitted || _hasValidNumber) return null;
    if (_phoneController.text.isEmpty) {
      return AppLanguage.translate('Enter your mobile number');
    }
    return AppLanguage.text(
      'Enter a valid ${_country.numberLength}-digit mobile number',
      '${_country.numberLength} अंकों का मान्य मोबाइल नंबर दर्ज करें',
    );
  }

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _submitted = true;
      _requestFailed = false;
    });
    if (!_hasValidNumber) return;

    setState(() => _isLoading = true);
    try {
      await _authService.requestOtp(
        phoneNumber: _phoneController.text,
        countryCode: _country.code,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OtpVerificationScreen(
            phoneNumber: _phoneController.text,
            countryCode: _country.code,
            authService: _authService,
          ),
        ),
      );
    } on Exception {
      if (mounted) setState(() => _requestFailed = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectCountry() async {
    final selected =
        await showModalBottomSheet<
          ({String name, String code, String flag, int numberLength})
        >(
          context: context,
          backgroundColor: const Color(0xFFF8F9FD),
          showDragHandle: true,
          builder: (context) => SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 4, 24, 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLanguage.translate('Select country'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  ..._countries.map(
                    (country) => ListTile(
                      leading: Text(
                        country.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(AppLanguage.translate(country.name)),
                      trailing: Text(
                        country.code,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onTap: () => Navigator.pop(context, country),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    if (selected != null && mounted) {
      setState(() {
        _country = selected;
        if (_phoneController.text.length > selected.numberLength) {
          _phoneController.text = _phoneController.text.substring(
            0,
            selected.numberLength,
          );
        }
        _submitted = false;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return AuthBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 680;
              final horizontalPadding = size.width < 360 ? 20.0 : 24.0;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  compact ? 28 : 40,
                  horizontalPadding,
                  24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - (compact ? 52 : 64),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(onHelp: _showHelp),
                      SizedBox(height: compact ? 36 : 52),
                      AuthContentCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLanguage.translate('Your journey starts here'),
                              style: TextStyle(
                                color: const Color(0xFF252137),
                                fontSize: compact ? 27 : 30,
                                height: 1.18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLanguage.translate(
                                'Enter your mobile number to continue',
                              ),
                              style: TextStyle(
                                color: Color(0xFF71697F),
                                fontSize: 15,
                                height: 1.45,
                              ),
                            ),
                            SizedBox(height: compact ? 24 : 30),
                            Text(
                              AppLanguage.translate('Mobile number'),
                              style: TextStyle(
                                color: Color(0xFF49454F),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 9),
                            _PhoneField(
                              controller: _phoneController,
                              country: _country,
                              errorText: _phoneError,
                              onCountryTap: _selectCountry,
                              onChanged: (_) {
                                if (_submitted || _requestFailed) {
                                  setState(() {
                                    _submitted = false;
                                    _requestFailed = false;
                                  });
                                } else {
                                  setState(() {});
                                }
                              },
                            ),
                            if (_requestFailed) ...[
                              const SizedBox(height: 8),
                              Text(
                                AppLanguage.translate(
                                  'Could not send a code. Please try again.',
                                ),
                                style: TextStyle(
                                  color: Color(0xFFB3261E),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            SizedBox(height: compact ? 18 : 24),
                            PrimaryButton(
                              label: AppLanguage.translate('Continue'),
                              onPressed: _canSubmit && !_isLoading
                                  ? _continue
                                  : null,
                              isLoading: _isLoading,
                            ),
                            const SizedBox(height: 14),
                            Center(
                              child: Text(
                                AppLanguage.translate(
                                  'We’ll send you a one-time verification code',
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF71697F),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLanguage.translate('Need help?')),
        content: Text(
          AppLanguage.translate(
            'Enter a valid 10-digit mobile number to receive a verification code.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLanguage.translate('Got it')),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onHelp});

  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFEADDFF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.explore_rounded,
            color: Color(0xFF6650B6),
            size: 25,
          ),
        ),
        const SizedBox(width: 11),
        const Text(
          'YatraFlow',
          style: TextStyle(
            color: Color(0xFF252137),
            fontSize: 21,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const Spacer(),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onHelp,
            borderRadius: BorderRadius.circular(14),
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                Icons.help_outline_rounded,
                color: Color(0xFF6650B6),
                size: 23,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.controller,
    required this.country,
    required this.errorText,
    required this.onCountryTap,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ({String name, String code, String flag, int numberLength}) country;
  final String? errorText;
  final VoidCallback onCountryTap;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: errorText == null
                  ? const Color(0xFFE5E1ED)
                  : const Color(0xFFB3261E),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onCountryTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 12),
                    child: Row(
                      children: [
                        Text(
                          country.flag,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          country.code,
                          style: const TextStyle(
                            color: Color(0xFF252137),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF71697F),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 25, color: const Color(0xFFE5E1ED)),
              Expanded(
                child: TextField(
                  key: const Key('phone-number'),
                  controller: controller,
                  onChanged: onChanged,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(country.numberLength),
                  ],
                  style: const TextStyle(
                    color: Color(0xFF252137),
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLanguage.translate('Enter mobile number'),
                    hintStyle: TextStyle(
                      color: Color(0xFFAAA5B2),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 13),
                    isCollapsed: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 7),
          Text(
            errorText!,
            style: const TextStyle(color: Color(0xFFB3261E), fontSize: 12),
          ),
        ],
      ],
    );
  }
}
