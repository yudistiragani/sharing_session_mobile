class CategoryOptionModel {
  final String id;
  final String name;
  CategoryOptionModel({required this.id, required this.name});

  factory CategoryOptionModel.fromJson(Map<String, dynamic> j) => CategoryOptionModel(
        id: (j['_id'] ?? j['id']).toString(),
        name: (j['name'] ?? '').toString(),
      );
}
