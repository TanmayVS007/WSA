import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../domain/entities/emergency_event.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../../data/repositories/mock_emergency_repository.dart';
import '../../data/repositories/firestore_emergency_repository.dart';
import '../../data/services/emergency_dispatch_service.dart';
import '../../../device/presentation/providers/device_provider.dart';
import '../../../../core/constants/app_constants.dart';

/// Flag to toggle between Firestore and Mock repository.
/// Defaults to Mock mode if Firebase is not initialized on this platform.
final isMockEmergencyModeProvider = Provider<bool>((ref) {
  try {
    return Firebase.apps.isEmpty;
  } catch (_) {
    return true;
  }
});

final emergencyRepositoryProvider = Provider<EmergencyRepository>((ref) {
  final forceMock = ref.watch(isMockEmergencyModeProvider);
  if (forceMock) {
    return MockEmergencyRepository();
  }
  try {
    if (Firebase.apps.isEmpty) {
      return MockEmergencyRepository();
    }
    return FirestoreEmergencyRepository();
  } catch (_) {
    return MockEmergencyRepository();
  }
});

class EmergencyState {
  final EmergencyEvent? activeEvent;
  final int confirmationCountdownSeconds;
  final bool isTriggering;
  final String? errorMessage;
  final List<EmergencyEvent> history;

  const EmergencyState({
    this.activeEvent,
    this.confirmationCountdownSeconds =
        AppConstants.anomalyConfirmationTimeoutSeconds,
    this.isTriggering = false,
    this.errorMessage,
    this.history = const [],
  });

  bool get hasActiveEmergency =>
      activeEvent != null &&
      (activeEvent!.status == EmergencyStatus.active ||
          activeEvent!.status == EmergencyStatus.acknowledged);

  bool get isConfirmationPending =>
      activeEvent != null &&
      (activeEvent!.status == EmergencyStatus.detected ||
          activeEvent!.status == EmergencyStatus.confirmationCountdown);

  EmergencyState copyWith({
    EmergencyEvent? activeEvent,
    bool clearActiveEvent = false,
    int? confirmationCountdownSeconds,
    bool? isTriggering,
    String? errorMessage,
    List<EmergencyEvent>? history,
  }) {
    return EmergencyState(
      activeEvent:
          clearActiveEvent ? null : (activeEvent ?? this.activeEvent),
      confirmationCountdownSeconds:
          confirmationCountdownSeconds ?? this.confirmationCountdownSeconds,
      isTriggering: isTriggering ?? this.isTriggering,
      errorMessage: errorMessage,
      history: history ?? this.history,
    );
  }
}

class EmergencyNotifier extends Notifier<EmergencyState> {
  Timer? _countdownTimer;
  StreamSubscription<EmergencyEvent?>? _activeEventSub;
  StreamSubscription<EmergencyEvent>? _deviceEmergencySub;

  EmergencyRepository get _repository => ref.read(emergencyRepositoryProvider);

  @override
  EmergencyState build() {
    ref.onDispose(() {
      _countdownTimer?.cancel();
      _activeEventSub?.cancel();
      _deviceEmergencySub?.cancel();
    });

    _initStreams();
    Future.microtask(() => loadHistory());

    return const EmergencyState();
  }

  void _initStreams() {
    _activeEventSub = _repository.activeEmergencyStream.listen((event) {
      if (event == null) {
        state = state.copyWith(clearActiveEvent: true);
        _countdownTimer?.cancel();
      } else {
        state = state.copyWith(activeEvent: event);
        if (event.status == EmergencyStatus.detected) {
          _startAnomalyCountdown(event);
        }
      }
    });

    // Listen to hardware-originated emergency triggers
    final deviceRepo = ref.read(deviceRepositoryProvider);
    _deviceEmergencySub = deviceRepo.emergencyStream.listen((event) {
      if (event.triggerSource == EmergencyTriggerSource.automaticAnomaly) {
        state = state.copyWith(activeEvent: event);
        _startAnomalyCountdown(event);
      } else if (event.triggerSource == EmergencyTriggerSource.manualSos) {
        triggerManualSos();
      }
    });
  }

  void _startAnomalyCountdown(EmergencyEvent event) {
    _countdownTimer?.cancel();
    state = state.copyWith(
      activeEvent:
          event.copyWith(status: EmergencyStatus.confirmationCountdown),
      confirmationCountdownSeconds:
          AppConstants.anomalyConfirmationTimeoutSeconds,
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.confirmationCountdownSeconds - 1;
      if (remaining <= 0) {
        timer.cancel();
        // Time expired without user response: Escalate to ACTIVE emergency
        confirmEmergency();
      } else {
        state = state.copyWith(confirmationCountdownSeconds: remaining);
      }
    });
  }

  Future<void> loadHistory() async {
    try {
      final history = await _repository.getEmergencyHistory('usr_owner_demo');
      state = state.copyWith(history: history);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Triggers an immediate confirmed Manual SOS
  Future<void> triggerManualSos() async {
    _countdownTimer?.cancel();
    state = state.copyWith(isTriggering: true, errorMessage: null);

    // Provide emergency vibration feedback
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}

    final deviceState = ref.read(deviceNotifierProvider);

    // Acquire accurate live GPS fix, falling back to device telemetry
    final locationFix = await EmergencyDispatchService.getAccurateLocation(
      fallbackLat: deviceState.currentData.latitude ?? 18.52043,
      fallbackLng: deviceState.currentData.longitude ?? 73.85674,
    );

    try {
      final event = await _repository.triggerEmergency(
        userId: 'usr_owner_demo',
        deviceId: deviceState.deviceId,
        triggerSource: EmergencyTriggerSource.manualSos,
        latitude: locationFix.latitude,
        longitude: locationFix.longitude,
        accuracyMeters: locationFix.accuracyMeters,
        heartRateSnapshot: deviceState.currentData.heartRate,
        batterySnapshot: deviceState.currentData.batteryPercentage,
      );

      state = state.copyWith(
        activeEvent: event,
        isTriggering: false,
      );
    } catch (e) {
      state = state.copyWith(isTriggering: false, errorMessage: e.toString());
    }
  }

  /// Direct Emergency Dispatch Action: Calls 112
  Future<bool> dial112() async {
    return await EmergencyDispatchService.launchEmergencyCall('112');
  }

  /// Direct Emergency Dispatch Action: Calls designated contact
  Future<bool> callPrimaryContact(String phoneNumber) async {
    return await EmergencyDispatchService.launchEmergencyCall(phoneNumber);
  }

  /// Direct Emergency Dispatch Action: Sends emergency SMS with live GPS link to trusted contacts
  Future<bool> sendEmergencySms({
    required List<String> phoneNumbers,
    String userName = 'Aegis Wearer',
  }) async {
    final lat = state.activeEvent?.latitude ?? 18.52043;
    final lng = state.activeEvent?.longitude ?? 73.85674;
    return await EmergencyDispatchService.launchEmergencySms(
      phoneNumbers: phoneNumbers,
      latitude: lat,
      longitude: lng,
      userName: userName,
    );
  }

  /// User explicitly confirms emergency during anomaly countdown OR countdown times out
  Future<void> confirmEmergency() async {
    _countdownTimer?.cancel();
    if (state.activeEvent != null) {
      await _repository.updateEmergencyStatus(
        eventId: state.activeEvent!.eventId,
        newStatus: EmergencyStatus.active,
      );
      state = state.copyWith(
        activeEvent:
            state.activeEvent!.copyWith(status: EmergencyStatus.active),
      );
    }
  }

  /// User presses "I'M SAFE" during anomaly countdown
  Future<void> cancelAnomaly({String reason = 'User confirmed safe'}) async {
    _countdownTimer?.cancel();
    if (state.activeEvent != null) {
      await _repository.cancelEmergency(
        eventId: state.activeEvent!.eventId,
        reason: reason,
      );
      await loadHistory();
      state = state.copyWith(clearActiveEvent: true);
    }
  }

  /// Resolves an active emergency
  Future<void> resolveEmergency({String? notes}) async {
    _countdownTimer?.cancel();
    if (state.activeEvent != null) {
      await _repository.resolveEmergency(
        eventId: state.activeEvent!.eventId,
        resolutionNotes: notes ?? 'Emergency marked resolved by wearer',
      );
      await loadHistory();
      state = state.copyWith(clearActiveEvent: true);
    }
  }
}

final emergencyNotifierProvider =
    NotifierProvider<EmergencyNotifier, EmergencyState>(EmergencyNotifier.new);
