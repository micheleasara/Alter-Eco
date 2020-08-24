import Foundation

/// Responsible for retrieving and publishing the data shown in the food pie chart.
public class FoodPieChartViewModel: PieChartViewModel {
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
        
        carbonVals[0] = carbonMeatsAndSeafood(date: date)
        carbonVals[1] = carbonDairiesAndEggs(date: date)
        carbonVals[2] = carbonVeganProduce(date: date)
        carbonVals[3] = carbonCarbsBeveragesAndOthers(date: date)
        update(values: carbonVals,
        imageNames: ["meat", "dairies", "vegetable", "fast-food"],
        colours: [.red, .yellow, .green, .blue],
        legendNames: ["Meat and seafood",
                      "Dairies and eggs",
                      "Veggies, fruits and legumes",
                      "Carbs and beverages"])
    }
    
    private func carbonVeganProduce(date: Date) -> Double {
        let veggies = Food.Category.vegetablesAndDerived.rawValue
        let fruits = Food.Category.fruits.rawValue
        let legumes = Food.Category.legumes.rawValue
        
        return (try? DBMS.carbonFromFoods(predicate: "date <= %@ AND (category == %@ OR category == %@ OR category == %@)",
        args: [date, veggies, fruits, legumes]).value) ?? 0
    }
    
    private func carbonDairiesAndEggs(date: Date) -> Double {
        return (try? DBMS.carbonFromFoods(predicate: "date <= %@ AND category == %@",
            args: [date, Food.Category.dairiesAndEggs.rawValue]).value) ?? 0
    }
    
    private func carbonMeatsAndSeafood(date: Date) -> Double {
        let meats = Food.Category.meats.rawValue
        let seafood = Food.Category.seafood.rawValue
        
        return (try? DBMS.carbonFromFoods(predicate: "date <= %@ AND (category == %@ OR category == %@)",
        args: [date, meats, seafood]).value) ?? 0
    }
    
    private func carbonCarbsBeveragesAndOthers(date: Date) -> Double {
        let others = Food.Category.others.rawValue
        let carbs = Food.Category.carbohydrates.rawValue
        let beverages = Food.Category.beverages.rawValue
        return (try? DBMS.carbonFromFoods(predicate: "category == %@ OR category == %@ OR category == %@",
            args: [carbs, beverages, others]).value) ?? 0
    }
}
