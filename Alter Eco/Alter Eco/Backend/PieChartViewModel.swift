import Foundation
import SwiftUI

/// Represents an updatable model for a chart.
public protocol ChartModel {
    /// Updates the model internal data up to the date provided.
    func updateUpTo(_ date: Date)
}

/// View model for a pie chart. All properties should be set to an appropriate value or a default appeareance will be generated.
public class PieChartViewModel: ObservableObject {
    @Published public var values: [Double] = []
    @Published public var imageNames: [String] = [""]
    @Published public var colours: [Color] = [.primary]
    @Published public var legendNames: [String] = [""]
    
    public func update(values: [Double], imageNames: [String],
                  colours: [Color], legendNames: [String]) {
        self.values = values
        self.imageNames = imageNames
        self.colours = colours
        self.legendNames = legendNames
    }
}

/// Represents the model for a pie chart. All the properties of the view model should be initialised and updated with a call to updateUpTo.
public typealias PieChartModel = PieChartViewModel & ChartModel

/// Model for the pie chart representing transportation data.
public class TransportPieChartModel: PieChartModel {
    private static let MOTION_TO_IMAGE:
        [MeasuredActivity.MotionType:String] = [.car:"car", .plane:"plane", .train:"train"]
    private static let MOTION_TO_LEGEND:
    [MeasuredActivity.MotionType:String] = [.car:"Car and bus", .plane:"Plane", .train:"Train and subway"]
    private static let MOTION_TO_COLOUR:
        [MeasuredActivity.MotionType:Color] = [.car:.yellow, .plane:.red, .train:.orange]
    private var DBMS: DBManager!
    
    public init(DBMS: DBManager) {
        self.DBMS = DBMS
        super.init()
        updateUpTo(Date())
    }
    
    public func updateUpTo(_ date: Date) {
        let now = date
        var values: [Double] = []
        var imageNames: [String] = []
        var colours: [Color] = []
        var legendNames: [String] = []
        
        if let origin = try? DBMS.getFirstDate() {
            let interval = now.timeIntervalSince(origin)
            for type in MeasuredActivity.MotionType.allCases {
                if type.isPolluting() {
                    let carbon = (try? DBMS.carbonWithinInterval(motionType: type, from: origin, interval: interval)) ?? 0
                    values.append(carbon)
                    imageNames.append(TransportPieChartModel.MOTION_TO_IMAGE[type] ?? "Image not found")
                    legendNames.append(TransportPieChartModel.MOTION_TO_LEGEND[type] ?? "Legend not found")
                    colours.append(TransportPieChartModel.MOTION_TO_COLOUR[type] ?? .red)
                }
            }
        }
        update(values: values, imageNames: imageNames, colours: colours, legendNames: legendNames)
    }
}

public class FoodPieChartModel: PieChartModel {
    private var DBMS: DBManager!
    
    public init(DBMS: DBManager) {
        self.DBMS = DBMS
        super.init()
        updateUpTo(Date())
    }
    
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
