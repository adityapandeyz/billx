import 'package:flutter/material.dart';

class CurrentFirmProvider with ChangeNotifier {
  String _currentFirmName = '';
  String _currentFirmId = '';
  String _currentFirmGSTIN = '';
  String _currentFirmPhone = '';
  String _currentFirmAddress = '';

  String get currentFirmName => _currentFirmName;
  String get currentFirmId => _currentFirmId;
  String get currentFirmGSTIN => _currentFirmGSTIN;
  String get currentFirmPhone => _currentFirmPhone;
  String get currentFirmAddress => _currentFirmAddress;

  void setCurrentFirm(
      {required String firmName,
      required String firmId,
      required String gstin,
      required String phone,
      required String address}) {
    _currentFirmName = firmName;
    _currentFirmId = firmId;
    _currentFirmGSTIN = gstin;
    _currentFirmPhone = phone;
    _currentFirmAddress = address;
    notifyListeners();
  }
}
