import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/features.dart';
import '../../models/preferences.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

class PreferencesScreen extends StatefulWidget {
  final bool fromRegistration;

  const PreferencesScreen({super.key, this.fromRegistration = false});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  late TextEditingController _minBudget;
  late TextEditingController _maxBudget;
  late TextEditingController _area;
  String? _location;
  String? _houseType;
  int? _bedrooms;
  int? _bathrooms;
  double _maxDistance = 10;
  bool _parking = false;
  String? _security;
  bool _furnished = false;
  FacilityFeatures _facilities = const FacilityFeatures(
    water: false,
    electricity: false,
    wifi: false,
    cctv: false,
    gatedCompound: false,
  );

  static const towns = [
    'Kitengela',
    'Kajiado',
    'Nairobi',
    'Rongai',
    'Ngong',
    'Athi River',
  ];
  static const types = [
    'Bedsitter',
    'Studio',
    'Apartment',
    'Maisonette',
    'Bungalow',
    'Villa',
    'Townhouse',
  ];

  @override
  void initState() {
    super.initState();
    final p = context.read<AuthProvider>().preferences;
    _minBudget = TextEditingController(text: p?.minimumBudget?.toStringAsFixed(0) ?? '');
    _maxBudget = TextEditingController(text: p?.maximumBudget?.toStringAsFixed(0) ?? '');
    _area = TextEditingController(text: p?.preferredArea ?? '');
    _location = p?.preferredLocation;
    _houseType = p?.houseType;
    _bedrooms = p?.bedrooms;
    _bathrooms = p?.bathrooms;
    _maxDistance = p?.maximumDistance ?? 10;
    _parking = p?.parking ?? false;
    _security = p?.security;
    _furnished = p?.furnished ?? false;
    if (p != null) _facilities = p.wantedFacilities;
  }

  @override
  void dispose() {
    _minBudget.dispose();
    _maxBudget.dispose();
    _area.dispose();
    super.dispose();
  }

  void _save() {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser!;
    final existing = auth.preferences;
    auth.savePreferences(
      UserPreferences(
        id: existing?.id ?? const Uuid().v4(),
        userId: user.id,
        preferredLocation: _location,
        preferredArea: _area.text.trim().isEmpty ? null : _area.text.trim(),
        minimumBudget: double.tryParse(_minBudget.text),
        maximumBudget: double.tryParse(_maxBudget.text),
        houseType: _houseType,
        bedrooms: _bedrooms,
        bathrooms: _bathrooms,
        maximumDistance: _maxDistance,
        parking: _parking ? true : null,
        security: _security,
        furnished: _furnished,
        wantedFacilities: _facilities,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferences saved — AI recommendations updated')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fromRegistration ? 'Set your preferences' : 'House preferences'),
        automaticallyImplyLeading: !widget.fromRegistration,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.sparkles, color: AppColors.primary, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'These preferences feed the AI recommender: budget 25%, location/distance 20%, type 15%, bedrooms 15%, amenities 15%, behaviour 10%.',
                    style: TextStyle(fontSize: 13, height: 1.4, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _h('Preferred town / location'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: towns.map((t) {
              return ChoiceChip(
                label: Text(t),
                selected: _location == t,
                onSelected: (_) => setState(() => _location = _location == t ? null : t),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _area,
            decoration: const InputDecoration(
              labelText: 'Preferred area (optional)',
              hintText: 'e.g. Kitengela Heights',
              prefixIcon: Icon(LucideIcons.mapPin, size: 18),
            ),
          ),
          const SizedBox(height: 18),
          _h('Budget (KSh)'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minBudget,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Minimum'),
                ),
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('—')),
              Expanded(
                child: TextField(
                  controller: _maxBudget,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Maximum'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _h('House type'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: types.map((t) {
              return ChoiceChip(
                label: Text(t),
                selected: _houseType == t,
                onSelected: (_) => setState(() => _houseType = _houseType == t ? null : t),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          _h('Bedrooms'),
          Wrap(
            spacing: 8,
            children: [1, 2, 3, 4].map((n) {
              return ChoiceChip(
                label: Text('$n'),
                selected: _bedrooms == n,
                onSelected: (_) => setState(() => _bedrooms = _bedrooms == n ? null : n),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          _h('Bathrooms'),
          Wrap(
            spacing: 8,
            children: [1, 2, 3].map((n) {
              return ChoiceChip(
                label: Text('$n+'),
                selected: _bathrooms == n,
                onSelected: (_) => setState(() => _bathrooms = _bathrooms == n ? null : n),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          Text(
            'Maximum distance: ${_maxDistance.toStringAsFixed(0)} km',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Slider(
            value: _maxDistance,
            min: 1,
            max: 40,
            divisions: 39,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _maxDistance = v),
          ),
          _h('Features'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(LucideIcons.car),
            title: const Text('Parking'),
            value: _parking,
            onChanged: (v) => setState(() => _parking = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(LucideIcons.sofa),
            title: const Text('Furnished'),
            value: _furnished,
            onChanged: (v) => setState(() => _furnished = v),
          ),
          ..._featureSwitches(),
          const SizedBox(height: 8),
          _h('Security'),
          Wrap(
            spacing: 8,
            children: ['High', 'Gated', '24hr Guard', 'Electric Fence'].map((s) {
              return ChoiceChip(
                label: Text(s),
                selected: _security == s,
                onSelected: (_) => setState(() => _security = _security == s ? null : s),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          _h('Nearby facilities'),
          ..._nearbySwitches(),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(LucideIcons.sparkles, size: 18),
            label: Text(widget.fromRegistration ? 'Save & see AI matches' : 'Save preferences'),
          ),
          if (widget.fromRegistration)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Skip for now'),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _h(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
      );

  List<Widget> _featureSwitches() {
    return [
      _sw(LucideIcons.droplet, 'Water', _facilities.water, (v) => _facilities = _facilities.copyWith(water: v)),
      _sw(LucideIcons.zap, 'Electricity', _facilities.electricity, (v) => _facilities = _facilities.copyWith(electricity: v)),
      _sw(LucideIcons.wifi, 'Wi‑Fi', _facilities.wifi, (v) => _facilities = _facilities.copyWith(wifi: v)),
      _sw(LucideIcons.video, 'CCTV', _facilities.cctv, (v) => _facilities = _facilities.copyWith(cctv: v)),
      _sw(LucideIcons.shield, 'Gated compound', _facilities.gatedCompound, (v) => _facilities = _facilities.copyWith(gatedCompound: v)),
    ];
  }

  List<Widget> _nearbySwitches() {
    return [
      _sw(LucideIcons.graduationCap, 'School', _facilities.nearbySchools, (v) => _facilities = _facilities.copyWith(nearbySchools: v)),
      _sw(LucideIcons.cross, 'Hospital', _facilities.nearbyHospitals, (v) => _facilities = _facilities.copyWith(nearbyHospitals: v)),
      _sw(LucideIcons.shoppingBag, 'Shopping center', _facilities.nearbyShopping, (v) => _facilities = _facilities.copyWith(nearbyShopping: v)),
      _sw(LucideIcons.bus, 'Public transport', _facilities.publicTransport, (v) => _facilities = _facilities.copyWith(publicTransport: v)),
      _sw(LucideIcons.landmark, 'Religious facility', _facilities.religiousFacility, (v) => _facilities = _facilities.copyWith(religiousFacility: v)),
    ];
  }

  Widget _sw(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon),
      title: Text(title),
      value: value,
      onChanged: (v) => setState(() => onChanged(v)),
    );
  }
}
