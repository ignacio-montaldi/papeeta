class PreparationStepModel {
  final int? tempId; // ID UI estable
  final int stepNumber;
  final String description;

  PreparationStepModel({
    this.tempId,
    required this.stepNumber,
    required this.description,
  });

  PreparationStepModel copyWith({int? stepNumber, String? description}) {
    return PreparationStepModel(
      tempId: tempId, // 🔒 se mantiene
      stepNumber: stepNumber ?? this.stepNumber,
      description: description ?? this.description,
    );
  }
}
