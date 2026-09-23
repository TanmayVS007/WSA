import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/location_provider.dart';
import '../../domain/models/safe_haven_model.dart';
import '../../../emergency/presentation/providers/emergency_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/aegis_bottom_nav.dart';
import '../../../../core/widgets/aegis_top_bar.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  bool _showBreadcrumbs = true;
  bool _showHelperGeofence = true;
  MapType _currentMapType = MapType.normal;
  bool _hasInitialCameraAnimated = false;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(liveLocationProvider);
    final emergencyState = ref.watch(emergencyNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final centerLatLng = locationState.currentLocation;
    final isEmergency = emergencyState.hasActiveEmergency;

    // Listen to location provider to center on first GPS fix
    ref.listen<LiveLocationState>(liveLocationProvider, (prev, next) {
      if (!_hasInitialCameraAnimated && next.hasPermission) {
        _hasInitialCameraAnimated = true;
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: next.currentLocation, zoom: 16.0),
          ),
        );
      }
    });

    // 1. Wearer Live Location Marker
    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('live_user_marker'),
        position: centerLatLng,
        zIndexInt: 2,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isEmergency ? BitmapDescriptor.hueRed : BitmapDescriptor.hueViolet,
        ),
        infoWindow: InfoWindow(
          title: 'YOU (WSB-001)',
          snippet: isEmergency
              ? 'EMERGENCY ACTIVE • SOS BROADCASTING'
              : 'Live GPS (${locationState.accuracyMeters.round()}m accuracy)',
        ),
      ),
      // 2. Real Safe Haven POI Markers from Places API (5km radius)
      ...locationState.safeHavens.map(
        (haven) => Marker(
          markerId: MarkerId(haven.id),
          position: haven.latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(haven.markerHue),
          infoWindow: InfoWindow(
            title: haven.name,
            snippet: '${haven.formattedDistance} • ${haven.address}',
          ),
          onTap: () {
            _showSafeHavenDetailSheet(context, haven, isDark);
          },
        ),
      ),
    };

    // Circles: Accuracy Halo + 5km Helper Geofence
    final Set<Circle> circles = {
      // 1. GPS Accuracy Halo
      Circle(
        circleId: const CircleId('live_accuracy_halo'),
        center: centerLatLng,
        radius: locationState.accuracyMeters.clamp(20.0, 150.0),
        fillColor: (isEmergency ? AppColors.emergencyRed : AppColors.primary)
            .withAlpha(35),
        strokeColor: (isEmergency ? AppColors.emergencyRed : AppColors.primary)
            .withAlpha(120),
        strokeWidth: 2,
      ),

      // 2. 5km Community Helper & Safe Haven Geofence
      if (_showHelperGeofence)
        Circle(
          circleId: const CircleId('helper_geofence_5km'),
          center: centerLatLng,
          radius: 3000.0, // Strict 5km radius geofence
          fillColor: (isEmergency
              ? AppColors.emergencyRed.withAlpha(20)
              : AppColors.primary.withAlpha(16)),
          strokeColor: (isEmergency
              ? AppColors.emergencyRed.withAlpha(160)
              : AppColors.primary.withAlpha(150)),
          strokeWidth: 2,
        ),
    };

    // Breadcrumbs Path
    final Set<Polyline> polylines = {
      if (_showBreadcrumbs && locationState.breadcrumbs.length > 1)
        Polyline(
          polylineId: const PolylineId('live_breadcrumb_trail'),
          points: locationState.breadcrumbs,
          color: AppColors.primary.withAlpha(210),
          width: 5,
          patterns: [PatternItem.dot, PatternItem.gap(10)],
        ),
    };

    return Scaffold(
      appBar: const AegisTopBar(title: 'Live Locator', showBackButton: true),
      bottomNavigationBar: const AegisBottomNav(currentIndex: 1),
      body: Stack(
        children: [
          // 1. Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: centerLatLng,
              zoom: 15.8,
            ),
            mapType: _currentMapType,
            markers: markers,
            circles: circles,
            polylines: polylines,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              if (locationState.hasPermission) {
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: centerLatLng, zoom: 16.0),
                  ),
                );
              }
            },
          ),

          // 2. Telemetry Status Bar at Top
          Positioned(
            top: 12,
            left: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark.withAlpha(240)
                    : Colors.white.withAlpha(245),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? AppColors.cardBorderDark
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0B1C30).withAlpha(14),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: locationState.hasPermission
                                  ? AppColors.tertiaryContainer.withAlpha(25)
                                  : AppColors.errorContainer.withAlpha(35),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 7,
                                  color: locationState.hasPermission
                                      ? AppColors.tertiary
                                      : AppColors.emergencyRed,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  locationState.isLoading
                                      ? 'ACQUIRING GPS...'
                                      : (locationState.hasPermission
                                            ? 'GPS • LIVE'
                                            : 'GPS PENDING'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: locationState.hasPermission
                                        ? AppColors.onTertiaryFixedVariant
                                        : AppColors.onErrorContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            locationState.isFetchingSafeHavens
                                ? 'Scanning 5km zone...'
                                : '${locationState.safeHavens.length} in 5km Zone',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          ref.read(liveLocationProvider.notifier).refresh();
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.sync_rounded,
                              size: 14,
                              color: locationState.isFetchingSafeHavens
                                  ? AppColors.primary
                                  : AppColors.tertiary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              locationState.isFetchingSafeHavens
                                  ? 'Updating'
                                  : 'Refresh',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.gps_fixed_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Accuracy: ±${locationState.accuracyMeters.round()}m',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.radar_rounded,
                            size: 12,
                            color: isEmergency
                                ? AppColors.emergencyRed
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _showHelperGeofence
                                ? '5km Geofence: ON'
                                : '5km Geofence: OFF',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isEmergency
                                  ? AppColors.emergencyRed
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. Floating Map Controls (Right side)
          Positioned(
            right: 14,
            bottom: 180,
            child: Column(
              children: [
                _buildMapFab(
                  icon: Icons.my_location_rounded,
                  tooltip: 'Recenter on My Live Location',
                  onTap: () {
                    _mapController?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(target: centerLatLng, zoom: 16.0),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildMapFab(
                  icon: Icons.radar_rounded,
                  tooltip: _showHelperGeofence
                      ? '5km Helper Geofence (Active)'
                      : '5km Helper Geofence (Hidden)',
                  color: _showHelperGeofence
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  onTap: () {
                    setState(() {
                      _showHelperGeofence = !_showHelperGeofence;
                    });
                  },
                ),
                const SizedBox(height: 8),
                _buildMapFab(
                  icon: Icons.fit_screen_rounded,
                  tooltip: 'Fit 5km Helper Geofence Perimeter',
                  color: AppColors.tertiary,
                  onTap: () {
                    _mapController?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(target: centerLatLng, zoom: 12.2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildMapFab(
                  icon: Icons.shield_outlined,
                  tooltip: 'View 5km Safe Havens List',
                  color: AppColors.tertiary,
                  onTap: () {
                    _showAllSafeHavensSheet(
                      context,
                      locationState.safeHavens,
                      isDark,
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildMapFab(
                  icon: _showBreadcrumbs
                      ? Icons.route_rounded
                      : Icons.alt_route_rounded,
                  tooltip: 'Toggle Breadcrumb Trail',
                  color: _showBreadcrumbs
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  onTap: () {
                    setState(() {
                      _showBreadcrumbs = !_showBreadcrumbs;
                    });
                  },
                ),
                const SizedBox(height: 8),
                _buildMapFab(
                  icon: _currentMapType == MapType.normal
                      ? Icons.layers_rounded
                      : Icons.map_rounded,
                  tooltip: 'Toggle Satellite View',
                  color: _currentMapType == MapType.satellite
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  onTap: () {
                    setState(() {
                      _currentMapType = _currentMapType == MapType.normal
                          ? MapType.satellite
                          : MapType.normal;
                    });
                  },
                ),
                const SizedBox(height: 8),
                _buildMapFab(
                  icon: Icons.add_rounded,
                  tooltip: 'Zoom In',
                  onTap: () {
                    _mapController?.animateCamera(CameraUpdate.zoomIn());
                  },
                ),
                const SizedBox(height: 8),
                _buildMapFab(
                  icon: Icons.remove_rounded,
                  tooltip: 'Zoom Out',
                  onTap: () {
                    _mapController?.animateCamera(CameraUpdate.zoomOut());
                  },
                ),
              ],
            ),
          ),

          // 4. Bottom Slide-up Information Card (Coordinate Anchor)
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: GestureDetector(
              onTap: () {
                _showAllSafeHavensSheet(
                  context,
                  locationState.safeHavens,
                  isDark,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? AppColors.cardBorderDark
                        : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0B1C30).withAlpha(16),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.pin_drop_rounded,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'LIVE LOCATION ANCHOR',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.6,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                locationState.address,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${centerLatLng.latitude.toStringAsFixed(5)}° N, ${centerLatLng.longitude.toStringAsFixed(5)}° E',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.tertiaryFixed,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.shield_rounded,
                                    size: 11,
                                    color: AppColors.onTertiaryFixed,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${locationState.safeHavens.length} in 5km',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.onTertiaryFixed,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '5km Safe Haven List',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSafeHavenDetailSheet(
    BuildContext context,
    SafeHaven haven,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: haven.badgeColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(haven.icon, color: haven.badgeColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          haven.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          haven.formattedDistance,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: haven.badgeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                haven.address,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _mapController?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(target: haven.latLng, zoom: 17.0),
                      ),
                    );
                  },
                  icon: const Icon(Icons.navigation_rounded, size: 18),
                  label: const Text('Focus on Map'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAllSafeHavensSheet(
    BuildContext context,
    List<SafeHaven> havens,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.85,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Safe Havens (5km Radius)',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Within 5km Safety & Helper Perimeter',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryFixed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${havens.length} in 5km',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onTertiaryFixed,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: havens.isEmpty
                        ? const Center(
                            child: Text(
                              'Scanning for police, hospitals & safe havens within 5km radius...',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: havens.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (_, index) {
                              final haven = havens[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: haven.badgeColor.withAlpha(25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    haven.icon,
                                    color: haven.badgeColor,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  haven.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  haven.address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      haven.formattedDistance,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: haven.badgeColor,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      size: 16,
                                      color: AppColors.outline,
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  _mapController?.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                      CameraPosition(
                                        target: haven.latLng,
                                        zoom: 17.0,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMapFab({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color color = AppColors.primary,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 3,
        shadowColor: Colors.black26,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}
