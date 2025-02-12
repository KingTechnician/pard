// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Monster _$MonsterFromJson(Map<String, dynamic> json) => Monster(
      monsterName: json['monsterName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      isObjective: json['isObjective'] as bool,
      monsterId: (json['monsterId'] as num).toInt(),
    );

Map<String, dynamic> _$MonsterToJson(Monster instance) => <String, dynamic>{
      'monsterName': instance.monsterName,
      'quantity': instance.quantity,
      'isObjective': instance.isObjective,
      'monsterId': instance.monsterId,
    };

Reward _$RewardFromJson(Map<String, dynamic> json) => Reward(
      group: json['group'] as String,
      itemName: json['itemName'] as String,
      stack: (json['stack'] as num).toInt(),
      percentage: (json['percentage'] as num).toInt(),
    );

Map<String, dynamic> _$RewardToJson(Reward instance) => <String, dynamic>{
      'group': instance.group,
      'itemName': instance.itemName,
      'stack': instance.stack,
      'percentage': instance.percentage,
    };

Quest _$QuestFromJson(Map<String, dynamic> json) => Quest(
      category: json['category'] as String,
      name: json['name'] as String,
      rank: json['rank'] as String,
      stars: (json['stars'] as num).toInt(),
      questType: json['questType'] as String,
      location: json['location'] as String,
      zenny: (json['zenny'] as num).toInt(),
      monsters: (json['monsters'] as List<dynamic>)
          .map((e) => Monster.fromJson(e as Map<String, dynamic>))
          .toList(),
      rewards: (json['rewards'] as List<dynamic>)
          .map((e) => Reward.fromJson(e as Map<String, dynamic>))
          .toList(),
      id: json['id'] as String,
    );

Map<String, dynamic> _$QuestToJson(Quest instance) => <String, dynamic>{
      'category': instance.category,
      'name': instance.name,
      'rank': instance.rank,
      'stars': instance.stars,
      'questType': instance.questType,
      'location': instance.location,
      'zenny': instance.zenny,
      'monsters': instance.monsters,
      'rewards': instance.rewards,
      'id': instance.id,
    };
