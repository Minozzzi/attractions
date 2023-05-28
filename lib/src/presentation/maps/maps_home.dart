import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:attractions/src/widget/custom_text_field.dart';

class MapasPage extends StatefulWidget {
  double latitude;
  double longitude;
  bool isViewOnly;

  MapasPage(
      {Key? ke,
      required this.latitude,
      required this.longitude,
      required this.isViewOnly})
      : super(key: ke);

  @override
  _MapasPageState createState() => _MapasPageState();
}

class _MapasPageState extends State<MapasPage> {
  final _controller = Completer<GoogleMapController>();
  late GoogleMapController _googleMapController;
  StreamSubscription<Position>? _subscription;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late Position _currentPosition;

  final localizationController = TextEditingController();
  final localizationFocusNode = FocusNode();
  String localization = '';

  String _currentAddress = '';

  bool isUpdated = false;

  @override
  void initState() {
    super.initState();

    _currentPosition = Position(
      longitude: widget.longitude,
      latitude: widget.latitude,
      timestamp: null,
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );

    _getCurrentPosition();
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
    _subscription = null;
  }

  Future<bool> _hasService() async {
    bool hasServices = await Geolocator.isLocationServiceEnabled();
    if (!hasServices) {
      await _showDialog(
          'Para utilizar esse recurso, você deverá habilitar o serviço'
          ' de localização');
      Geolocator.openLocationSettings();
      return false;
    }
    return true;
  }

  Future<void> _showDialog(String mensagem) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Atenção'),
        content: Text(mensagem),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(), child: Text('OK'))
        ],
      ),
    );
  }

  void _getCurrentPosition() async {
    if (_currentPosition != null) {
      return;
    }

    bool hasServivce = await _hasService();
    if (!hasServivce) {
      return;
    }
    bool hasPermissions = await _hasPermissions();
    if (!hasPermissions) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });

    await _getAddress();
  }

  Future<bool> _hasPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showMessage('Não será possível utilizar o recurso '
            'por falta de permissão');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showMessage('Para utilizar esse recurso, você deverá acessar '
          'as configurações do app para permitir a utilização do serviço de localização');
      Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];
      print(place);

      setState(() {
        _currentAddress =
            "${place.street}, ${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        localizationController.text = _currentAddress;
        localization = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  _getLocationFromAddress(String location) async {
    try {
      List<Location> l = await locationFromAddress(location);
      if (l.length > 0) {
        Location location = l[0];

        setState(() {
          _currentPosition = Position(
            latitude: location.latitude,
            longitude: location.longitude,
            timestamp: location.timestamp,
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
          );
        });
      }
    } catch (e) {}
  }

  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Attractions Map'),
      ),
      body: Container(
          height: height,
          width: width,
          child: Scaffold(
            key: _scaffoldKey,
            body: Stack(children: <Widget>[
              GoogleMap(
                mapType: MapType.normal,
                markers: {
                  Marker(
                    markerId: MarkerId('1'),
                    position: isUpdated
                        ? LatLng(_currentPosition.latitude,
                            _currentPosition.longitude)
                        : LatLng(widget.latitude, widget.longitude),
                  ),
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(widget.latitude, widget.longitude),
                  zoom: 15,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  _googleMapController = controller;
                },
                myLocationEnabled: true,
              ),
              SafeArea(
                  child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        )),
                    width: width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomTextField(
                              label: 'Pesquise o endereço correto',
                              hint: 'Pesquise o endereço correto',
                              isEnable: !widget.isViewOnly,
                              prefixIcon: Icon(Icons.search),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.check),
                                onPressed: () async {
                                  await _getLocationFromAddress(
                                      localizationController.text);
                                  setState(() {
                                    isUpdated = true;
                                    _googleMapController.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                                target: LatLng(
                                                    _currentPosition.latitude,
                                                    _currentPosition.longitude),
                                                zoom: 20)));
                                  });
                                  print(_currentPosition.latitude);
                                },
                              ),
                              controller: localizationController,
                              focusNode: localizationFocusNode,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  localization = value;
                                });
                              }),
                          Container(
                            width:
                                width * 0.8, // Defina a largura desejada aqui
                            child: !widget.isViewOnly
                                ? ElevatedButton(
                                    onPressed: () => Navigator.pop(
                                        context, _currentPosition),
                                    child: Text('Salvar'),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ))
            ]),
          )),
    );
  }
}
