import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plant_app/constant.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();
  Marker? _pickedMarker;
  String? _pickedAddress;
  CameraPosition? _initialCamera;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _setupLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _setupLocation() async {
    try {
      final pos = await _getPermissions();
      _currentPosition = pos;
      _initialCamera = CameraPosition(
        target: LatLng(pos.latitude, pos.longitude),
        zoom: 16,
      );
      setState(() {});
    } catch (e) {
      _initialCamera = const CameraPosition(target: LatLng(0, 0), zoom: 2);
      setState(() {});
      _showErrorSnackBar('Gagal memuat lokasi: $e');
    }
  }

  Future<Position> _getPermissions() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Layanan lokasi tidak aktif. Silakan aktifkan GPS.');
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak.');
      }
    }
    if (perm == LocationPermission.deniedForever) {
      throw Exception(
        'Izin lokasi ditolak permanen. Silakan aktifkan di pengaturan.',
      );
    }

    return Geolocator.getCurrentPosition();
  }

  Future<void> _onMapTap(LatLng latlng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latlng.latitude,
        latlng.longitude,
      );
      final p = placemarks.first;
      final address = _formatAddress(p);

      setState(() {
        _pickedMarker = Marker(
          markerId: const MarkerId("picked"),
          position: latlng,
          infoWindow: InfoWindow(
            title: p.name?.isNotEmpty == true ? p.name : "Lokasi Dipilih",
            snippet: '${p.street}, ${p.locality}',
          ),
        );
        _pickedAddress = address;
      });

      final controller = await _controller.future;
      await controller.animateCamera(CameraUpdate.newLatLngZoom(latlng, 16));
    } catch (e) {
      _showErrorSnackBar('Gagal memuat alamat: $e');
    }
  }

  Future<void> _searchAddress(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final latlng = LatLng(location.latitude, location.longitude);
        final placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );
        final p = placemarks.first;
        final address = _formatAddress(p);

        setState(() {
          _pickedMarker = Marker(
            markerId: const MarkerId("picked"),
            position: latlng,
            infoWindow: InfoWindow(
              title: p.name?.isNotEmpty == true ? p.name : "Lokasi Dipilih",
              snippet: '${p.street}, ${p.locality}',
            ),
          );
          _pickedAddress = address;
        });

        final controller = await _controller.future;
        await controller.animateCamera(CameraUpdate.newLatLngZoom(latlng, 16));
      } else {
        _showErrorSnackBar('Alamat tidak ditemukan.');
      }
    } catch (e) {
      _showErrorSnackBar('Gagal mencari alamat: $e');
    }
  }

  String _formatAddress(Placemark p) {
    return [
      p.name,
      p.street,
      p.locality,
      p.subAdministrativeArea,
      p.administrativeArea,
      p.country,
      p.postalCode,
    ].where((e) => e != null && e.isNotEmpty).join(', ');
  }

  void _confirmSelection() {
    if (_pickedAddress == null) {
      _showErrorSnackBar('Silakan pilih alamat terlebih dahulu.');
      return;
    }
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              'Konfirmasi Alamat',
              style: TextStyle(
                color: kTextColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(_pickedAddress!, style: TextStyle(color: kTextColor)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, _pickedAddress);
                },
                child: Text('Pilih'),
              ),
            ],
          ),
    );
  }

  void _clearSelection() {
    setState(() {
      _pickedAddress = null;
      _pickedMarker = null;
      _searchController.clear();
    });
    _showSuccessSnackBar('Pilihan alamat telah dihapus.');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: kPrimaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initialCamera == null) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: kTextColor),
        ),
        title: Text(
          'Pilih Alamat',
          style: TextStyle(
            color: kTextColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari alamat...',
                  prefixIcon: Icon(Icons.search, color: kPrimaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onSubmitted: _searchAddress,
              ),
            ),
          ),

          Expanded(
            child: GoogleMap(
              initialCameraPosition: _initialCamera!,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
              zoomControlsEnabled: true,
              onMapCreated: (GoogleMapController ctrl) {
                _controller.complete(ctrl);
              },
              markers: _pickedMarker != null ? {_pickedMarker!} : {},
              onTap: _onMapTap,
              padding: EdgeInsets.only(
                bottom: _pickedAddress != null ? 180 : 0,
              ),
            ),
          ),

          if (_pickedAddress != null)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_pin,
                          color: kPrimaryColor,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Alamat Dipilih',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: kTextColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      _pickedAddress!,
                      style: TextStyle(fontSize: 13, color: kTextColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _clearSelection,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: BorderSide(color: Colors.red),
                              padding: EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Hapus'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _confirmSelection,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Pilih'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
