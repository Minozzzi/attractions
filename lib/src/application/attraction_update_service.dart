import 'package:attractions/src/data/attraction_repository.dart';
import 'package:attractions/src/domain/attraction.dart';

class AttractionUpdateService {
  final AttractionRepository _attractionRepository;

  AttractionUpdateService(this._attractionRepository);

  Future<void> updateAttraction(Attraction attraction) async {
    await _attractionRepository.updateAttraction(attraction);
  }
}
