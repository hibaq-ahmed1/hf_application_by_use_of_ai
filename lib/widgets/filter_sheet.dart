import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../models/house.dart';
import '../theme/app_colors.dart';

class FilterSheet extends StatefulWidget {
  final HouseFilter initial;
  final ValueChanged<HouseFilter> onApply;

  const FilterSheet({
    super.key,
    required this.initial,
    required this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late TextEditingController _minPrice;
  late TextEditingController _maxPrice;
  String? _location;
  String? _houseType;
  int? _bedrooms;
  int? _bathrooms;
  bool? _parking;
  String? _security;
  bool? _furnished;
  double _maxDistance = 25;

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
  static const securities = ['Gated', '24hr Guard', 'Electric Fence'];

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _minPrice = TextEditingController(
      text: f.minPrice?.toStringAsFixed(0) ?? '',
    );
    _maxPrice = TextEditingController(
      text: f.maxPrice?.toStringAsFixed(0) ?? '',
    );
    _location = f.location;
    _houseType = f.houseType;
    _bedrooms = f.bedrooms;
    _bathrooms = f.bathrooms;
    _parking = f.parking;
    _security = f.security;
    _furnished = f.furnished;
    _maxDistance = f.maxDistanceKm ?? 25;
  }

  @override
  void dispose() {
    _minPrice.dispose();
    _maxPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    Text(
                      'Advanced filters',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _location = null;
                          _houseType = null;
                          _bedrooms = null;
                          _bathrooms = null;
                          _parking = null;
                          _security = null;
                          _furnished = null;
                          _maxDistance = 25;
                          _minPrice.clear();
                          _maxPrice.clear();
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    _label('Town / location'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: towns.map((t) {
                        final selected = _location == t;
                        return ChoiceChip(
                          label: Text(t),
                          selected: selected,
                          onSelected: (_) => setState(
                            () => _location = selected ? null : t,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    _label('Price range (KSh)'),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minPrice,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: 'Min'),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('—'),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _maxPrice,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: 'Max'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _label('House type'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: types.map((t) {
                        final selected = _houseType == t;
                        return ChoiceChip(
                          label: Text(t),
                          selected: selected,
                          onSelected: (_) => setState(
                            () => _houseType = selected ? null : t,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    _label('Bedrooms'),
                    _numberRow(
                      value: _bedrooms,
                      onChanged: (v) => setState(() => _bedrooms = v),
                    ),
                    const SizedBox(height: 12),
                    _label('Bathrooms'),
                    _numberRow(
                      value: _bathrooms,
                      onChanged: (v) => setState(() => _bathrooms = v),
                    ),
                    const SizedBox(height: 18),
                    _label('Max distance: ${_maxDistance.toStringAsFixed(0)} km'),
                    Slider(
                      value: _maxDistance,
                      min: 1,
                      max: 50,
                      divisions: 49,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _maxDistance = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Parking required'),
                      secondary: const Icon(LucideIcons.car),
                      value: _parking ?? false,
                      onChanged: (v) => setState(() => _parking = v ? true : null),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Furnished'),
                      secondary: const Icon(LucideIcons.sofa),
                      value: _furnished ?? false,
                      onChanged: (v) => setState(() => _furnished = v ? true : null),
                    ),
                    const SizedBox(height: 8),
                    _label('Security'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: securities.map((s) {
                        final selected = _security == s;
                        return ChoiceChip(
                          label: Text(s),
                          selected: selected,
                          onSelected: (_) => setState(
                            () => _security = selected ? null : s,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          widget.onApply(
                            HouseFilter(
                              location: _location,
                              minPrice: double.tryParse(_minPrice.text),
                              maxPrice: double.tryParse(_maxPrice.text),
                              houseType: _houseType,
                              bedrooms: _bedrooms,
                              bathrooms: _bathrooms,
                              parking: _parking,
                              security: _security,
                              furnished: _furnished,
                              maxDistanceKm: _maxDistance,
                            ),
                          );
                          Navigator.pop(context);
                        },
                        icon: const Icon(LucideIcons.slidersHorizontal, size: 18),
                        label: const Text('Apply filters'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      );

  Widget _numberRow({required int? value, required ValueChanged<int?> onChanged}) {
    return Wrap(
      spacing: 8,
      children: [1, 2, 3, 4].map((n) {
        final selected = value == n;
        return ChoiceChip(
          label: Text('$n+'),
          selected: selected,
          onSelected: (_) => onChanged(selected ? null : n),
        );
      }).toList(),
    );
  }
}
