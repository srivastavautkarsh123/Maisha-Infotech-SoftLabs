import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';

class LocationViewModel extends ChangeNotifier {
  final LocationService _locationService;

  LocationViewModel({LocationService? locationService})
      : _locationService = locationService ?? LocationService();

  UserLocation? _currentLocation;
  String _address = 'Bengaluru, Karnataka - 560038';
  String _pincode = '560038';
  bool _isLoading = false;
  String? _errorMessage;
  bool _isGpsDisabled = false;

  UserLocation? get currentLocation => _currentLocation;
  String get address => _address;
  String get pincode => _pincode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isGpsDisabled => _isGpsDisabled;

  String get shortDisplay {
    if (_currentLocation != null && _currentLocation!.city.isNotEmpty) {
      return '${_currentLocation!.city}${_pincode.isNotEmpty ? " - $_pincode" : ""}';
    }
    return _address.length > 25 ? '${_address.substring(0, 25)}...' : _address;
  }

  Future<void> fetchLocation() async {
    _isLoading = true;
    _errorMessage = null;
    _isGpsDisabled = false;
    notifyListeners();

    try {
      final loc = await _locationService.getCurrentLocation();
      _currentLocation = loc;
      _address = loc.fullAddress;
      if (loc.postalCode.isNotEmpty) {
        _pincode = loc.postalCode;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      _isGpsDisabled = e.toString().toLowerCase().contains('gps');
      // Keep existing default address so checkout and app display never break
      notifyListeners();
    }
  }

  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  void updateManualAddress(String newAddress, {String? pincode}) {
    _address = newAddress;
    if (pincode != null && pincode.isNotEmpty) {
      _pincode = pincode;
    }
    _errorMessage = null;
    notifyListeners();
  }

  void selectPresetCity(String city, String state, String pincode) {
    _address = '$city, $state - $pincode';
    _pincode = pincode;
    _currentLocation = UserLocation(
      latitude: 0,
      longitude: 0,
      street: '',
      subLocality: '',
      city: city,
      state: state,
      postalCode: pincode,
      country: 'India',
      fullAddress: '$city, $state - $pincode',
    );
    _errorMessage = null;
    notifyListeners();
  }
}
