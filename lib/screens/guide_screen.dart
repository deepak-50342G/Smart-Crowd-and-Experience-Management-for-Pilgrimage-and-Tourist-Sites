import 'package:material_ui/material_ui.dart';

import '../localization/app_language.dart';
import 'profile_screens.dart';
import 'safety_screen.dart';

const _guidePurple = Color(0xFF6429C8);
const _guideInk = Color(0xFF24134F);
const _guideMuted = Color(0xFF746A91);
const _guideBackground = Color(0xFFF8F5FF);

enum _UpdateKind { alert, event, news, info }

class _GuideUpdate {
  const _GuideUpdate({
    required this.id,
    required this.kind,
    required this.title,
    required this.summary,
    required this.location,
    required this.timeAgo,
    required this.icon,
    required this.accent,
    required this.tileColor,
    required this.advisory,
    required this.precautions,
  });

  final String id;
  final _UpdateKind kind;
  final String title;
  final String summary;
  final String location;
  final String timeAgo;
  final IconData icon;
  final Color accent;
  final Color tileColor;
  final String advisory;
  final List<String> precautions;

  String get kindLabel => switch (kind) {
    _UpdateKind.alert => 'ALERT',
    _UpdateKind.event => 'EVENT',
    _UpdateKind.news => 'NEWS',
    _UpdateKind.info => 'INFO',
  };
}

const _guideUpdates = <_GuideUpdate>[
  _GuideUpdate(
    id: 'rainfall',
    kind: _UpdateKind.alert,
    title: 'Heavy Rainfall Alert',
    summary: 'Avoid travel to lower areas of Vaishno Devi track.',
    location: 'Katra & Vaishno Devi track',
    timeAgo: '2h ago',
    icon: Icons.warning_rounded,
    accent: Color(0xFFE84268),
    tileColor: Color(0xFFFFE9EF),
    advisory: 'Heavy rainfall may affect visibility and travel conditions on parts of the route. Check official updates before departure.',
    precautions: [
      'Avoid exposed or low-lying areas.',
      'Follow route staff and official guidance.',
      'Allow extra time; conditions may change.',
    ],
  ),
  _GuideUpdate(
    id: 'bhajan-sandhya',
    kind: _UpdateKind.event,
    title: 'Bhajan Sandhya',
    summary: 'Today at 7:00 PM at Bhawan Premises.',
    location: 'Bhawan Premises',
    timeAgo: '3h ago',
    icon: Icons.event_note_rounded,
    accent: Color(0xFF8A4DE8),
    tileColor: Color(0xFFF0E8FF),
    advisory: 'Bhajan Sandhya is scheduled for today at 7:00 PM at the Bhawan Premises.',
    precautions: [
      'Arrive early and follow venue directions.',
      'Keep walkways clear and follow staff instructions.',
      'Check local announcements for schedule changes.',
    ],
  ),
  _GuideUpdate(
    id: 'facilities',
    kind: _UpdateKind.news,
    title: 'New Facilities at Bhawan',
    summary: 'Improved queue management system now live.',
    location: 'Bhawan',
    timeAgo: '5h ago',
    icon: Icons.article_rounded,
    accent: Color(0xFF3885F6),
    tileColor: Color(0xFFE5F0FF),
    advisory: 'An improved queue management system is now available at Bhawan to help guide visitors through the premises.',
    precautions: [
      'Follow the queue signs and staff directions.',
      'Keep your registration details accessible.',
      'Allow extra time during busy periods.',
    ],
  ),
  _GuideUpdate(
    id: 'helpline',
    kind: _UpdateKind.info,
    title: 'Helpline Update',
    summary: 'New helpline number: 1800-891-9031 (sample)',
    location: 'Visitor support',
    timeAgo: '6h ago',
    icon: Icons.info_rounded,
    accent: Color(0xFFFF791C),
    tileColor: Color(0xFFFFF0E3),
    advisory: 'This sample notice includes a demonstration helpline number. Verify contact details through official channels before calling.',
    precautions: [
      'Do not rely on sample contact details.',
      'Use verified official sources for assistance.',
      'For immediate danger, contact local emergency services.',
    ],
  ),
];

class GuideScreen extends StatelessWidget {
  const GuideScreen({
    this.phoneNumber = '',
    this.countryCode = '+91',
    super.key,
  });

  final String phoneNumber;
  final String countryCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _guideBackground,
      appBar: AppBar(
        backgroundColor: _guideBackground,
        foregroundColor: _guideInk,
        leading: IconButton(
          key: const Key('guide-back'),
          tooltip: AppLanguage.translate('Back'),
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          AppLanguage.translate('Guide'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDE5FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_rounded,
                    color: _guidePurple,
                    size: 22,
                  ),
                ),
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE7355C),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
            child: Column(
              children: [
                Text(
                  AppLanguage.translate('Latest Updates & Alerts'),
                  style: const TextStyle(color: _guideMuted, fontSize: 13),
                ),
                const SizedBox(height: 14),
                Container(
                  key: const Key('guide-notifications-filter'),
                  height: 40,
                  width: 230,
                  decoration: BoxDecoration(
                    color: _guidePurple,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.white,
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLanguage.translate('Notifications'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              key: const Key('guide-updates-list'),
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              itemCount: _guideUpdates.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final update = _guideUpdates[index];
                return _GuideUpdateCard(
                  update: update,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _GuideUpdateDetailScreen(update: update),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _GuideBottomNavigation(
        phoneNumber: phoneNumber,
        countryCode: countryCode,
      ),
    );
  }
}

class _GuideUpdateCard extends StatelessWidget {
  const _GuideUpdateCard({required this.update, required this.onTap});

  final _GuideUpdate update;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: update.accent,
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100F0B20),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.only(left: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          key: Key('guide-update-${update.id}'),
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 60,
                  decoration: BoxDecoration(
                    color: update.tileColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(update.icon, color: update.accent, size: 30),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: update.tileColor,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          AppLanguage.translate(update.kindLabel),
                          style: TextStyle(
                            color: update.accent,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        AppLanguage.translate(update.title),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _guideInk,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLanguage.translate(update.summary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _guideMuted,
                          fontSize: 10,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: _guideMuted,
                            size: 10,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            AppLanguage.translate(update.timeAgo),
                            style: const TextStyle(
                              color: _guideMuted,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_left_rounded, color: _guideInk, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideUpdateDetailScreen extends StatelessWidget {
  const _GuideUpdateDetailScreen({required this.update});

  final _GuideUpdate update;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _guideBackground,
      appBar: AppBar(
        backgroundColor: _guideBackground,
        foregroundColor: _guideInk,
        leading: IconButton(
          key: const Key('guide-detail-back'),
          tooltip: AppLanguage.translate('Back'),
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(AppLanguage.translate('Alert Details')),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                Container(
                  height: 126,
                  decoration: BoxDecoration(
                    color: update.tileColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    update.kind == _UpdateKind.alert
                        ? Icons.thunderstorm_rounded
                        : update.icon,
                    color: update.accent,
                    size: 62,
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: update.tileColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppLanguage.translate(update.kindLabel),
                      style: TextStyle(
                        color: update.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLanguage.translate(update.title),
                  key: const Key('guide-detail-title'),
                  style: const TextStyle(
                    color: _guideInk,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppLanguage.translate(update.location)} · ${AppLanguage.translate(update.timeAgo)}',
                  style: const TextStyle(color: _guideMuted, fontSize: 12),
                ),
                const SizedBox(height: 14),
                _DetailSection(
                  title: AppLanguage.translate('Advisory'),
                  child: Text(
                    AppLanguage.translate(update.advisory),
                    style: const TextStyle(
                      color: _guideMuted,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _DetailSection(
                  title: AppLanguage.translate('Recommended precautions'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final precaution in update.precautions)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 5, right: 7),
                                child: Icon(
                                  Icons.circle,
                                  color: _guidePurple,
                                  size: 6,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  AppLanguage.translate(precaution),
                                  style: const TextStyle(
                                    color: _guideMuted,
                                    fontSize: 12,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLanguage.translate(
                    'Illustrative alert content — not live update data.',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _guideMuted, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E0F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _guideInk,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _GuideBottomNavigation extends StatelessWidget {
  const _GuideBottomNavigation({
    required this.phoneNumber,
    required this.countryCode,
  });

  final String phoneNumber;
  final String countryCode;

  static const _tabs = <(IconData, String)>[
    (Icons.home_outlined, 'Home'),
    (Icons.auto_awesome, 'Guide'),
    (Icons.shield_outlined, 'Safety'),
    (Icons.person_outline_rounded, 'You'),
    (Icons.more_horiz_rounded, 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 42,
        decoration: const BoxDecoration(
          color: Color(0xFFF8F5FF),
          border: Border(top: BorderSide(color: Color(0xFFE7E0F2))),
        ),
        child: Row(
          children: [
            for (var index = 0; index < _tabs.length; index++)
              Expanded(
                child: InkWell(
                  key: Key('guide-tab-$index'),
                  onTap: () {
                    if (index == 0) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    } else if (index == 2) {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => SafetyScreen(
                            phoneNumber: phoneNumber,
                            countryCode: countryCode,
                          ),
                        ),
                      );
                    } else if (index == 3) {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => MyProfileScreen(
                            phoneNumber: phoneNumber,
                            countryCode: countryCode,
                          ),
                        ),
                      );
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _tabs[index].$1,
                        size: 13,
                        color: index == 1 ? _guidePurple : _guideMuted,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        AppLanguage.translate(_tabs[index].$2),
                        style: TextStyle(
                          fontSize: 8,
                          color: index == 1 ? _guidePurple : _guideMuted,
                          fontWeight: index == 1
                              ? FontWeight.w700
                              : FontWeight.normal,
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
