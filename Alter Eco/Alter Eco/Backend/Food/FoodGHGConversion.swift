import Foundation

extension FoodToCarbonManager {
    public static func getTypeInfo(_ type: String) -> FoodTypeInfo? {
        return foodTypesInfo[type]
    }
    
    public static func getAvailableTypes() -> [String] {
        return Array(foodTypesInfo.keys)
    }
    
    
    /// Database of food types (lowercase) containing information about their GHG emission values in  kgCOeq/kg and their categories.
    private static let foodTypesInfo: Dictionary<String, FoodTypeInfo> = [
        "onion": (0.18, .vegetablesAndDerived),
        "celery": (0.18, .vegetablesAndDerived),
        "potato": (0.20, .carbohydrates),
        "carrot": (0.22, .vegetablesAndDerived),
        "zucchini": (0.42, .vegetablesAndDerived),
        "cucumber": (0.33, .vegetablesAndDerived),
        "beetroot": (0.23, .vegetablesAndDerived),
        "pumpkin": (0.33, .fruits),
        "cantaloupe": (0.25, .fruits),
        "lemon": (0.30, .fruits),
        "lime": (0.30, .fruits),
        "mushroom": (0.27, .vegetablesAndDerived),
        "guava": (0.28, .fruits),
        "apple": (0.36, .fruits),
        "rutabaga": (0.29, .vegetablesAndDerived),
        "pear": (0.33, .fruits),
        "quince": (0.33, .fruits),
        "green bean": (0.51, .vegetablesAndDerived),
        "watermelon": (0.32, .fruits),
        "date": (0.32, .fruits),
        "orange": (0.35, .fruits),
        "kiwi": (0.47, .fruits),
        "cauliflower": (0.35, .vegetablesAndDerived),
        "grapes": (0.41, .fruits),
        "oat": (0.44, .carbohydrates),
        "rye": (0.41, .carbohydrates),
        "pea": (0.60, .legumes),
        "cherry": (0.48, .fruits),
        "almond milk": (0.42, .vegetablesAndDerived),
        "coconut milk": (0.42, .vegetablesAndDerived),
        "peach": (0.54, .fruits),
        "nectarine": (0.52, .fruits),
        "fig": (0.43, .fruits),
        "barley": (0.49, .carbohydrates),
        "apricot": (0.43, .fruits),
        "chestnut": (0.43, .fruits),
        "bean": (0.62, .legumes),
        "mandarin": (0.45, .fruits),
        "tomato": (0.46, .fruits),
        "corn": (0.63, .vegetablesAndDerived),
        "fennel": (0.48, .vegetablesAndDerived),
        "artichoke": (0.48, .vegetablesAndDerived),
        "soy bean": (0.58, .vegetablesAndDerived),
        "pineapple": (0.72, .fruits),
        "melon": (0.88, .fruits),
        "grapefruit": (0.51, .fruits),
        "pomelo": (0.51, .fruits),
        "tangerine": (0.51, .fruits),
        "wheat": (0.51, .carbohydrates),
        "spinach": (0.54, .vegetablesAndDerived),
        "garlic": (0.57, .vegetablesAndDerived),
        "strawberry": (0.65, .fruits),
        "broccoli": (0.70, .vegetablesAndDerived),
        "olive": (0.56, .fruits),
        "pepper": (0.60, .vegetablesAndDerived),
        "pinto bean": (0.63, .legumes),
        "soy milk": (0.88, .beverages),
        "runner bean": (0.85, .legumes),
        "chickpea": (0.67, .legumes),
        "asparagus": (0.92, .vegetablesAndDerived),
        "peanut": (0.87, .fruits),
        "raspberry": (0.84, .fruits),
        "gooseberry": (0.84, .fruits),
        "sesame seed": (0.88, .vegetablesAndDerived),
        "ginger": (0.88, .vegetablesAndDerived),
        "cranberry": (0.92, .fruits),
        "blueberry": (0.92, .fruits),
        "hazelnut": (0.97, .fruits),
        "lentil": (1.03, .legumes),
        "quinoa": (1.15, .carbohydrates),
        "herring fish": (1.17, .seafood),
        "milk": (1.39, .dairiesAndEggs),
        "avocado": (1.30, .fruits),
        "yogurt": (1.43, .dairiesAndEggs),
        "eggplant": (1.35, .vegetablesAndDerived),
        "sunflower seed": (1.41, .vegetablesAndDerived),
        "cashew nut": (1.55, .fruits),
        "walnut": (1.62, .fruits),
        "pistachio": (1.53, .fruits),
        "almond": (1.74, .fruits),
        "carp": (1.80, .seafood),
        "mackerel": (2.0, .seafood),
        "mustard seed": (2.09, .vegetablesAndDerived),
        "tuna": (2.6, .seafood),
        "rice": (2.66, .carbohydrates),
        "whiting fish": (2.66, .seafood),
        "duck": (3.09, .meats),
        "sea bass fish": (3.55, .seafood),
        "haddock fish": (3.37, .seafood),
        "egg": (3.39, .dairiesAndEggs),
        "chicken egg": (3.39, .dairiesAndEggs),
        "salmon": (3.76, .seafood),
        "fish": (4.41, .seafood),
        "cod fish": (3.49, .seafood),
        "buffalo milk": (3.75, .dairiesAndEggs),
        "chicken": (4.12, .meats),
        "lettuce": (3.15, .vegetablesAndDerived),
        "eel": (3.88, .seafood),
        "kangaroo": (4.10, .meats),
        "trout": (3.73, .seafood),
        "rabbit": (4.70, .meats),
        "cream": (5.32, .dairiesAndEggs),
        "pork": (5.85, .meats),
        "pomfret fish": (6.63, .seafood),
        "rock fish": (6.94, .seafood),
        "octopus": (8.07, .seafood),
        "squid": (8.07, .seafood),
        "prawn": (14.85, .seafood),
        "turkey": (6.04, .meats),
        "diamond fish": (8.33, .seafood),
        "rhombus fish": (8.41, .seafood),
        "cheese": (8.86, .dairiesAndEggs),
        "butter": (11.52, .dairiesAndEggs),
        "mussel": (7.54, .seafood),
        "hake": (8.98, .seafood),
        "mackerel shark": (11.44, .seafood),
        "shark mako": (11.50, .seafood),
        "anglerfish": (12.29, .seafood),
        "swordfish": (12.84, .seafood),
        "whiff fish": (14.15, .seafood),
        "turbot": (14.51, .seafood),
        "sole fish": (20.68, .seafood),
        "lamb": (27.91, .meats),
        "beef": (28.73, .meats),
        "lobster": (21.74, .seafood),
        "buffalo": (62.59, .meats),
        "cola": (0.34, .beverages),
        "beer": (0.45, .beverages),
        "cider": (0.45, .beverages),
        "water": (0.2, .beverages),
        "coffee": (17.72, .beverages),
        "juice": (0.79, .beverages),
        "wine": (0.38, .beverages),
        "liqueur": (0.5, .beverages),
        "tea": (6.42, .beverages),
        "peppercorn": (1.36, .fruits),
        "jam": (1.32, .carbohydrates),
        "salt": (1.36, .others),
        "spice": (1.13, .vegetablesAndDerived),
        "yeast": (0.99, .others),
        "vinegar": (1.36, .others),
        "honey": (1.32, .carbohydrates),
        "chutney": (1.36, .others),
        "dried herb": (1.13, .vegetablesAndDerived),
        "nut butter": (1.32, .carbohydrates),
        "cocoa powder": (0.52, .carbohydrates),
        "sugar": (1, .carbohydrates),
        "syrup": (0.87, .carbohydrates),
        "sweetener": (0.98, .carbohydrates),
        "sweet snack": (5.4, .carbohydrates),
        "butter pastry": (5.4, .carbohydrates),
        "vegan pastry": (2.32, .carbohydrates),
        "chocolate": (2.96, .carbohydrates),
        "noodle": (1.17, .carbohydrates),
        "flour": (0.96, .carbohydrates),
        "brown rice": (3.08, .carbohydrates),
        "bread": (0.91, .carbohydrates),
        "tapioca": (0.96, .vegetablesAndDerived),
        "couscous": (1.17, .carbohydrates),
        "pasta": (1.17, .carbohydrates),
        "buckwheat": (0.81, .carbohydrates),
        "vegetable oil": (3.67, .carbohydrates),
        "animal fat": (9.83, .others),
        "dairy": (1.13, .dairiesAndEggs),
        "cow milk": (1.13, .dairiesAndEggs),
        "sheep milk": (1.15, .dairiesAndEggs),
        "goat milk": (1.15, .dairiesAndEggs),
        "margarine": (1.18, .vegetablesAndDerived),
        "tofu": (1.07, .vegetablesAndDerived),
        "vegan burger": (2.29, .vegetablesAndDerived),
        "vegan sausage": (2.29, .vegetablesAndDerived),
        "fresh basil": (1.28, .vegetablesAndDerived),
        "bamboo shoot": (3.97, .vegetablesAndDerived),
        "chicory": (0.54, .vegetablesAndDerived),
        "okra": (3.97, .vegetablesAndDerived),
        "pickle": (1.35, .vegetablesAndDerived),
        "truffle": (3.97, .vegetablesAndDerived),
        "fresh coriander": (1.28, .vegetablesAndDerived),
        "fresh herb": (1.77, .vegetablesAndDerived),
        "legume": (1.35, .legumes),
        "curd": (1.32, .dairiesAndEggs),
        "chili pepper": (3.31, .vegetablesAndDerived),
        "salty snack": (2.5, .carbohydrates),
        "potato chip": (1.64, .carbohydrates),
        "waffle": (2.73, .carbohydrates),
        "hazelnut spread": (1.53, .carbohydrates),
        "candy": (2.5, .carbohydrates),
        "rice pudding": (0.85, .carbohydrates),
        "ice cream": (2, .dairiesAndEggs),
        "breakfast cereal": (2.64, .carbohydrates)
    ]
}
