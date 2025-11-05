/// Category model
library;

import '../../core/constants.dart';

/// Represents a category for time blocks
class Category {
  final CategoryType type;
  final String displayName;
  final int colour;

  const Category({
    required this.type,
    required this.displayName,
    required this.colour,
  });

  /// Create a category from a type
  factory Category.fromType(CategoryType type) {
    return Category(
      type: type,
      displayName: type.displayName,
      colour: type.colour,
    );
  }

  /// Create a category from a string
  factory Category.fromString(String value) {
    final type = CategoryType.fromString(value);
    return Category.fromType(type);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'Category($displayName)';
}

/// Default categories
final Map<CategoryType, Category> defaultCategories = {
  for (final type in CategoryType.values) type: Category.fromType(type),
};
