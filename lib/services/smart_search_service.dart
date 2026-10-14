import '../models/house.dart';

/// Converts a natural-language housing request into structured filters.
/// Example: "two bedroom house in Kitengela below 30,000 with parking"
class SmartSearchService {
  static HouseFilter parse(String raw) {
    final text = raw.toLowerCase();

    String? location;
    for (final town in [
      'kitengela',
      'kajiado',
      'nairobi',
      'rongai',
      'ngong',
      'athi river',
      'athiriver',
      'syokimau',
    ]) {
      if (text.contains(town)) {
        location = town == 'athiriver' ? 'Athi River' : _title(town);
        break;
      }
    }

    int? bedrooms;
    final bedMatch = RegExp(r'(\d+)\s*(?:bed|bedroom|br)\b').firstMatch(text);
    if (bedMatch != null) {
      bedrooms = int.tryParse(bedMatch.group(1)!);
    } else if (text.contains('bedsitter') || text.contains('studio')) {
      bedrooms = 1;
    } else if (text.contains('two bedroom') || text.contains('2 bedroom')) {
      bedrooms = 2;
    } else if (text.contains('three bedroom') || text.contains('3 bedroom')) {
      bedrooms = 3;
    } else if (text.contains('four bedroom') || text.contains('4 bedroom')) {
      bedrooms = 4;
    }

    String? houseType;
    for (final t in [
      'bedsitter',
      'studio',
      'apartment',
      'maisonette',
      'bungalow',
      'villa',
      'townhouse',
    ]) {
      if (text.contains(t)) {
        houseType = _title(t);
        break;
      }
    }

    double? maxPrice;
    double? minPrice;
    final below = RegExp(r'(?:below|under|less than|max(?:imum)?)\s*(?:ksh|kes)?\s*([\d,]+)').firstMatch(text);
    final between = RegExp(r'(?:between|from)\s*(?:ksh|kes)?\s*([\d,]+)\s*(?:and|to|-)\s*(?:ksh|kes)?\s*([\d,]+)').firstMatch(text);
    final plain = RegExp(r'(?:ksh|kes)?\s*([\d,]+)\s*(?:ksh|kes|/)?').allMatches(text).toList();
    if (between != null) {
      minPrice = _num(between.group(1)!);
      maxPrice = _num(between.group(2)!);
    } else if (below != null) {
      maxPrice = _num(below.group(1)!);
    } else if (text.contains('below') || text.contains('under')) {
      for (final m in plain) {
        final n = _num(m.group(1)!);
        if (n != null && n >= 5000) {
          maxPrice = n;
          break;
        }
      }
    }

    bool? parking;
    if (text.contains('parking') || text.contains('car park')) parking = true;

    String? security;
    if (text.contains('high security') ||
        text.contains('good security') ||
        text.contains('secure') ||
        text.contains('gated')) {
      security = 'High';
    }

    bool? furnished;
    if (text.contains('furnished') && !text.contains('unfurnished')) {
      furnished = true;
    } else if (text.contains('unfurnished')) {
      furnished = false;
    }

    return HouseFilter(
      location: location,
      bedrooms: bedrooms,
      houseType: houseType,
      minPrice: minPrice,
      maxPrice: maxPrice,
      parking: parking,
      security: security,
      furnished: furnished,
    );
  }

  static double? _num(String s) => double.tryParse(s.replaceAll(',', ''));

  static String _title(String s) {
    if (s == 'athi river') return 'Athi River';
    return s[0].toUpperCase() + s.substring(1);
  }

  static List<String> explain(HouseFilter f) {
    final out = <String>[];
    if (f.location != null) out.add('Location = ${f.location}');
    if (f.bedrooms != null) out.add('Bedrooms = ${f.bedrooms}');
    if (f.houseType != null) out.add('House type = ${f.houseType}');
    if (f.minPrice != null) out.add('Minimum price = ${f.minPrice!.toStringAsFixed(0)}');
    if (f.maxPrice != null) out.add('Maximum price = ${f.maxPrice!.toStringAsFixed(0)}');
    if (f.parking == true) out.add('Parking = Yes');
    if (f.security != null) out.add('Security = ${f.security}');
    if (f.furnished != null) out.add('Furnished = ${f.furnished! ? 'Yes' : 'No'}');
    return out;
  }
}
