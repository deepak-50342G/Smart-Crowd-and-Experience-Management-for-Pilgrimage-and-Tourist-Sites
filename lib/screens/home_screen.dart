import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../localization/app_language.dart';
import '../services/travel_assistant_service.dart';
import 'emergency_support_screen.dart';
import 'explore_places_screen.dart';
import 'guide_screen.dart';
import 'profile_screens.dart';
import 'registration_flow_screen.dart';
import 'report_flow_screen.dart';
import 'safety_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.language,
    this.phoneNumber = '',
    this.countryCode = '+91',
    super.key,
  });

  final String language;
  final String phoneNumber;
  final String countryCode;

  bool get isHindi => language == 'Hindi';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isChatOpen = false;
  bool _isMenuOpen = false;
  bool _isSendingChat = false;
  String? _chatError;
  final _chatMessages = <_ChatMessage>[];
  final _assistantService = TravelAssistantService();
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    AppLanguage.language.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    AppLanguage.language.removeListener(_onLanguageChanged);
    _assistantService.dispose();
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  String _text(String english, String hindi) =>
      AppLanguage.text(english, hindi);

  Future<void> _sendChatMessage(String message) async {
    final prompt = message.trim();
    if (prompt.isEmpty || _isSendingChat) return;

    final history = _chatMessages
        .map((item) => {'role': item.role, 'text': item.text})
        .toList(growable: false);
    final recentHistory = history.length <= 20
        ? history
        : history.sublist(history.length - 20);
    final usableHistory =
        recentHistory.isNotEmpty && recentHistory.first['role'] == 'assistant'
        ? recentHistory.skip(1).toList(growable: false)
        : recentHistory;
    setState(() {
      _chatMessages.add(_ChatMessage(role: 'user', text: prompt));
      _isSendingChat = true;
      _chatError = null;
    });

    try {
      final reply = await _assistantService.reply(
        message: prompt,
        history: usableHistory,
      );
      if (!mounted) return;
      setState(() {
        _chatMessages.add(_ChatMessage(role: 'assistant', text: reply));
      });
    } on TravelAssistantException catch (error) {
      if (!mounted) return;
      setState(() {
        _chatError = AppLanguage.translate(error.message);
      });
    } finally {
      if (mounted) setState(() => _isSendingChat = false);
    }
  }

  void _openProfile() {
    setState(() => _isMenuOpen = false);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MyProfileScreen(
          phoneNumber: widget.phoneNumber,
          countryCode: widget.countryCode,
        ),
      ),
    );
  }

  void _openExplorePlaces() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExplorePlacesScreen(
          phoneNumber: widget.phoneNumber,
          countryCode: widget.countryCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1F5),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildSearchBar(),
                const _ScenicBanner(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(
                      children: [
                        Expanded(
                          child: GridView.count(
                            key: const Key('home-feature-grid'),
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.18,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _FeatureCard(
                                title: _text(
                                  'Emergency & Support',
                                  'आपातकालीन सहायता',
                                ),
                                imageAsset:
                                    'assets/images/home/emergency_support.jpg',
                                color: const Color(0xFFFF1B1B),
                                cardKey: const Key('emergency-support-card'),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const EmergencySupportScreen(),
                                  ),
                                ),
                              ),
                              _FeatureCard(
                                title: _text('Register', 'पंजीकरण'),
                                imageAsset: 'assets/images/home/register.jpg',
                                color: const Color(0xFF00A8C6),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => RegistrationFlowScreen(
                                      isHindi: AppLanguage.isHindi,
                                      phoneNumber: widget.phoneNumber,
                                      countryCode: widget.countryCode,
                                    ),
                                  ),
                                ),
                              ),
                              _FeatureCard(
                                title: _text('Report Problem', 'समस्या बताएं'),
                                imageAsset:
                                    'assets/images/home/report_problem.jpg',
                                color: const Color(0xFF3B171C),
                                cardKey: const Key('report-problem-card'),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const ReportProblemScreen(),
                                  ),
                                ),
                              ),
                              _FeatureCard(
                                title: _text('Near Places', 'आस-पास की जगहें'),
                                imageAsset:
                                    'assets/images/home/near_places.jpg',
                                color: const Color(0xFF43B7CE),
                                cardKey: const Key('near-places-card'),
                                onTap: _openExplorePlaces,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                _buildBottomNavigation(),
              ],
            ),
            if (_isChatOpen) _buildChatPanel(),
            if (_isMenuOpen) _buildMenuDrawer(),
            Positioned(right: 18, bottom: 58, child: _buildChatButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFEAE5EE),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            IconButton(
              key: const Key('home-menu'),
              tooltip: _text('Menu', 'मेन्यू'),
              onPressed: () => setState(() {
                _isMenuOpen = !_isMenuOpen;
                _isChatOpen = false;
              }),
              icon: const Icon(Icons.menu_rounded, size: 20),
              color: const Color(0xFF514A59),
            ),
            Expanded(
              child: InkWell(
                key: const Key('home-search'),
                onTap: _openExplorePlaces,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _text(
                          'Search destinations, tourist places...',
                          'मंज़िलें और पर्यटन स्थल खोजें...',
                        ),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF514A59),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF514A59),
                      size: 20,
                    ),
                    const SizedBox(width: 11),
                  ],
                ),
              ),
            )
          ],
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
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F5F9),
        border: Border(top: BorderSide(color: Color(0xFFE7E1E9))),
      ),
      child: Row(
        children: [
          for (var index = 0; index < tabs.length; index++)
            Expanded(
              child: InkWell(
                key: Key('home-tab-$index'),
                onTap: () {
                  if (index == 1) {
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
                    _openProfile();
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

  Widget _buildChatButton() {
    return Semantics(
      button: true,
      label: _text('Open travel assistant', 'यात्रा सहायक खोलें'),
      child: Material(
        color: const Color(0xFFFFD000),
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          key: const Key('chat-toggle'),
          customBorder: const CircleBorder(),
          onTap: () => setState(() {
            _isChatOpen = !_isChatOpen;
            _isMenuOpen = false;
          }),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              _isChatOpen ? Icons.close_rounded : Icons.chat_bubble_rounded,
              color: const Color(0xFF302A24),
              size: 25,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuDrawer() {
    return Positioned(
      left: 12,
      top: 10,
      bottom: 62,
      width: MediaQuery.sizeOf(context).width * 0.58,
      child: Material(
        color: const Color(0xFFD1C3D7),
        elevation: 5,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF368BFF), width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    key: const Key('menu-close'),
                    tooltip: _text('Close menu', 'मेन्यू बंद करें'),
                    onPressed: () => setState(() => _isMenuOpen = false),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 30,
                      height: 30,
                    ),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF46404B),
                      size: 19,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFE7E0EA),
                      shape: const CircleBorder(),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _text('Menu', 'मेन्यू'),
                    style: const TextStyle(
                      color: Color(0xFF302A38),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                child: InkWell(
                  key: const Key('menu-profile'),
                  onTap: _openProfile,
                  borderRadius: BorderRadius.circular(7),
                  child: Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4DFE6),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFF29252E),
                          size: 19,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _text('Profile', 'प्रोफ़ाइल'),
                          style: const TextStyle(
                            color: Color(0xFF29252E),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatPanel() {
    return Positioned(
      left: 20,
      bottom: 78,
      width: MediaQuery.sizeOf(context).width * 0.75,
      height: MediaQuery.sizeOf(context).height * 0.54,
      child: Material(
        elevation: 8,
        color: const Color(0xFFDFC86E),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4E8B4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.smart_toy_outlined, size: 13),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        _text(
                          'Hello! So how may I help you?',
                          'नमस्ते! मैं आपकी क्या मदद कर सकता हूँ?',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  key: const Key('chat-history'),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: _chatMessages.length,
                  itemBuilder: (context, index) {
                    final message = _chatMessages[index];
                    return _ChatMessageBubble(
                      message: message.text,
                      isUser: message.role == 'user',
                    );
                  },
                ),
              ),
              if (_chatError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    _chatError!,
                    key: const Key('chat-error'),
                    style: const TextStyle(
                      color: Color(0xFF9B1C1C),
                      fontSize: 10,
                    ),
                  ),
                ),
              if (_isSendingChat)
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: LinearProgressIndicator(
                    key: Key('chat-loading'),
                    minHeight: 2,
                  ),
                ),
              _ChatComposer(
                hint: _text(
                  'What would you like to know?',
                  'आप क्या जानना चाहेंगे?',
                ),
                sendLabel: _text('Send message', 'संदेश भेजें'),
                isSending: _isSendingChat,
                onSend: (message) => unawaited(_sendChatMessage(message)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({required this.role, required this.text});

  final String role;
  final String text;
}

class _ChatMessageBubble extends StatelessWidget {
  const _ChatMessageBubble({required this.message, required this.isUser});

  final String message;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250),
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFF8F5E9) : const Color(0xFFF4E8B4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message, style: const TextStyle(fontSize: 11)),
      ),
    );
  }
}

class _ScenicBanner extends StatelessWidget {
  const _ScenicBanner();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Image.asset(
        'assets/images/home/home_banner.png',
        key: const Key('home-banner'),
        fit: BoxFit.cover,
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.imageAsset,
    required this.color,
    this.onTap,
    this.cardKey,
  });

  final String title;
  final String imageAsset;
  final Color color;
  final VoidCallback? onTap;
  final Key? cardKey;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: cardKey ?? (onTap == null ? null : const Key('register-card')),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.asset(imageAsset, fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatComposer extends StatefulWidget {
  const _ChatComposer({
    required this.hint,
    required this.sendLabel,
    required this.isSending,
    required this.onSend,
  });

  final String hint;
  final String sendLabel;
  final bool isSending;
  final ValueChanged<String> onSend;

  @override
  State<_ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<_ChatComposer> {
  final _controller = TextEditingController();

  void _send() {
    final message = _controller.text.trim();
    if (message.isEmpty || widget.isSending) return;
    _controller.clear();
    widget.onSend(message);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.fromLTRB(9, 5, 6, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              key: const Key('chat-message'),
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: const TextStyle(
                  color: Color(0xFFAAA5B2),
                  fontSize: 10,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.only(top: 5),
              ),
              style: const TextStyle(fontSize: 11),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.image_outlined, size: 15),
              const SizedBox(width: 9),
              const Icon(Icons.code_rounded, size: 15),
              const SizedBox(width: 9),
              const Icon(Icons.mic_none_rounded, size: 15),
              const Spacer(),
              Semantics(
                button: true,
                label: widget.sendLabel,
                child: InkWell(
                  key: const Key('chat-send'),
                  customBorder: const CircleBorder(),
                  onTap: _send,
                  child: const CircleAvatar(
                    radius: 11,
                    backgroundColor: Color(0xFF6650B6),
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
