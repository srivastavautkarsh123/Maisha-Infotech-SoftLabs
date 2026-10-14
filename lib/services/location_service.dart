import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/location_model.dart';

class LocationService {
  // Check whether device GPS service is currently turned on
  Future<bool> isGpsEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Open device location settings directly
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  // Open app permission settings
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  // Fetch current or last known GPS location
  Future<UserLocation> getCurrentLocation() async {
    // 1. Check & Request Permissions first
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permission was denied. Tap here to grant permission or pick an address.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permission is permanently denied. Please enable in App Settings.';
    }

    // 2. Check if GPS service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    Position? position;

    if (!serviceEnabled) {
      // Try last known position as non-blocking instant fallback
      position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        throw 'GPS is turned off. Please enable device location.';
      }
    } else {
      // 3. Fetch fresh GPS coordinates
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }
    }

    if (position == null) {
      throw 'Could not determine GPS coordinates. Please check device location.';
    }

    // 4. Reverse Geocode to street / locality
    try {
      final List<Placemark> placemarks =
          await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;

        final street = place.street ?? '';
        final subLocality = place.subLocality ?? '';
        final locality = place.locality ?? '';
        final state = place.administrativeArea ?? '';
        final postalCode = place.postalCode ?? '';
        final country = place.country ?? '';

        final addressParts = [
          street,
          subLocality,
          locality,
          state,
          postalCode,
          country
        ].where((element) => element.trim().isNotEmpty).toList();

        final fullAddress = addressParts.join(', ');

        return UserLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          street: street,
          subLocality: subLocality,
          city: locality.isNotEmpty ? locality : subLocality,
          state: state,
          postalCode: postalCode,
          country: country,
          fullAddress: fullAddress.isNotEmpty
              ? fullAddress
              : 'Lat: ${position.latitude.toStringAsFixed(4)}, Lon: ${position.longitude.toStringAsFixed(4)}',
        );
      }
    } catch (_) {
      // Geocoding service fallback
    }

    return UserLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      street: '',
      subLocality: '',
      city: 'Current Location',
      state: '',
      postalCode: '',
      country: '',
      fullAddress:
          'Lat: ${position.latitude.toStringAsFixed(4)}, Lon: ${position.longitude.toStringAsFixed(4)}',
    );
  }
}
