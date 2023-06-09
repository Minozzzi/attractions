import 'package:intl/intl.dart';

class Attraction {
  static const TABLE_NAME = 'attractions';
  static const FIELD_ID = 'id';
  static const FIELD_NAME = 'name';
  static const FIELD_DESCRIPTION = 'description';
  static const FIELD_DIFFERENTIALS = 'differentials';
  static const FIELD_LATITUDE = 'latitude';
  static const FIELD_LONGITUDE = 'longitude';
  static const FIELD_CREATED_AT = 'createdAt';

  int id;
  final String name;
  final String description;
  final String? differentials;
  final String? longitude;
  final String? latitude;
  final DateTime createdAt;

  Attraction(
      {required this.id,
      required this.name,
      required this.description,
      this.differentials,
      this.longitude,
      this.latitude,
      required this.createdAt});

  factory Attraction.fromJson(Map<String, dynamic> json) {
    return Attraction(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        differentials: json['differentials'],
        longitude: json['longitude'],
        latitude: json['latitude'],
        createdAt: DateFormat("yyyy-MM-dd").parse(json['createdAt']));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'differentials': differentials,
      'longitude': longitude,
      'latitude': latitude,
      'createdAt': DateFormat("yyyy-MM-dd").format(createdAt)
    };
  }
}
