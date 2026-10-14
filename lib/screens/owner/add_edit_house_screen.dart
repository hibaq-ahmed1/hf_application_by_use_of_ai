import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../data/sample_data.dart';
import '../../models/features.dart';
import '../../models/house.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/house_provider.dart';
import '../../theme/app_colors.dart';

class AddEditHouseScreen extends StatefulWidget {
  final House? house;

  const AddEditHouseScreen({super.key, this.house});

  @override
  State<AddEditHouseScreen> createState() => _AddEditHouseScreenState();
}

class _AddEditHouseScreenState extends State<AddEditHouseScreen> {
  late TextEditingController _title;
  late TextEditingController _description;
  late TextEditingController _price;
  late TextEditingController _address;
  late TextEditingController _area;
  late TextEditingController _ownerName;
  late TextEditingController _phone;
  late TextEditingController _email;
  late TextEditingController _imageUrl;
  late TextEditingController _amenities;
  String _town = 'Kitengela';
  String _houseType = 'Apartment';
  String _category = 'Residential';
  int _bedrooms = 2;
  int _bathrooms = 1;
  bool _parking = true;
  String _security = 'Gated';
  bool _furnished = false;
  FacilityFeatures _facilities = const FacilityFeatures();
  HouseAvailability _availability = HouseAvailability.available;
  final List<String> _images = [];

  @override
  void initState() {
    super.initState();
    final h = widget.house;
    final owner = context.read<AuthProvider>().currentUser;
    final cats = context.read<HouseProvider>().categories;
    _title = TextEditingController(text: h?.title ?? '');
    _description = TextEditingController(text: h?.description ?? '');
    _price = TextEditingController(text: h?.price.toStringAsFixed(0) ?? '');
    _address = TextEditingController(text: h?.address ?? '');
    _area = TextEditingController(text: h?.area ?? '');
    _ownerName = TextEditingController(text: h?.ownerName ?? owner?.fullName ?? '');
    _phone = TextEditingController(text: h?.ownerPhone ?? owner?.phone ?? '');
    _email = TextEditingController(text: h?.ownerEmail ?? owner?.email ?? '');
    _imageUrl = TextEditingController();
    _amenities = TextEditingController(text: h?.amenities.join(', ') ?? '');
    if (h != null) {
      _town = SampleData.towns.containsKey(h.town) ? h.town : 'Kitengela';
      _houseType = kHouseTypes.contains(h.houseType) ? h.houseType : 'Apartment';
      _category = cats.contains(h.category) ? h.category : cats.first;
      _bedrooms = h.bedrooms;
      _bathrooms = h.bathrooms;
      _parking = h.parking;
      _security = h.security;
      _furnished = h.furnished;
      _availability = h.availability;
      _facilities = h.facilities;
      _images.addAll(h.images);
    } else if (cats.isNotEmpty) {
      _category = cats.first;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _price.dispose();
    _address.dispose();
    _area.dispose();
    _ownerName.dispose();
    _phone.dispose();
    _email.dispose();
    _imageUrl.dispose();
    _amenities.dispose();
    super.dispose();
  }

  void _save() {
    final price = double.tryParse(_price.text);
    if (_title.text.trim().isEmpty || price == null || _address.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title, price, and address are required')),
      );
      return;
    }
    final meta = SampleData.towns[_town]!;
    final owner = context.read<AuthProvider>().currentUser!;
    final images = _images.isNotEmpty
        ? List<String>.from(_images)
        : ['https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800'];
    final amenities = _amenities.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final house = House(
      id: widget.house?.id ?? const Uuid().v4(),
      ownerId: widget.house?.ownerId ?? owner.id,
      title: _title.text.trim(),
      description: _description.text.trim(),
      price: price,
      town: _town,
      county: meta.county,
      address: _address.text.trim(),
      area: _area.text.trim().isEmpty ? null : _area.text.trim(),
      latitude: meta.lat,
      longitude: meta.lng,
      houseType: _houseType,
      category: _category,
      bedrooms: _bedrooms,
      bathrooms: _bathrooms,
      parking: _parking,
      security: _security,
      furnished: _furnished,
      availability: _availability,
      ownerName: _ownerName.text.trim(),
      ownerPhone: _phone.text.trim(),
      ownerEmail: _email.text.trim(),
      images: images,
      amenities: amenities,
      facilities: _facilities,
      approved: widget.house?.approved ?? (owner.role == UserRole.admin),
      reported: widget.house?.reported ?? false,
      reportReason: widget.house?.reportReason,
      viewCount: widget.house?.viewCount ?? 0,
      createdAt: widget.house?.createdAt ?? DateTime.now(),
    );

    final provider = context.read<HouseProvider>();
    if (widget.house == null) {
      provider.addHouse(house);
    } else {
      provider.updateHouse(house);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.house != null;
    final cats = context.watch<HouseProvider>().categories;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit listing' : 'Add house')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (editing)
            Text(
              'Property ID: ${widget.house!.id}',
              style: const TextStyle(color: AppColors.inkMuted),
            ),
          if (editing) const SizedBox(height: 12),
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Property title')),
          const SizedBox(height: 12),
          TextField(controller: _description, maxLines: 4, decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: 12),
          TextField(
            controller: _price,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Price (KSh / month)'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _town,
            items: SampleData.towns.keys
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _town = v!),
            decoration: const InputDecoration(labelText: 'Town'),
          ),
          const SizedBox(height: 8),
          Text(
            'County: ${SampleData.towns[_town]!.county}',
            style: const TextStyle(color: AppColors.inkMuted),
          ),
          const SizedBox(height: 12),
          TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address')),
          const SizedBox(height: 12),
          TextField(controller: _area, decoration: const InputDecoration(labelText: 'Area / estate')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _houseType,
            items: kHouseTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _houseType = v!),
            decoration: const InputDecoration(labelText: 'House type'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: cats.contains(_category) ? _category : cats.first,
            items: cats.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _category = v!),
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _bedrooms,
                  items: [1, 2, 3, 4, 5]
                      .map((n) => DropdownMenuItem(value: n, child: Text('$n beds')))
                      .toList(),
                  onChanged: (v) => setState(() => _bedrooms = v!),
                  decoration: const InputDecoration(labelText: 'Bedrooms'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _bathrooms,
                  items: [1, 2, 3, 4]
                      .map((n) => DropdownMenuItem(value: n, child: Text('$n baths')))
                      .toList(),
                  onChanged: (v) => setState(() => _bathrooms = v!),
                  decoration: const InputDecoration(labelText: 'Bathrooms'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _security,
            items: ['Gated', '24hr Guard', 'Electric Fence']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _security = v!),
            decoration: const InputDecoration(labelText: 'Security'),
          ),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Parking'), value: _parking, onChanged: (v) => setState(() => _parking = v)),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Furnished'), value: _furnished, onChanged: (v) => setState(() => _furnished = v)),
          const Text('Amenities', style: TextStyle(fontWeight: FontWeight.w700)),
          ..._amenityToggles(),
          DropdownButtonFormField<HouseAvailability>(
            initialValue: _availability,
            items: HouseAvailability.values
                .map(
                  (a) => DropdownMenuItem(
                    value: a,
                    child: Text(
                      a == HouseAvailability.available
                          ? 'Available'
                          : a == HouseAvailability.rented
                              ? 'Rented'
                              : 'Pending',
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _availability = v!),
            decoration: const InputDecoration(labelText: 'Availability'),
          ),
          const SizedBox(height: 16),
          const Text('Owner / agent information', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          TextField(controller: _ownerName, decoration: const InputDecoration(labelText: 'Owner/Agent name')),
          const SizedBox(height: 12),
          TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone number')),
          const SizedBox(height: 12),
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 12),
          TextField(
            controller: _amenities,
            decoration: const InputDecoration(labelText: 'Extra amenities (comma separated)'),
          ),
          const SizedBox(height: 16),
          const Text('Images (multiple)', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _imageUrl,
                  decoration: const InputDecoration(hintText: 'Paste image URL'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () {
                  if (_imageUrl.text.trim().isEmpty) return;
                  setState(() {
                    _images.add(_imageUrl.text.trim());
                    _imageUrl.clear();
                  });
                },
                icon: const Icon(LucideIcons.plus),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _images
                .map(
                  (url) => Chip(
                    label: Text(url.length > 28 ? '${url.substring(0, 28)}…' : url, style: const TextStyle(fontSize: 11)),
                    onDeleted: () => setState(() => _images.remove(url)),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _save,
            icon: Icon(editing ? LucideIcons.save : LucideIcons.plus, size: 18),
            label: Text(editing ? 'Update listing' : 'Publish listing'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<Widget> _amenityToggles() {
    void set(FacilityFeatures f) => setState(() => _facilities = f);
    return [
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Water'), value: _facilities.water, onChanged: (v) => set(_facilities.copyWith(water: v))),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Electricity'), value: _facilities.electricity, onChanged: (v) => set(_facilities.copyWith(electricity: v))),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Wi‑Fi'), value: _facilities.wifi, onChanged: (v) => set(_facilities.copyWith(wifi: v))),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('CCTV'), value: _facilities.cctv, onChanged: (v) => set(_facilities.copyWith(cctv: v))),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Garden'), value: _facilities.garden, onChanged: (v) => set(_facilities.copyWith(garden: v))),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Balcony'), value: _facilities.balcony, onChanged: (v) => set(_facilities.copyWith(balcony: v))),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Gated compound'), value: _facilities.gatedCompound, onChanged: (v) => set(_facilities.copyWith(gatedCompound: v))),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Pet friendly'), value: _facilities.petFriendly, onChanged: (v) => set(_facilities.copyWith(petFriendly: v))),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Family friendly'), value: _facilities.familyFriendly, onChanged: (v) => set(_facilities.copyWith(familyFriendly: v))),
    ];
  }
}
