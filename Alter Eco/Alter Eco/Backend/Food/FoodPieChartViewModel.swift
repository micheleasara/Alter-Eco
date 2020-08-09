import Foundation

/// Responsible for retrieving and publishing the data shown in the food pie chart.
public class FoodPieChartViewModel: PieChartModel {
    private let DBMS: DBManager
    
    /// Initializes a new instance of the view model with the database manager provided.
    public init(DBMS: DBManager) {
        self.DBMS = DBMS
        super.init()
        updateUpTo(Date())
    }
    
    /// Updates the chart up to the date given.
    public func updateUpTo(_ date: Date) {
        var carbonVals = [0.0, 0.0, 0.0, 0.0]
        
        let converter = FoodToCarbonConverter()
        carbonVals[0] = converter.getCarbon(fromFoods: getMeatsAndSeafood(date: date)).value
        carbonVals[1] = converter.getCarbon(fromFoods: getDairiesAndEggs(date: date)).value
        carbonVals[2] = converter.getCarbon(fromFoods: getVeganProduce(date: date)).value
        carbonVals[3] = converter.getCarbon(fromFoods: getCarbsBeveragesAndOthers(date: date)).value
        update(values: carbonVals,
        imageNames: ["meat", "dairies", "vegetable", "fast-food"],
        colours: [.red, .yellow, .green, .blue],
        legendNames: ["Meat and seafood",
                      "Dairies and eggs",
                      "Veggies, fruits and legumes",
                      "Carbs and beverages"])
    }
    
    private func getVeganProduce(date: Date) -> [Food] {
        let veggies = Food.Category.vegetablesAndDerived.rawValue
        let fruits = Food.Category.fruits.rawValue
        let legumes = Food.Category.legumes.rawValue
        let foods = try? DBMS.queryFoods(predicate: "date <= %@ AND (category == %@ OR category == %@ OR category == %@)",
                                         args: [date, veggies, fruits, legumes])
        return (foods ?? [])
    }
    
    private func getDairiesAndEggs(date: Date) -> [Food] {
        let foods = try? DBMS.queryFoods(predicate: "date <= %@ AND category == %@",
                                         args: [date, Food.Category.dairiesAndEggs.rawValue])
        return (foods ?? [])
    }
    
    private func getMeatsAndSeafood(date: Date) -> [Food] {
        let meats = Food.Category.meats.rawValue
        let seafood = Food.Category.seafood.rawValue
        let foods = try? DBMS.queryFoods(predicate: "date <= %@ AND (category == %@ OR category == %@)",
                                         args: [date, meats, seafood])
        return (foods ?? [])
    }
    
    private func getCarbsBeveragesAndOthers(date: Date) -> [Food] {
        let others = Food.Category.others.rawValue
        let carbs = Food.Category.carbohydrates.rawValue
        let beverages = Food.Category.beverages.rawValue
        let foods = try? DBMS.queryFoods(predicate: "category == %@ OR category == %@ OR category == %@",
                                         args: [carbs, beverages, others])

        return (foods ?? [])
    }
}
