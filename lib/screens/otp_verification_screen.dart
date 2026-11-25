import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../auth/demo_auth_service.dart';
import '../widgets/auth_background.dart';
import '../widgets/primary_button.dart';
import 'language_selection_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    required this.phoneNumber,
    required this.countryCode,
    required this.authService,
    super.key,
  });

  final String phoneNumber;
  final String countryCode;
  final DemoAuthService authService;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  Timer? _timer;
  int _secondsRemaining = 30;
  bool _isLoading = false;
  bool _isResending = false;
  bool _submitted = false;
  bool _isVerified = false;
  String? _verificationError;
  String? _resendError;

  bool get _hasCompleteOtp => _otpController.text.length == 6;

  String get _maskedPhoneNumber {
    final number = widget.phoneNumber;
    if (number.length < 4) return '${widget.countryCode} $number';
    return '${widget.countryCode} ${'*' * (number.length - 4)}${number.substring(number.length - 4)}';
  }

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  Future<void> _resendCode() async {
    if (_secondsRemaining > 0 || _isResending) return;
    setState(() {
      _isResending = true;
      _resendError = null;
    });
    try {
      await widget.authService.requestOtp(
        phoneNumber: widget.phoneNumber,
        countryCode: widget.countryCode,
      );
      if (mounted) _startCountdown();
    } on Exception {
      if (mounted) {
        setState(() => _resendError = 'Could not resend the code. Try again.');
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (!_hasCompleteOtp) return;

    setState(() {
      _isLoading = true;
      _verificationError = null;
    });
    try {
      final verified = await widget.authService.verifyOtp(
        phoneNumber: widget.phoneNumber,
        countryCode: widget.countryCode,
        otp: _otpController.text,
      );
      if (mounted) {
        setState(() {
          _isVerified = verified;
          _submitted = true;
          if (!verified) {
            _verificationError = 'That code didn’t match. Please try again.';
          }
        });
        if (verified) {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => LanguageSelectionScreen(
                phoneNumber: widget.phoneNumber,
                countryCode: widget.countryCode,
              ),
            ),
          );
        }
      }
    } on Exception {
      if (mounted) {
        setState(
          () => _verificationError =
              'Could not verify the code. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return AuthBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 620;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  size.width < 360 ? 20 : 24,
                  compact ? 12 : 32,
                  size.width < 360 ? 20 : 24,
                  24,
                ),
                child: AuthContentCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEADDFF),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.mark_email_read_outlined,
                          color: Color(0xFF6650B6),
                          size: 28,
                        ),
                      ),
                      SizedBox(height: compact ? 22 : 30),
                      Text(
                        _isVerified ? 'You’re all set!' : 'Verify your number',
                        style: const TextStyle(
                          color: Color(0xFF252137),
                          fontSize: 29,
                          height: 1.18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        _isVerified
                            ? 'Your mobile number has been verified.'
                            : 'Enter the 6-digit code sent to\n$_maskedPhoneNumber',
                        style: const TextStyle(
                          color: Color(0xFF71697F),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: compact ? 28 : 38),
                      const Text(
                        'Verification code',
                        style: TextStyle(
                          color: Color(0xFF49454F),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _OtpField(
                        controller: _otpController,
                        onChanged: (_) => setState(() {}),
                      ),
                      if (_submitted && !_hasCompleteOtp && !_isVerified) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Enter the complete 6-digit code',
                          style: TextStyle(
                            color: Color(0xFFB3261E),
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (_verificationError != null && !_isVerified) ...[
                        const SizedBox(height: 8),
                        Text(
                          _verificationError!,
                          style: const TextStyle(
                            color: Color(0xFFB3261E),
                            fontSize: 12,
                          ),
                        ),
                      ],
                      SizedBox(height: compact ? 24 : 32),
                      if (_isVerified)
                        PrimaryButton(
                          label: 'Done',
                          onPressed: () =>
                              Navigator.of(context)
                                ..popUntil((route) => route.isFirst),
                        )
                      else
                        PrimaryButton(
                          label: 'Verify',
                          onPressed: _hasCompleteOtp ? _verify : null,
                          isLoading: _isLoading,
                        ),
                      const SizedBox(height: 24),
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              'Didn’t receive the code? ',
                              style: TextStyle(
                                color: Color(0xFF71697F),
                                fontSize: 13,
                              ),
                            ),
                            if (_isResending)
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              TextButton(
                                onPressed: _secondsRemaining == 0
                                    ? _resendCode
                                    : null,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  _secondsRemaining == 0
                                      ? 'Resend code'
                                      : 'Resend in 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    color: _secondsRemaining == 0
                                        ? const Color(0xFF6650B6)
                                        : const Color(0xFFAAA5B2),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (_resendError != null) ...[
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            _resendError!,
                            style: const TextStyle(
                              color: Color(0xFFB3261E),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 26),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Change mobile number'),
                        ),
                      ),
                      if (!_isVerified) ...[
                        SizedBox(height: compact ? 16 : 26),
                        const _DemoOtpHint(),
                      ],
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
}

class _OtpField extends StatelessWidget {
  const _OtpField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('otp-code'),
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      textAlign: TextAlign.center,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      style: const TextStyle(
        color: Color(0xFF252137),
        fontSize: 23,
        fontWeight: FontWeight.w600,
        letterSpacing: 11,
      ),
      decoration: InputDecoration(
        hintText: '• • • • • •',
        hintStyle: const TextStyle(
          color: Color(0xFFCAC4D0),
          fontSize: 18,
          letterSpacing: 5,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E1ED)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E1ED)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6650B6), width: 1.5),
        ),
      ),
    );
  }
}

class _DemoOtpHint extends StatelessWidget {
  const _DemoOtpHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0ECFA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Demo mode: use 123456 to verify. Replace DemoAuthService with '
        'Firebase Phone Auth when you are ready.',
        style: TextStyle(color: Color(0xFF4A4459), fontSize: 12, height: 1.45),
      ),
    );
  }
}
