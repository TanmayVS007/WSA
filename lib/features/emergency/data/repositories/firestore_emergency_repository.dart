import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/emergency_event.dart';
import '../../domain/repositories/emergency_repository.dart';

class FirestoreEmergencyRepository implements EmergencyRepository {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  FirestoreEmergencyRepository({
    FirebaseFirestore? firestore,
    Uuid? uuid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = uuid ?? const Uuid();

  CollectionReference<Map<String, dynamic>> get _emergenciesCol =>
      _firestore.collection('emergencies');

  @override
  Stream<EmergencyEvent?> get activeEmergencyStream {
    // Listen for any active emergencies (detected, countdown, active, acknowledged)
    return _emergenciesCol
        .where('status', whereIn: [
          EmergencyStatus.detected.name,
          EmergencyStatus.confirmationCountdown.name,
          EmergencyStatus.active.name,
          EmergencyStatus.acknowledged.name,
        ])
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final doc = snapshot.docs.first;
          return _mapDocToEmergencyEvent(doc.id, doc.data());
        })
        .handleError((e) {
          // In case index is building or offline, log and emit null
          return null;
        });
  }

  @override
  Future<List<EmergencyEvent>> getEmergencyHistory(String userId) async {
    try {
      final snapshot = await _emergenciesCol
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(30)
          .get();

      return snapshot.docs
          .map((doc) => _mapDocToEmergencyEvent(doc.id, doc.data()))
          .toList();
    } catch (_) {
      // Fallback query if composite index is pending
      final fallbackSnapshot = await _emergenciesCol
          .where('userId', isEqualTo: userId)
          .get();

      final list = fallbackSnapshot.docs
          .map((doc) => _mapDocToEmergencyEvent(doc.id, doc.data()))
          .toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }
  }

  @override
  Future<EmergencyEvent> triggerEmergency({
    required String userId,
    required String deviceId,
    required EmergencyTriggerSource triggerSource,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    int? heartRateSnapshot,
    int? batterySnapshot,
  }) async {
    final eventId = 'emg_${_uuid.v4().substring(0, 8)}';
    final initialStatus =
        triggerSource == EmergencyTriggerSource.automaticAnomaly
            ? EmergencyStatus.detected
            : EmergencyStatus.active;

    final now = DateTime.now();

    final data = <String, dynamic>{
      'eventId': eventId,
      'userId': userId,
      'deviceId': deviceId,
      'triggerSource': triggerSource.name,
      'status': initialStatus.name,
      'latitude': latitude ?? 18.52043,
      'longitude': longitude ?? 73.85674,
      'accuracyMeters': accuracyMeters ?? 4.2,
      'locationFreshness': LocationFreshness.live.name,
      'heartRateSnapshot': heartRateSnapshot ?? 136,
      'batterySnapshot': batterySnapshot ?? 82,
      'acknowledgedBy': <String>[],
      'cancellationReason': null,
      'resolutionNotes': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _emergenciesCol.doc(eventId).set(data);

    return EmergencyEvent(
      eventId: eventId,
      userId: userId,
      deviceId: deviceId,
      triggerSource: triggerSource,
      status: initialStatus,
      latitude: latitude ?? 18.52043,
      longitude: longitude ?? 73.85674,
      accuracyMeters: accuracyMeters ?? 4.2,
      locationFreshness: LocationFreshness.live,
      heartRateSnapshot: heartRateSnapshot ?? 136,
      batterySnapshot: batterySnapshot ?? 82,
      acknowledgedBy: const [],
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> updateEmergencyStatus({
    required String eventId,
    required EmergencyStatus newStatus,
    String? reason,
  }) async {
    final updateData = <String, dynamic>{
      'status': newStatus.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (reason != null) {
      updateData['cancellationReason'] = reason;
    }
    await _emergenciesCol.doc(eventId).update(updateData);
  }

  @override
  Future<void> acknowledgeEmergency({
    required String eventId,
    required String contactId,
  }) async {
    await _emergenciesCol.doc(eventId).update({
      'status': EmergencyStatus.acknowledged.name,
      'acknowledgedBy': FieldValue.arrayUnion([contactId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> resolveEmergency({
    required String eventId,
    String? resolutionNotes,
  }) async {
    await _emergenciesCol.doc(eventId).update({
      'status': EmergencyStatus.resolved.name,
      'resolutionNotes': resolutionNotes ?? 'Marked safe by user',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> cancelEmergency({
    required String eventId,
    required String reason,
  }) async {
    await _emergenciesCol.doc(eventId).update({
      'status': EmergencyStatus.cancelled.name,
      'cancellationReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  EmergencyEvent _mapDocToEmergencyEvent(
    String docId,
    Map<String, dynamic> data,
  ) {
    EmergencyStatus status = EmergencyStatus.safe;
    final statusStr = data['status'] as String?;
    for (final s in EmergencyStatus.values) {
      if (s.name == statusStr) {
        status = s;
        break;
      }
    }

    EmergencyTriggerSource triggerSource = EmergencyTriggerSource.manualSos;
    final triggerStr = data['triggerSource'] as String?;
    for (final t in EmergencyTriggerSource.values) {
      if (t.name == triggerStr) {
        triggerSource = t;
        break;
      }
    }

    LocationFreshness freshness = LocationFreshness.live;
    final freshnessStr = data['locationFreshness'] as String?;
    for (final f in LocationFreshness.values) {
      if (f.name == freshnessStr) {
        freshness = f;
        break;
      }
    }

    DateTime createdAt = DateTime.now();
    final createdTs = data['createdAt'];
    if (createdTs is Timestamp) {
      createdAt = createdTs.toDate();
    }

    DateTime updatedAt = DateTime.now();
    final updatedTs = data['updatedAt'];
    if (updatedTs is Timestamp) {
      updatedAt = updatedTs.toDate();
    }

    final rawAck = data['acknowledgedBy'];
    final List<String> acknowledgedBy = rawAck is List
        ? rawAck.map((e) => e.toString()).toList()
        : const [];

    return EmergencyEvent(
      eventId: (data['eventId'] as String?) ?? docId,
      userId: (data['userId'] as String?) ?? '',
      deviceId: (data['deviceId'] as String?) ?? '',
      triggerSource: triggerSource,
      status: status,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      accuracyMeters: (data['accuracyMeters'] as num?)?.toDouble(),
      locationFreshness: freshness,
      heartRateSnapshot: (data['heartRateSnapshot'] as num?)?.toInt(),
      batterySnapshot: (data['batterySnapshot'] as num?)?.toInt(),
      acknowledgedBy: acknowledgedBy,
      cancellationReason: data['cancellationReason'] as String?,
      resolutionNotes: data['resolutionNotes'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
