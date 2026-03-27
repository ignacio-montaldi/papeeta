import 'package:papeeta/features/recipes/data/models/preparation_step_dto.dart';
import 'package:papeeta/features/recipes/domain/entities/preparation_step.dart';

class PreparationStepMapper {
  static PreparationStep toEntity(PreparationStepDto dto) {
    return PreparationStep(order: dto.stepNumber, description: dto.description);
  }

  static PreparationStepDto toDto(PreparationStep entity) {
    return PreparationStepDto(
      stepNumber: entity.order,
      description: entity.description,
    );
  }
}
