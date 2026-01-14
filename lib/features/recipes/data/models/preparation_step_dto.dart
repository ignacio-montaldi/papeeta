class PreparationStepDto {
  final int stepNumber;
  final String description;

  PreparationStepDto({required this.stepNumber, required this.description});

  factory PreparationStepDto.fromJson(Map<String, dynamic> json) {
    return PreparationStepDto(
      stepNumber: json['step_number'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
    'step_number': stepNumber,
    'description': description,
  };
}
