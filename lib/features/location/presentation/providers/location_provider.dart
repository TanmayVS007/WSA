import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/services/safe_haven_service.dart';
import '../../domain/models/safe_haven_model.dart';

final safeHavenServiceProvider = Provider<SafeHavenService>((ref) {
  return SafeHavenService();
});

class LiveLocationState {
  final LatLng currentLocation;
  final double accuracyMeters;
  final String address;
  final List<LatLng> breadcrumbs;
  final List<SafeHaven> safeHavens;
  final bool isLoading;
  final bool isFetchingSafeHavens;
  final String? errorMessage;
  final bool hasPermission;

  const LiveLocationState({
    required this.currentLocation,
    this.accuracyMeters = 5.0,
    this.address = 'Fetching current address...',
    this.breadcrumbs = const [],
    this.safeHavens = const [],
    this.isLoading = true,
    this.isFetchingSafeHavens = false,
    this.errorMessage,
    this.hasPermission = false,
  });

  LiveLocationState copyWith({
    LatLng? currentLocation,
    double? accuracyMeters,
    String? address,
    List<LatLng>? breadcrumbs,
    List<SafeHaven>? safeHavens,
    bool? isLoading,
    bool? isFetchingSafeHavens,
    String? errorMessage,
    bool? hasPermission,
  }) {
    return LiveLocationState(
      currentLocation: currentLocation ?? this.currentLocation,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      address: address ?? this.address,
      breadcrumbs: breadcrumbs ?? this.breadcrumbs,
      safeHavens: safeHavens ?? this.safeHavens,
      isLoading: isLoading ?? this.isLoading,
      isFetchingSafeHavens: isFetchingSafeHavens ?? this.isFetchingSafeHavens,
      errorMessage: errorMessage,
      hasPermission: hasPermission ?? this.hasPermission,
    );
  }
}

class LiveLocationNotifier extends Notifier<LiveLocationState> {
  StreamSubscription<Position>? _positionSubscription;
  SafeHavenService get _safeHavenService => ref.read(safeHavenServiceProvider);

  // Default fallback center if GPS is disabled or waiting for initial fix
  static const LatLng _defaultLocation = LatLng(18.5196, 73.8753);

  @override
  LiveLocationState build() {
    ref.onDispose(() {
      _positionSubscription?.cancel();
    });

    Future.microtask(() => initLiveLocation());

    return const LiveLocationState(
      currentLocation: _defaultLocation,
      breadcrumbs: [_defaultLocation],
      isLoading: true,
    );
  }

  Future<void> initLiveLocation() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Location services are disabled on this device.',
        );
        _loadSafeHavensForLocation(state.currentLocation);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Location permissions were denied by user.',
          );
          _loadSafeHavensForLocation(state.currentLocation);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Location permissions are permanently denied.',
        );
        _loadSafeHavensForLocation(state.currentLocation);
        return;
      }

      // Permissions granted
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final liveLatLng = LatLng(position.latitude, position.longitude);

      state = state.copyWith(
        currentLocation: liveLatLng,
        accuracyMeters: position.accuracy,
        hasPermission: true,
        isLoading: false,
        breadcrumbs: [liveLatLng],
      );

      // Fetch address and real safe havens around this live location
      _fetchAddress(liveLatLng);
      _loadSafeHavensForLocation(liveLatLng);

      // Start continuous position stream
      _subscribeToLocationUpdates();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'GPS error: $e',
      );
      _loadSafeHavensForLocation(state.currentLocation);
    }
  }

  void _subscribeToLocationUpdates() {
    _positionSubscription?.cancel();

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // update every 5 meters moved
      ),
    ).listen(
      (Position position) {
        final newLatLng = LatLng(position.latitude, position.longitude);

        // Append to breadcrumbs if moved significantly
        final updatedBreadcrumbs = List<LatLng>.from(state.breadcrumbs);
        if (updatedBreadcrumbs.isEmpty ||
            Geolocator.distanceBetween(
                  updatedBreadcrumbs.last.latitude,
                  updatedBreadcrumbs.last.longitude,
                  newLatLng.latitude,
                  newLatLng.longitude,
                ) >
                5) {
          updatedBreadcrumbs.add(newLatLng);
          // Keep last 40 breadcrumbs
          if (updatedBreadcrumbs.length > 40) {
            updatedBreadcrumbs.removeAt(0);
          }
        }

        // If moved more than 500m from where we last fetched safe havens, refresh them
        final lastHavenCenter = state.currentLocation;
        final distanceSinceLastHavenFetch = Geolocator.distanceBetween(
          lastHavenCenter.latitude,
          lastHavenCenter.longitude,
          newLatLng.latitude,
          newLatLng.longitude,
        );

        state = state.copyWith(
          currentLocation: newLatLng,
          accuracyMeters: position.accuracy,
          breadcrumbs: updatedBreadcrumbs,
        );

        if (distanceSinceLastHavenFetch > 500) {
          _fetchAddress(newLatLng);
          _loadSafeHavensForLocation(newLatLng);
        }
      },
      onError: (err) {
        state = state.copyWith(errorMessage: err.toString());
      },
    );
  }

  Future<void> refresh() async {
    await initLiveLocation();
  }

  Future<void> _fetchAddress(LatLng latLng) async {
    try {
      final addr = await _safeHavenService.fetchAddressForCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      state = state.copyWith(address: addr);
    } catch (_) {}
  }

  Future<void> _loadSafeHavensForLocation(LatLng latLng) async {
    state = state.copyWith(isFetchingSafeHavens: true);

    try {
      final havens = await _safeHavenService.fetchNearbySafeHavens(
        latLng.latitude,
        latLng.longitude,
      );

      state = state.copyWith(
        safeHavens: havens,
        isFetchingSafeHavens: false,
      );
    } catch (e) {
      state = state.copyWith(
        isFetchingSafeHavens: false,
        errorMessage: 'Could not fetch safe havens: $e',
      );
    }
  }
}

final liveLocationProvider =
    NotifierProvider<LiveLocationNotifier, LiveLocationState>(
  LiveLocationNotifier.new,
);
