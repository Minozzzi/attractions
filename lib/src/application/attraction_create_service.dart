import 'package:attractions/src/data/attraction_repository.dart';
import 'package:attractions/src/domain/attraction.dart';

class AttractionCreateService {
  final AttractionRepository _attractionRepository;

  AttractionCreateService(this._attractionRepository);

  Future<void> createAttraction(Attraction attraction) async {
    await _attractionRepository.addAttraction(attraction);
  }
}
