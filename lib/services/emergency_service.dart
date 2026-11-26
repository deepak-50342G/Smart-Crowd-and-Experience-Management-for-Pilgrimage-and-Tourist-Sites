import 'package:geolocator/geolocator.dart';

enum SosStatus {
  submitted,
  awaitingAcknowledgement,
  acknowledged,
  assistanceDispatched,
  resolved,
  failed,
}

class SosRequest {
  const SosRequest({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.submittedAt,
    required this.status,
    this.isMock = false,
  });

  final String id;
  final double latitude;
  final double longitude;
  final DateTime submittedAt;
  final SosStatus status;
  final bool isMock;
}

abstract interface class EmergencyRepository {
  Future<SosRequest> submitSos({
    required double latitude,
    required double longitude,
  });

  Future<String> submitIncident({
    required String issueType,
    required String description,
    required double? latitude,
    required double? longitude,
    required String? photoPath,
  });
}

class MockEmergencyRepository implements EmergencyRepository {
  int _sosSequence = 0;

  @override
  Future<SosRequest> submitSos({
    required double latitude,
    required double longitude,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    _sosSequence++;
    final now = DateTime.now();
    return SosRequest(
      id: 'SOS-${now.year}-${_sosSequence.toString().padLeft(3, '0')}',
      latitude: latitude,
      longitude: longitude,
      submittedAt: now,
      status: SosStatus.awaitingAcknowledgement,
      isMock: true,
    );
  }

  @override
  Future<String> submitIncident({
    required String issueType,
    required String description,
    required double? latitude,
    required double? longitude,
    required String? photoPath,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return 'INC-DEMO-$stamp';
  }
}

class LocationException implements Exception {
  const LocationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LocationService {
  Future<Position> currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(
        'Location services are disabled. Turn on GPS and try again.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException(
        'Location permission was denied. Allow location access to send SOS.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Location permission is permanently denied. Enable it in app settings.',
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } on Exception {
      throw const LocationException(
        'Your location could not be obtained. Check GPS and try again.',
      );
    }
  }
}
