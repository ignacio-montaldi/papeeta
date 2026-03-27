import 'package:papeeta/core/domain/entities/category_group.dart';

class Category {
  final int id;
  final String name;
  final int? groupId;
  final CategoryGroup? group;
  final String? imageUrl;

  const Category({
    required this.id,
    required this.name,
    this.groupId,
    this.group,
    this.imageUrl,
  });
}
