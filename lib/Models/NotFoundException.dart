class NotFoundException {
  String entity;

  NotFoundException({
   required this.entity,
  });
  String toString() {
    return "the searched $entity not found";
  }
}