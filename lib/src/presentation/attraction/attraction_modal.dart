import 'dart:async';

import 'package:attractions/src/application/attraction_create_service.dart';
import 'package:attractions/src/application/attraction_update_service.dart';
import 'package:attractions/src/data/attraction_repository.dart';
import 'package:attractions/src/domain/attraction.dart';
import 'package:attractions/src/presentation/maps/maps_home.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:maps_launcher/maps_launcher.dart';

class AttractionModal extends StatefulWidget {
  final AttractionCreateService attractionCreateService;
  final AttractionUpdateService attractionUpdateService;
  final bool isViewOnly;
  final bool isEditing;
  final Attraction? attraction;

  const AttractionModal(
      {Key? key,
      required this.attractionCreateService,
      required this.attractionUpdateService,
      required this.isViewOnly,
      required this.isEditing,
      this.attraction})
      : super(key: key);

  @override
  AttractionModalState createState() => AttractionModalState();
}

class AttractionModalState extends State<AttractionModal> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final differentialsController = TextEditingController();

  late Position _currentPosition;
  late Position _lastKnownPosition;
  String _lastKnownAddress = '';

  bool hasLocation = false;

  late String pageTitle;

  @override
  void initState() {
    super.initState();

    if (widget.attraction != null) {
      nameController.text = widget.attraction?.name ?? '';
      descriptionController.text = widget.attraction?.description ?? '';
      differentialsController.text = widget.attraction?.differentials ?? '';

      _lastKnownPosition = Position(
        longitude: double.tryParse(widget.attraction?.longitude ?? '0') ?? 0,
        latitude: double.tryParse(widget.attraction?.latitude ?? '0') ?? 0,
        timestamp: null,
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      hasLocation = true;
    }

    _getCurrentPosition();

    if (widget.isViewOnly) {
      pageTitle = 'Visualizar atração';
      return;
    }

    pageTitle = widget.isEditing
        ? 'Atualizar atração ${widget.attraction?.name}'
        : 'Criar nova atração';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(pageTitle),
        ),
        body: _createBody());
  }

  Widget _createBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o nome da atração';
                }
                return null;
              },
              enabled: !widget.isViewOnly,
            ),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira a descrição da atração';
                }
                return null;
              },
              enabled: !widget.isViewOnly,
            ),
            TextFormField(
              controller: differentialsController,
              decoration: const InputDecoration(
                labelText: 'Diferenciais',
              ),
              enabled: !widget.isViewOnly,
            ),
            const SizedBox(height: 16),
            Text(
                "Sua distância até o ponto turístico é: ${_calculateDistance()} km",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            _renderViewOnMapButton(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.isViewOnly
                    ? null
                    : () async {
                        final bool hasServices = await _hasService();
                        final bool hasPermissions = await _hasPermissions();

                        if (!hasServices || !hasPermissions) {
                          return;
                        }

                        await _getAddress();

                        await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('Atenção'),
                            content: Text(
                                'Você está nessa localização? $_lastKnownAddress'),
                            actions: [
                              TextButton(
                                  onPressed: () async {
                                    await _openAppMap();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Não, selecionar no mapa')),
                              TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('Sim'))
                            ],
                          ),
                        );

                        return getOnPressed();
                      },
                child: Text(widget.isEditing || widget.isViewOnly
                    ? 'Atualizar'
                    : 'Adicionar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _renderViewOnMapButton() {
    if (widget.isViewOnly)
      return SizedBox(
          width: double.infinity,
          child:
              ElevatedButton(child: Text('Ver no mapa'), onPressed: _openMaps));

    return SizedBox.shrink();
  }

  getOnPressed() {
    if (widget.isEditing) return updateAttraction();
    return createAttraction();
  }

  void updateAttraction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final Attraction attractionToUpdate = Attraction(
          id: widget.attraction!.id,
          name: nameController.text,
          description: descriptionController.text,
          differentials: differentialsController.text,
          latitude: _lastKnownPosition.latitude.toString(),
          longitude: _lastKnownPosition.longitude.toString(),
          createdAt: widget.attraction!.createdAt);
      await widget.attractionUpdateService.updateAttraction(attractionToUpdate);
      Navigator.pop(context, attractionToUpdate);
    }
  }

  void createAttraction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final Attraction newAttraction = Attraction(
          id: Random().nextInt(1001),
          name: nameController.text,
          description: descriptionController.text,
          differentials: differentialsController.text,
          latitude: _lastKnownPosition.latitude.toString(),
          longitude: _lastKnownPosition.longitude.toString(),
          createdAt: DateTime.now());
      await widget.attractionCreateService.createAttraction(newAttraction);
      Navigator.pop(context, newAttraction);
    }
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

  void _getCurrentPosition() async {
    if (hasLocation) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
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
      // if (_lastKnownPosition.latitude)
      _lastKnownPosition = position;
    });
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

  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _lastKnownPosition.latitude, _lastKnownPosition.longitude);

      print(p);

      Placemark place = p[0];
      print(place);

      setState(() {
        _lastKnownAddress =
            "${place.street}, ${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  _openMaps() async {
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Deseja abrir qual mapa?'),
              actions: [
                TextButton(
                    onPressed: _openAppMap, child: Text('Mapa do aplicativo')),
                TextButton(
                    onPressed: _openGoogleMap, child: Text('Google Maps')),
              ],
            ));
  }

  _openGoogleMap() {
    if (_lastKnownPosition == null) {
      return;
    }
    MapsLauncher.launchCoordinates(
        _lastKnownPosition.latitude, _lastKnownPosition.longitude);
  }

  _openAppMap() async {
    if (_lastKnownPosition == null) {
      return;
    }

    Position? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => MapasPage(
          latitude: _lastKnownPosition.latitude,
          longitude: _lastKnownPosition.longitude,
          isViewOnly: widget.isViewOnly,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _lastKnownPosition = result;
      });
    }
  }

  String _calculateDistance() {
    try {
      double startLatitude = _currentPosition.latitude;
      double startLongitude = _currentPosition.longitude;

      double destinationLatitude = _lastKnownPosition.latitude;
      double destinationLongitude = _lastKnownPosition.longitude;

      double distanceInMeters = Geolocator.distanceBetween(
        startLatitude,
        startLongitude,
        destinationLatitude,
        destinationLongitude,
      );

      return (distanceInMeters / 1000).toStringAsFixed(2);
    } catch (e) {
      print(e);
    }
    return '0';
  }
}
