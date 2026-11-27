import 'package:material_ui/material_ui.dart';

import '../localization/app_language.dart';
import 'guide_screen.dart';
import 'profile_screens.dart';
import 'safety_screen.dart';

const _explorePurple = Color(0xFF6650B6);
const _exploreInk = Color(0xFF2E2941);
const _exploreMuted = Color(0xFF777180);
const _exploreCanvas = Color(0xFFF8F6FC);

enum _PlaceFilter { allPlaces, quietNow, nearMe }

class _Place {
  const _Place({
    required this.id,
    required this.name,
    required this.category,
    required this.distance,
    required this.crowd,
    required this.capacity,
    required this.bestTime,
    required this.quietNow,
    required this.nearMe,
    required this.icon,
    required this.placeholderColor,
    this.imageAsset,
    this.keywords = const [],
  });

  final String id;
  final String name;
  final String category;
  final String distance;
  final String crowd;
  final int capacity;
  final String bestTime;
  final bool quietNow;
  final bool nearMe;
  final IconData icon;
  final Color placeholderColor;
  final String? imageAsset;
  final List<String> keywords;
}

const _places = <_Place>[
  _Place(
    id: 'amber-fort',
    name: 'Amber Fort',
    category: 'Fort & Heritage',
    distance: '11 km',
    crowd: 'Low',
    capacity: 32,
    bestTime: 'Best time: now–11 AM',
    quietNow: true,
    nearMe: false,
    icon: Icons.castle_rounded,
    placeholderColor: Color(0xFFE7D6BB),
    imageAsset: 'assets/images/home/amber_fort.jpg',
    keywords: ['Amer Fort', 'fort', 'heritage', 'Jaipur'],
  ),
  _Place(
    id: 'hawa-mahal',
    name: 'Hawa Mahal',
    category: 'Architecture',
    distance: '1.2 km',
    crowd: 'Moderate',
    capacity: 58,
    bestTime: 'Quieter after 4 PM',
    quietNow: false,
    nearMe: false,
    icon: Icons.account_balance_rounded,
    placeholderColor: Color(0xFFF5DDCC),
    imageAsset: 'assets/images/home/hawa_mahal.jpg',
    keywords: ['Palace of Winds', 'architecture', 'palace', 'Jaipur'],
  ),
  _Place(
    id: 'city-palace',
    name: 'City Palace',
    category: 'Museum & Culture',
    distance: '2.1 km',
    crowd: 'Busy',
    capacity: 81,
    bestTime: 'Try Amber Fort instead',
    quietNow: false,
    nearMe: false,
    icon: Icons.museum_rounded,
    placeholderColor: Color(0xFFE9DDEB),
    imageAsset: 'assets/images/home/city_palace.jpg',
    keywords: ['museum', 'culture', 'palace', 'Jaipur'],
  ),
  _Place(
    id: 'jantar-mantar',
    name: 'Jantar Mantar',
    category: 'Science & Heritage',
    distance: '2.2 km',
    crowd: 'Low',
    capacity: 28,
    bestTime: 'Best time: now–11 AM',
    quietNow: true,
    nearMe: false,
    icon: Icons.public_rounded,
    placeholderColor: Color(0xFFDCEBFA),
    imageAsset: 'assets/images/home/jantar_mantar.jpg',
    keywords: ['observatory', 'science', 'heritage', 'Jaipur'],
  ),
  _Place(
    id: 'jal-mahal',
    name: 'Jal Mahal',
    category: 'Palace & Scenic View',
    distance: '4.8 km',
    crowd: 'Low',
    capacity: 25,
    bestTime: 'Best time: now–11 AM',
    quietNow: true,
    nearMe: false,
    icon: Icons.water_rounded,
    placeholderColor: Color(0xFFD9EDF2),
    imageAsset: 'assets/images/home/jal_mahal.jpg',
    keywords: ['water', 'lake', 'scenic', 'Jaipur'],
  ),
  _Place(
    id: 'albert-hall',
    name: 'Albert Hall Museum',
    category: 'Museum · Architecture · Heritage',
    distance: 'Nearby',
    crowd: 'Low',
    capacity: 32,
    bestTime: 'Best time: 3–7 PM',
    quietNow: false,
    nearMe: true,
    icon: Icons.account_balance_rounded,
    placeholderColor: Color(0xFFE8E1D8),
    imageAsset: 'assets/images/home/albert_hall_museum.jpg',
    keywords: ['museum', 'architecture', 'heritage', 'Jaipur'],
  ),
  _Place(
    id: 'nahargarh-fort',
    name: 'Nahargarh Fort',
    category: 'Fort · Scenic viewpoint · Heritage',
    distance: 'Nearby',
    crowd: 'Moderate',
    capacity: 48,
    bestTime: 'Best time: 4:30–5:30 PM',
    quietNow: false,
    nearMe: true,
    icon: Icons.castle_rounded,
    placeholderColor: Color(0xFFE4E6D8),
    imageAsset: 'assets/images/home/nahargarh_fort.jpg',
    keywords: ['fort', 'viewpoint', 'heritage', 'Jaipur'],
  ),
  _Place(
    id: 'jaigarh-fort',
    name: 'Jaigarh Fort',
    category: 'Military heritage · Fort · Photography',
    distance: 'Nearby',
    crowd: 'Low',
    capacity: 20,
    bestTime: 'Best time: 8–11 AM',
    quietNow: true,
    nearMe: true,
    icon: Icons.castle_rounded,
    placeholderColor: Color(0xFFE9D8C6),
    imageAsset: 'assets/images/home/jaigarh_fort.jpg',
    keywords: ['military', 'fort', 'photography', 'Jaipur'],
  ),
];

class ExplorePlacesScreen extends StatefulWidget {
  const ExplorePlacesScreen({
    this.initialQuery = '',
    this.phoneNumber = '',
    this.countryCode = '+91',
    super.key,
  });

  final String initialQuery;
  final String phoneNumber;
  final String countryCode;

  @override
  State<ExplorePlacesScreen> createState() => _ExplorePlacesScreenState();
}

class _ExplorePlacesScreenState extends State<ExplorePlacesScreen> {
  late final TextEditingController _searchController;
  _PlaceFilter _selectedFilter = _PlaceFilter.allPlaces;
  String _submittedQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _submittedQuery = widget.initialQuery.trim();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String value) {
    setState(() => _submittedQuery = value.trim());
    FocusScope.of(context).unfocus();
  }

  List<_Place> get _visiblePlaces {
    return _places
        .where((place) {
          final matchesFilter = switch (_selectedFilter) {
            _PlaceFilter.allPlaces => const {
              'amber-fort',
              'hawa-mahal',
              'city-palace',
            }.contains(place.id),
            _PlaceFilter.quietNow => place.quietNow,
            _PlaceFilter.nearMe => place.nearMe,
          };
          if (!matchesFilter) return false;
          if (_submittedQuery.isEmpty) return true;

          final searchableText = [
            place.name,
            place.category,
            place.distance,
            ...place.keywords,
          ].join(' ').toLowerCase();
          return searchableText.contains(_submittedQuery.toLowerCase());
        })
        .toList(growable: false);
  }

  void _selectFilter(_PlaceFilter filter) {
    setState(() => _selectedFilter = filter);
  }

  @override
  Widget build(BuildContext context) {
    final visiblePlaces = _visiblePlaces;
    return Scaffold(
      backgroundColor: _exploreCanvas,
      appBar: AppBar(
        backgroundColor: _exploreCanvas,
        foregroundColor: _exploreInk,
        toolbarHeight: 62,
        leadingWidth: 48,
        leading: IconButton(
          key: const Key('explore-back'),
          tooltip: AppLanguage.translate('Back'),
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFFE6E2E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLanguage.translate('Explore Jaipur'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            Text(
              AppLanguage.translate('Find your place. Skip the crowds.'),
              style: const TextStyle(color: _exploreMuted, fontSize: 10),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 2, 18, 10),
            child: _buildSearchField(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                _FilterChip(
                  label: AppLanguage.translate('All places'),
                  selected: _selectedFilter == _PlaceFilter.allPlaces,
                  onTap: () => _selectFilter(_PlaceFilter.allPlaces),
                  chipKey: const Key('explore-filter-all'),
                ),
                const SizedBox(width: 7),
                _FilterChip(
                  label: AppLanguage.translate('Quiet now'),
                  selected: _selectedFilter == _PlaceFilter.quietNow,
                  onTap: () => _selectFilter(_PlaceFilter.quietNow),
                  chipKey: const Key('explore-filter-quiet'),
                ),
                const SizedBox(width: 7),
                _FilterChip(
                  label: AppLanguage.translate('Near me'),
                  selected: _selectedFilter == _PlaceFilter.nearMe,
                  onTap: () => _selectFilter(_PlaceFilter.nearMe),
                  chipKey: const Key('explore-filter-near'),
                ),
              ],
            ),
          ),
          if (_selectedFilter == _PlaceFilter.nearMe)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLanguage.translate(
                    'Nearby suggestions are examples; location is not accessed.',
                  ),
                  style: const TextStyle(color: _exploreMuted, fontSize: 9),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLanguage.translate('A good time to explore'),
                  style: const TextStyle(
                    color: _exploreInk,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  AppLanguage.translate(
                    'Sample crowd suggestions. Check local updates before you go.',
                  ),
                  style: const TextStyle(color: _exploreMuted, fontSize: 10),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              key: const Key('explore-results'),
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              children: [
                if (visiblePlaces.isEmpty)
                  _EmptyResults(query: _submittedQuery)
                else
                  for (final place in visiblePlaces) ...[
                    _PlaceCard(place: place),
                    const SizedBox(height: 8),
                  ],
                const _CrowdForecastCard(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ExploreBottomNavigation(
        phoneNumber: widget.phoneNumber,
        countryCode: widget.countryCode,
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8E4EF)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        key: const Key('explore-search'),
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: _submitSearch,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: _exploreInk, fontSize: 12),
        decoration: InputDecoration(
          hintText: AppLanguage.translate('Search tourist sites'),
          hintStyle: const TextStyle(color: _exploreMuted, fontSize: 11),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _exploreMuted,
            size: 17,
          ),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  key: const Key('explore-search-submit'),
                  tooltip: AppLanguage.translate('Search'),
                  onPressed: () => _submitSearch(_searchController.text),
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: _explorePurple,
                    size: 17,
                  ),
                ),
          contentPadding: const EdgeInsets.symmetric(vertical: 9),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.chipKey,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Key chipKey;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 32,
        child: Material(
          color: selected ? _explorePurple : Colors.white,
          borderRadius: BorderRadius.circular(11),
          child: InkWell(
            key: chipKey,
            borderRadius: BorderRadius.circular(11),
            onTap: onTap,
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : _exploreMuted,
                  fontSize: 9,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place});

  final _Place place;

  Color get _crowdColor => switch (place.crowd) {
    'Low' => const Color(0xFF328264),
    'Moderate' => const Color(0xFFC36A18),
    _ => const Color(0xFFCC4054),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('place-card-${place.id}'),
      height: 78,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7E2EE)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: SizedBox(
              width: 58,
              height: 58,
              child: place.imageAsset == null
                  ? ColoredBox(
                      color: place.placeholderColor,
                      child: Icon(
                        place.icon,
                        color: const Color(0xFF78688F),
                        size: 28,
                      ),
                    )
                  : Image.asset(
                      place.imageAsset!,
                      key: Key('place-image-${place.id}'),
                      semanticLabel: place.name,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => ColoredBox(
                        color: place.placeholderColor,
                        child: Icon(place.icon, color: const Color(0xFF78688F)),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLanguage.translate(place.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _exploreInk,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${AppLanguage.translate(place.category)} · ${AppLanguage.translate(place.distance)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _exploreMuted, fontSize: 9),
                ),
                const SizedBox(height: 2),
                Text(
                  '${AppLanguage.translate(place.crowd)} · ${place.capacity}% ${AppLanguage.translate('capacity')}',
                  style: TextStyle(
                    color: _crowdColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  AppLanguage.translate(place.bestTime),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _exploreMuted, fontSize: 8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CrowdForecastCard extends StatelessWidget {
  const _CrowdForecastCard();

  static const _hours = ['Now', '11 AM', '1 PM', '3 PM', '5 PM'];
  static const _levels = [0.26, 0.47, 0.72, 0.62, 0.38];

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('explore-crowd-forecast'),
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7E2EE)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLanguage.translate('Amber Fort · Crowd forecast'),
            style: const TextStyle(
              color: _exploreInk,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          SizedBox(
            height: 34,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var index = 0; index < _hours.length; index++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        height: 7 + (_levels[index] * 22),
                        decoration: BoxDecoration(
                          color: index == 0
                              ? const Color(0xFF6FB295)
                              : const Color(0xFFC4B5E9),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              for (final hour in _hours)
                Expanded(
                  child: Text(
                    AppLanguage.translate(hour),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _exploreMuted, fontSize: 7),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            AppLanguage.translate('Sample crowd estimate — not live data.'),
            style: const TextStyle(color: _exploreMuted, fontSize: 8),
          ),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, color: _exploreMuted, size: 34),
          const SizedBox(height: 8),
          Text(
            AppLanguage.translate('No places found'),
            style: const TextStyle(
              color: _exploreInk,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (query.isNotEmpty)
            Text(
              '${AppLanguage.translate('Try another search for')} "$query".',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _exploreMuted, fontSize: 11),
            ),
        ],
      ),
    );
  }
}

class _ExploreBottomNavigation extends StatelessWidget {
  const _ExploreBottomNavigation({
    required this.phoneNumber,
    required this.countryCode,
  });

  final String phoneNumber;
  final String countryCode;

  static const _tabs = <(IconData, String)>[
    (Icons.home_outlined, 'Home'),
    (Icons.chat_bubble_outline_rounded, 'Guide'),
    (Icons.verified_user_outlined, 'Safety'),
    (Icons.person_outline_rounded, 'You'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 48,
        decoration: const BoxDecoration(
          color: Color(0xFFF0ECF3),
          border: Border(top: BorderSide(color: Color(0xFFE4E0E8))),
        ),
        child: Row(
          children: [
            for (var index = 0; index < _tabs.length; index++)
              Expanded(
                child: InkWell(
                  key: Key('explore-tab-$index'),
                  onTap: () {
                    if (index == 0) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    } else if (index == 1) {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => GuideScreen(
                            phoneNumber: phoneNumber,
                            countryCode: countryCode,
                          ),
                        ),
                      );
                    } else if (index == 2) {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => SafetyScreen(
                            phoneNumber: phoneNumber,
                            countryCode: countryCode,
                          ),
                        ),
                      );
                    } else {
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
                      Icon(_tabs[index].$1, size: 16, color: _exploreMuted),
                      const SizedBox(height: 2),
                      Text(
                        AppLanguage.translate(_tabs[index].$2),
                        style: const TextStyle(
                          color: _exploreMuted,
                          fontSize: 9,
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
