enum ModelStatus { installed, available, downloading }

class ModelInfo {
  ModelInfo({
    required this.name,
    required this.size,
    required this.description,
    this.status = ModelStatus.available,
    this.progress = 0,
  });

  final String name;
  final String size;
  final String description;
  ModelStatus status;
  double progress;
}
