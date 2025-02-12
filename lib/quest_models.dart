import 'package:json_annotation/json_annotation.dart';

part 'quest_models.g.dart';

@JsonSerializable()
class Monster {
  final String monsterName;
  final int quantity;
  final bool isObjective;
  final int monsterId;

  Monster({
    required this.monsterName,
    required this.quantity,
    required this.isObjective,
    required this.monsterId,
  });

  factory Monster.fromJson(Map<String, dynamic> json) {
    return Monster(
      monsterName: json['monster_name']?.toString() ?? 'Unknown Monster',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      isObjective: json['is_objective'] as bool? ?? false,
      monsterId: (json['monster_id'] as num?)?.toInt() ?? 0,
    );
  }
  Map<String, dynamic> toJson() => _$MonsterToJson(this);
}

@JsonSerializable()
class Reward {
  final String group;
  final String itemName;
  final int stack;
  final int percentage;

  Reward({
    required this.group,
    required this.itemName,
    required this.stack,
    required this.percentage,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      group: json['group']?.toString() ?? 'A',
      itemName: json['item_name']?.toString() ?? 'Unknown Item',
      stack: (json['stack'] as num?)?.toInt() ?? 1,
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
    );
  }
  Map<String, dynamic> toJson() => _$RewardToJson(this);
}

@JsonSerializable()
class Quest {
  final String category;
  final String name;
  final String rank;
  final int stars;
  final String questType;
  final String location;
  final int zenny;
  final List<Monster> monsters;
  final List<Reward> rewards;
  final String id;

  Quest({
    required this.category,
    required this.name,
    required this.rank,
    required this.stars,
    required this.questType,
    required this.location,
    required this.zenny,
    required this.monsters,
    required this.rewards,
    required this.id,
  });

  factory Quest.fromJson(Map<String, dynamic> json, String questId) {
    return Quest(
      category: json['category']?.toString() ?? 'Unknown Category',
      name: json['name']?.toString() ?? 'Unknown Quest',
      rank: json['rank']?.toString() ?? 'Low Rank',
      stars: (json['stars'] as num?)?.toInt() ?? 1,
      questType: json['quest_type']?.toString() ?? 'hunt',
      location: json['location']?.toString() ?? 'Unknown Location',
      zenny: (json['zenny'] as num?)?.toInt() ?? 0,
      monsters: (json['monsters'] as List<dynamic>?)
          ?.map((e) => Monster.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      rewards: (json['rewards'] as List<dynamic>?)
          ?.map((e) => Reward.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      id: questId,
    );
  }

  Map<String, dynamic> toJson() => _$QuestToJson(this);
}
