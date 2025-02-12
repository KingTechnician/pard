# Conversion to Quest Class Definitions


Your purpose will be to transform the current implication of using just list<dynamic> for the quests and instead taking a more class-based format with Flutter.

The fullQuests.json file that is read in main.dart, is a dictionary, keyed by ID number of the quest, and the value is a dictionary containing all of the attributes of the quest.

This is one example of those entries:

```json
"101": {
    "category": "assigned",
    "name": "Jagras of the Ancient Forest",
    "rank": "Low Rank",
    "stars": 1,
    "quest_type": "hunt",
    "location": "Ancient Forest",
    "zenny": 720,
    "monsters": [
      {
        "monster_name": "Jagras",
        "quantity": 7,
        "is_objective": true,
        "monster_id": 2
      }
    ],
    "rewards": [
      {
        "group": "A",
        "item_name": "Armor Sphere",
        "stack": 1,
        "percentage": 100
      },
      {
        "group": "A",
        "item_name": "Blue Mushroom",
        "stack": 2,
        "percentage": 18
      },
      {
        "group": "A",
        "item_name": "Bitterbug",
        "stack": 3,
        "percentage": 16
      },
      {
        "group": "A",
        "item_name": "Toadstool",
        "stack": 2,
        "percentage": 15
      },
      {
        "group": "A",
        "item_name": "Mandragora",
        "stack": 1,
        "percentage": 12
      },
      {
        "group": "A",
        "item_name": "Machalite Ore",
        "stack": 1,
        "percentage": 12
      },
      {
        "group": "A",
        "item_name": "Ancient Bone",
        "stack": 1,
        "percentage": 12
      },
      {
        "group": "A",
        "item_name": "Iron Ore",
        "stack": 2,
        "percentage": 7
      },
      {
        "group": "A",
        "item_name": "Monster Bone S",
        "stack": 2,
        "percentage": 7
      },
      {
        "group": "A",
        "item_name": "Armor Sphere",
        "stack": 1,
        "percentage": 1
      }
    ]
  }
```

Right now, it just uses the raw list<dynamic>, guessing all of the attributes.

Instead, what you will do is create serialization wqhen the quests are loaded.

(These are python classes as an example, but you will be using Dart to make these):

```py
class Reward:
	group: str
	item_name: str
	stack: int
	percentage: int

class Monster:
	name: str
	quantity: int
	is_objective: bool
	id: int

Class Quest:
	category:str
	name:str
	rank:str
	stars:int
	quest_type:str
	location:str
	zenny:int
	monsters: list[Monster]
	rewards:list[Rewards]
```

Note that you'll still need the key for each dictionary, in order to get the ID number for the quest.

After making these changes, you will then make sure all usages are also updated.