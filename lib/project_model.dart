
class ProjectDetails{
  late final String projectID;
  late final String description;
  ProjectDetails({required this.projectID, required this.description});

  factory ProjectDetails.fromJson(Map<String, dynamic> json) {
    return ProjectDetails(
      projectID: json['Key1'],
      description: json['Character01'],
    );
  }

  @override
   String toString() {
      return 'projectID: $projectID, description: $description';
    }
}