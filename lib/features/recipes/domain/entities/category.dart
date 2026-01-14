import 'package:papeeta/features/recipes/domain/entities/category_group.dart';

class Category {
  final int id;
  final String name;
  final CategoryGroup? group;
  final String? imageUrl;

  const Category({
    required this.id,
    required this.name,
    this.group,
    this.imageUrl,
  });
}
