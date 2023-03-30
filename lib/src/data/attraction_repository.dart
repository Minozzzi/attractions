import 'package:attractions/src/domain/attraction.dart';

class AttractionRepository {
  final List<Attraction> _attractions = [];

  Future<List<Attraction>> getAttractions() async {
    return _attractions;
  }

  Future<void> addAttraction(Attraction attraction) async {
    _attractions.add(attraction);
  }

  Future<void> removeAttraction(Attraction attraction) async {
    _attractions.remove(attraction);
  }
}
