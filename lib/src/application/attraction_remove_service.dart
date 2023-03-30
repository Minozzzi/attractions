import 'package:attractions/src/data/attraction_repository.dart';
import 'package:attractions/src/domain/attraction.dart';

class AttractionRemoveService {
  final AttractionRepository attractionRepository;
  final Function onRemoved;

  AttractionRemoveService(
      {required this.attractionRepository, required this.onRemoved});

  Future<void> removeAttraction(Attraction attraction) async {
    await attractionRepository.removeAttraction(attraction);
    onRemoved();
  }
}
