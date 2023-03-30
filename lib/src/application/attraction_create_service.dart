import 'package:attractions/src/data/attraction_repository.dart';
import 'package:attractions/src/domain/attraction.dart';

class AttractionCreateService {
  final AttractionRepository _attractionListRepository;

  AttractionCreateService(this._attractionListRepository);

  Future<void> createAttraction(Attraction attraction) async {
    await _attractionListRepository.addAttraction(attraction);
  }
}
