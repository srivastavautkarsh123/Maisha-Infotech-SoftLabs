class UserLocation {
  final double latitude;
  final double longitude;
  final String street;
  final String subLocality;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String fullAddress;

  UserLocation({
    required this.latitude,
    required this.longitude,
    required this.street,
    required this.subLocality,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.fullAddress,
  });

  String get shortAddress {
    final parts = [subLocality, city].where((p) => p.trim().isNotEmpty).toList();
    if (parts.isNotEmpty) {
      return parts.join(', ');
    }
    return city.isNotEmpty ? city : (fullAddress.isNotEmpty ? fullAddress : 'Current Location');
  }
}
