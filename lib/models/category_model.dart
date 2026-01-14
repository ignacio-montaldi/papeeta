import 'package:papeeta/models/group_model.dart';

class CategoryModel {
  final int? id;
  final String name;
  final String? imageUrl;
  final int? groupId;
  final GroupModel? group;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.groupId,
    required this.group,
  });
}
