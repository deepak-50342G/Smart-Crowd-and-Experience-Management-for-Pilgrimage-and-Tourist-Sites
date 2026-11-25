import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../localization/app_language.dart';
import '../models/profile_data.dart';

const _profilePurple = Color(0xFF563B98);
const _profileInk = Color(0xFF302A43);
const _profileMutedText = Color(0xFF5F596D);
const _profileHintText = Color(0xFF6B6578);
const _profileCanvas = Color(0xFFF7F7FC);
const _profileLine = Color(0xFFE9E6F0);
const _profileYellow = Color(0xFFFFCC00);

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({
    required this.phoneNumber,
    required this.countryCode,
    super.key,
  });

  final String phoneNumber;
  final String countryCode;

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  ProfileData? _profile;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final profile = await ProfileStorage.load(
        fallbackPhoneNumber: _formatPhoneNumber(
          widget.countryCode,
          widget.phoneNumber,
        ),
      );
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } on ProfilePersistenceException {
      _showLoadError(
        AppLanguage.translate(
          'Profile data could not be loaded. Please try again.',
        ),
      );
    } on FormatException {
      _showLoadError(
        AppLanguage.translate(
          'Saved profile data is invalid. Please try again.',
        ),
      );
    }
  }

  void _showLoadError(String message) {
    if (!mounted) return;
    setState(() {
      _loadError = message;
      _isLoading = false;
    });
  }

  Future<void> _editProfile() async {
    final profile = _profile;
    if (profile == null) return;

    final updatedProfile = await Navigator.of(context).push<ProfileData>(
      MaterialPageRoute<ProfileData>(
        builder: (_) =>
            EditProfileScreen(profile: profile, onSave: ProfileStorage.save),
      ),
    );
    if (updatedProfile == null || !mounted) return;
    setState(() => _profile = updatedProfile);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(AppLanguage.translate('Profile updated.'))),
      );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    return Scaffold(
      backgroundColor: _profileCanvas,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                _ProfilePageHeader(
                  title: 'My profile',
                  subtitle: 'Your details, all in one place',
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: _profilePurple,
                          ),
                        )
                      : _loadError != null
                      ? _ProfileLoadError(
                          message: _loadError!,
                          onRetry: _loadProfile,
                        )
                      : profile == null
                      ? _ProfileLoadError(
                          message: AppLanguage.translate(
                            'Profile data could not be loaded. Please try again.',
                          ),
                          onRetry: _loadProfile,
                        )
                      : _ProfileDetails(profile: profile, onEdit: _editProfile),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _ProfileBottomNavigation(),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  const _ProfileDetails({required this.profile, required this.onEdit});

  final ProfileData profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('my-profile-content'),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  key: const Key('profile-full-name-display'),
                  style: const TextStyle(
                    color: _profileInk,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  profile.username,
                  key: const Key('profile-username'),
                  style: const TextStyle(
                    color: _profileMutedText,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EAF5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${AppLanguage.translate('User ID')}  ·  ${profile.userId}',
                    key: const Key('profile-user-id'),
                    style: const TextStyle(
                      color: _profileInk,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: FilledButton(
                    key: const Key('profile-edit'),
                    onPressed: onEdit,
                    style: FilledButton.styleFrom(
                      backgroundColor: _profileYellow,
                      foregroundColor: _profileInk,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(AppLanguage.translate('Edit profile')),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ProfileSectionTitle('Personal information'),
          const SizedBox(height: 6),
          _ProfileInfoCard(
            rows: [
              _ProfileInfoRow(
                label: 'Email address',
                value: profile.email,
                key: const Key('profile-email'),
              ),
              _ProfileInfoRow(
                label: 'Phone number',
                value: profile.phoneNumber,
                key: const Key('profile-phone'),
              ),
              _ProfileInfoRow(
                label: 'Home city',
                value: AppLanguage.translate(profile.homeCity),
                key: const Key('profile-city'),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileSectionTitle('Travel preferences'),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ProfilePreference(
                    label: 'Language',
                    value: AppLanguage.translate(profile.language),
                    key: const Key('profile-language'),
                  ),
                ),
                Container(width: 1, height: 34, color: _profileLine),
                Expanded(
                  child: _ProfilePreference(
                    label: 'Travel style',
                    value: AppLanguage.translate(profile.travelStyle),
                    key: const Key('profile-travel-style'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6D8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLanguage.translate('EMERGENCY CONTACT'),
                  style: TextStyle(
                    color: Color(0xFF735B14),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${profile.emergencyContactName} · ${profile.emergencyContactPhone}',
                  key: const Key('profile-emergency-contact'),
                  style: const TextStyle(
                    color: _profileInk,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    required this.profile,
    required this.onSave,
    super.key,
  });

  final ProfileData profile;
  final Future<void> Function(ProfileData profile) onSave;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const _cities = <String>[
    'New Delhi, India',
    'Jaipur, India',
    'Varanasi, India',
    'Rishikesh, India',
    'Haridwar, India',
    'Mumbai, India',
    'Other',
  ];
  static const _languages = <String>['English, Hindi', 'English', 'Hindi'];
  static const _travelStyles = <String>[
    'Culture & Nature',
    'Spiritual',
    'Adventure',
    'Relaxed',
    'Family',
  ];
  static const _maxPhotoBytes = 2 * 1024 * 1024;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _imagePicker = ImagePicker();

  late String _homeCity;
  late String _language;
  late String _travelStyle;
  late bool _notificationsEnabled;
  late bool _isProfilePublic;
  String? _photoBase64;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.profile.fullName;
    _emailController.text = widget.profile.email;
    _phoneController.text = widget.profile.phoneNumber;
    _emergencyNameController.text = widget.profile.emergencyContactName;
    _emergencyPhoneController.text = widget.profile.emergencyContactPhone;
    _homeCity = widget.profile.homeCity;
    _language = widget.profile.language;
    _travelStyle = widget.profile.travelStyle;
    _notificationsEnabled = widget.profile.notificationsEnabled;
    _isProfilePublic = widget.profile.isProfilePublic;
    _photoBase64 = widget.profile.photoBase64;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(AppLanguage.translate(message))));
  }

  Future<void> _changePhoto() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 700,
        maxHeight: 700,
        imageQuality: 85,
      );
      if (image == null) return;

      final extension = image.name.split('.').last.toLowerCase();
      if (!const {'jpg', 'jpeg', 'png'}.contains(extension)) {
        _showMessage('Choose a JPG or PNG photo.');
        return;
      }

      if (await image.length() > _maxPhotoBytes) {
        _showMessage('Choose a photo smaller than 2 MB.');
        return;
      }
      final bytes = await image.readAsBytes();
      if (bytes.lengthInBytes > _maxPhotoBytes) {
        _showMessage('Choose a photo smaller than 2 MB.');
        return;
      }
      if (!mounted) return;
      setState(() => _photoBase64 = base64Encode(bytes));
    } on PlatformException {
      _showMessage('Could not open that photo. Please try again.');
    } on MissingPluginException {
      _showMessage('Photo selection is not available on this device.');
    } on UnsupportedError {
      _showMessage('This device does not support photo selection.');
    }
  }

  Future<void> _editPrivacySettings() async {
    var selectedValue = _isProfilePublic;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(AppLanguage.translate('Privacy Settings')),
          content: SwitchListTile.adaptive(
            key: const Key('privacy-public-toggle'),
            contentPadding: EdgeInsets.zero,
            value: selectedValue,
            onChanged: (value) => setDialogState(() {
              selectedValue = value;
            }),
            activeTrackColor: _profilePurple,
            title: Text(AppLanguage.translate('Public profile')),
            subtitle: Text(
              AppLanguage.translate('Control your profile visibility'),
            ),
          ),
          actions: [
            TextButton(
              key: const Key('privacy-cancel'),
              onPressed: () => Navigator.pop(context),
              child: Text(AppLanguage.translate('Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, selectedValue),
              child: Text(AppLanguage.translate('Done')),
            ),
          ],
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() => _isProfilePublic = result);
    }
  }

  Future<void> _saveChanges() async {
    if (_isSaving || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    final updatedProfile = widget.profile.copyWith(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      emergencyContactName: _emergencyNameController.text.trim(),
      emergencyContactPhone: _emergencyPhoneController.text.trim(),
      homeCity: _homeCity,
      language: _language,
      travelStyle: _travelStyle,
      notificationsEnabled: _notificationsEnabled,
      isProfilePublic: _isProfilePublic,
      photoBase64: _photoBase64,
    );

    try {
      await widget.onSave(updatedProfile);
      await AppLanguage.setLanguage(updatedProfile.language);
      if (mounted) Navigator.of(context).pop(updatedProfile);
    } on ProfilePersistenceException {
      _showMessage('Your changes could not be saved. Please try again.');
    } on AppLanguagePersistenceException {
      _showMessage('Could not update the app language. Please try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  List<String> _optionsWithCurrentValue(
    List<String> options,
    String currentValue,
  ) {
    return options.contains(currentValue)
        ? options
        : [currentValue, ...options];
  }

  @override
  Widget build(BuildContext context) {
    final photoBytes = _decodePhoto(_photoBase64);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1FF),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                children: [
                  Row(
                    children: [
                      IconButton(
                        key: const Key('edit-profile-back'),
                        tooltip: AppLanguage.translate('Back to profile'),
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: _profilePurple,
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFE7E0F5),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: _profilePurple,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.explore_rounded,
                        color: _profilePurple,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'YatraFlow',
                        style: TextStyle(
                          color: _profilePurple,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: const Color(0xFFDCCFFF),
                        foregroundImage: photoBytes == null
                            ? null
                            : MemoryImage(photoBytes),
                        child: photoBytes == null
                            ? const Icon(
                                Icons.person_rounded,
                                size: 46,
                                color: _profilePurple,
                              )
                            : null,
                      ),
                      const SizedBox(height: 3),
                      TextButton.icon(
                        key: const Key('profile-change-photo'),
                        onPressed: _changePhoto,
                        icon: const Icon(Icons.camera_alt_rounded, size: 14),
                        label: Text(AppLanguage.translate('Change Photo')),
                        style: TextButton.styleFrom(
                          foregroundColor: _profilePurple,
                          visualDensity: VisualDensity.compact,
                          textStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        AppLanguage.translate('JPG, PNG • Max 2 MB'),
                        style: TextStyle(color: _profileMutedText, fontSize: 9),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _EditSectionCard(
                    title: 'Personal Information',
                    icon: Icons.person_rounded,
                    children: [
                      _ProfileTextField(
                        fieldKey: const Key('profile-full-name'),
                        controller: _nameController,
                        label: 'Full Name *',
                        hint: 'Enter your full name',
                        icon: Icons.person_outline_rounded,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Full name is required.'
                            : null,
                      ),
                      _ProfileTextField(
                        fieldKey: const Key('profile-email-input'),
                        controller: _emailController,
                        label: 'Email Address *',
                        hint: 'your.email@example.com',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) {
                            return 'Email address is required.';
                          }
                          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                              .hasMatch(email)) {
                            return 'Enter a valid email address.';
                          }
                          return null;
                        },
                      ),
                      _ProfileTextField(
                        fieldKey: const Key('profile-phone-input'),
                        controller: _phoneController,
                        label: 'Phone Number *',
                        hint: '+91 XXXXX XXXXX',
                        icon: Icons.call_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9+()\-\s]'),
                          ),
                        ],
                        validator: (value) =>
                            value == null || value.trim().length < 7
                            ? 'Enter a valid phone number.'
                            : null,
                      ),
                      _ProfileDropdown(
                        fieldKey: const Key('profile-city-dropdown'),
                        label: 'Home City *',
                        icon: Icons.location_on_outlined,
                        value: _homeCity,
                        options: _optionsWithCurrentValue(_cities, _homeCity),
                        onChanged: (value) {
                          if (value != null) setState(() => _homeCity = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _EditSectionCard(
                    title: 'Travel Preferences',
                    icon: Icons.explore_rounded,
                    children: [
                      _ProfileDropdown(
                        fieldKey: const Key('profile-language-dropdown'),
                        label: 'Language',
                        icon: Icons.language_rounded,
                        value: _language,
                        options: _optionsWithCurrentValue(
                          _languages,
                          _language,
                        ),
                        onChanged: (value) {
                          if (value != null) setState(() => _language = value);
                        },
                      ),
                      _ProfileDropdown(
                        fieldKey: const Key('profile-travel-style-dropdown'),
                        label: 'Travel Style',
                        icon: Icons.luggage_outlined,
                        value: _travelStyle,
                        options: _optionsWithCurrentValue(
                          _travelStyles,
                          _travelStyle,
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _travelStyle = value);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _EditSectionCard(
                    title: 'Emergency Contact',
                    icon: Icons.contact_phone_outlined,
                    children: [
                      _ProfileTextField(
                        fieldKey: const Key('profile-emergency-contact-name'),
                        controller: _emergencyNameController,
                        label: 'Contact Name *',
                        hint: 'Enter emergency contact name',
                        icon: Icons.person_outline_rounded,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Emergency contact name is required.'
                            : null,
                      ),
                      _ProfileTextField(
                        fieldKey: const Key('profile-emergency-contact-phone'),
                        controller: _emergencyPhoneController,
                        label: 'Contact Number *',
                        hint: 'Enter emergency contact number',
                        icon: Icons.call_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9+()\-\s]'),
                          ),
                        ],
                        validator: (value) =>
                            value == null || value.trim().length < 7
                            ? 'Enter a valid emergency contact number.'
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _EditSectionCard(
                    title: 'Account Settings',
                    icon: Icons.tune_rounded,
                    children: [
                      SwitchListTile.adaptive(
                        key: const Key('profile-notifications-toggle'),
                        contentPadding: EdgeInsets.zero,
                        value: _notificationsEnabled,
                        onChanged: (value) =>
                            setState(() => _notificationsEnabled = value),
                        activeTrackColor: _profilePurple,
                        title: Text(
                          AppLanguage.translate('Notification Preferences'),
                          style: TextStyle(
                            color: _profileInk,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          AppLanguage.translate(
                            'Get updates about new destinations',
                          ),
                          style: TextStyle(
                            color: _profileMutedText,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      ListTile(
                        key: const Key('profile-privacy-settings'),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        onTap: _editPrivacySettings,
                        leading: const Icon(
                          Icons.shield_outlined,
                          color: _profilePurple,
                          size: 18,
                        ),
                        title: Text(
                          AppLanguage.translate('Privacy Settings'),
                          style: TextStyle(
                            color: _profileInk,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          AppLanguage.translate(
                            'Control your profile visibility',
                          ),
                          style: TextStyle(
                            color: _profileMutedText,
                            fontSize: 9,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: _profilePurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: FilledButton(
                      key: const Key('profile-save'),
                      onPressed: _isSaving ? null : _saveChanges,
                      style: FilledButton.styleFrom(
                        backgroundColor: _profileYellow,
                        foregroundColor: _profileInk,
                        disabledBackgroundColor: const Color(0xFFFFE987),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _profileInk,
                              ),
                            )
                          : Text(AppLanguage.translate('Save Changes')),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 34,
                    child: TextButton(
                      key: const Key('profile-cancel'),
                      onPressed: () => Navigator.of(context).maybePop(),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFE2E0E5),
                        foregroundColor: _profilePurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(AppLanguage.translate('Cancel')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfilePageHeader extends StatelessWidget {
  const _ProfilePageHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      child: Row(
        children: [
          IconButton(
            key: const Key('profile-back'),
            tooltip: AppLanguage.translate('Back'),
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: _profileInk,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFE7E5EB),
              fixedSize: const Size(34, 34),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLanguage.translate(title),
                  style: const TextStyle(
                    color: _profileInk,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLanguage.translate(subtitle),
                  style: const TextStyle(color: _profileMutedText, fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSectionTitle extends StatelessWidget {
  const _ProfileSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLanguage.translate(title),
      style: const TextStyle(
        color: _profileInk,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({required this.rows});

  final List<_ProfileInfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(children: rows),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.label,
    required this.value,
    this.showDivider = true,
    super.key,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: _profileLine))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLanguage.translate(label),
            style: const TextStyle(color: _profileMutedText, fontSize: 9),
          ),
          const SizedBox(height: 3),
          Text(
            AppLanguage.translate(value),
            style: const TextStyle(
              color: _profileInk,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePreference extends StatelessWidget {
  const _ProfilePreference({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLanguage.translate(label),
            style: const TextStyle(color: _profileMutedText, fontSize: 9),
          ),
          const SizedBox(height: 4),
          Text(
            AppLanguage.translate(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _profileInk,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBottomNavigation extends StatefulWidget {
  const _ProfileBottomNavigation();

  @override
  State<_ProfileBottomNavigation> createState() =>
      _ProfileBottomNavigationState();
}

class _ProfileBottomNavigationState extends State<_ProfileBottomNavigation> {
  static const _tabs = <(IconData, String)>[
    (Icons.home_outlined, 'Home'),
    (Icons.chat_bubble_outline_rounded, 'Guide'),
    (Icons.verified_user_outlined, 'Safety'),
    (Icons.person_outline_rounded, 'You'),
  ];

  int _selectedTab = 3;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 48,
        decoration: const BoxDecoration(
          color: Color(0xFFF8F5F9),
          border: Border(top: BorderSide(color: _profileLine)),
        ),
        child: Row(
          children: [
            for (var index = 0; index < _tabs.length; index++)
              Expanded(
                child: InkWell(
                  key: Key('profile-tab-$index'),
                  onTap: () {
                    if (index == 0) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    } else {
                      setState(() => _selectedTab = index);
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: _selectedTab == index ? 36 : 24,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _selectedTab == index
                              ? _profileYellow
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _tabs[index].$1,
                          size: 15,
                          color: _selectedTab == index
                              ? _profileInk
                              : _profileMutedText,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        AppLanguage.translate(_tabs[index].$2),
                        style: TextStyle(
                          fontSize: 8,
                          color: _selectedTab == index
                              ? _profileInk
                              : _profileMutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileLoadError extends StatelessWidget {
  const _ProfileLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLanguage.translate(message), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
              key: const Key('profile-retry'),
              onPressed: onRetry,
              child: Text(AppLanguage.translate('Try again')),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditSectionCard extends StatelessWidget {
  const _EditSectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 15, color: _profilePurple),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    AppLanguage.translate(title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _profilePurple,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...children.map(
              (child) =>
                  Padding(padding: const EdgeInsets.only(top: 5), child: child),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(
        color: _profileInk,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: AppLanguage.translate(label),
        hintText: AppLanguage.translate(hint),
        labelStyle: const TextStyle(color: _profileMutedText, fontSize: 10),
        hintStyle: const TextStyle(color: _profileHintText, fontSize: 10),
        prefixIcon: Icon(icon, size: 15, color: _profilePurple),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 34,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        errorStyle: const TextStyle(fontSize: 9),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDCCFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _profilePurple),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFB3261E)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFB3261E)),
        ),
      ),
    );
  }
}

class _ProfileDropdown extends StatelessWidget {
  const _ProfileDropdown({
    required this.fieldKey,
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final Key fieldKey;
  final String label;
  final IconData icon;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: fieldKey,
      initialValue: value,
      isExpanded: true,
      onChanged: onChanged,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: _profilePurple,
        size: 18,
      ),
      style: const TextStyle(
        color: _profileInk,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
      items: options
          .map(
            (option) => DropdownMenuItem<String>(
              value: option,
              child: Text(
                AppLanguage.translate(option),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      decoration: InputDecoration(
        labelText: AppLanguage.translate(label),
        labelStyle: const TextStyle(color: _profileMutedText, fontSize: 10),
        prefixIcon: Icon(icon, size: 15, color: _profilePurple),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 34,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDCCFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _profilePurple),
        ),
      ),
    );
  }
}

String _formatPhoneNumber(String countryCode, String phoneNumber) {
  final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '+91 98765 43210';
  if (digits.length == 10) {
    return '$countryCode ${digits.substring(0, 5)} ${digits.substring(5)}';
  }
  return '$countryCode $phoneNumber';
}

Uint8List? _decodePhoto(String? encodedPhoto) {
  if (encodedPhoto == null || encodedPhoto.isEmpty) return null;
  try {
    return base64Decode(encodedPhoto);
  } on FormatException {
    return null;
  }
}
