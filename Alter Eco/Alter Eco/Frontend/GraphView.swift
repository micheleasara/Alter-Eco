import SwiftUI

struct GraphView: View {
    @State private var timespanSelection = GraphDataModel.Timespan.day
    @State private var transportSelection = MeasuredActivity.MotionType.unknown
    @EnvironmentObject var dataGraph : GraphDataModel

    var body: some View {
        VStack () {
            self.timePicker.padding(.horizontal)

            Text("Total carbon " + self.savedOrEmittedLabel + ": " +
                self.kgToReadableLabel(valueInKg: self.totalCarbonInKg()))
                .font(.headline)
                .fontWeight(.semibold)
            
            BarChart(values: self.getValues(), xLabels: self.getLabels(), infoOnBarTap: self.getInfoOnBarTap(), colour: self.barColour, yAxisTicksCount: 4).padding(.horizontal)

            self.transportPicker.padding()
        }
    }
    
    /// Represents the picker for the timespan the user's wishes to see.
    public var timePicker : some View {
        Picker(selection: $timespanSelection.animation(), label: Text("")) {
            Text("Daily").tag(GraphDataModel.Timespan.day)
            Text("Weekly").tag(GraphDataModel.Timespan.week)
            Text("Monthly").tag(GraphDataModel.Timespan.month)
            Text("Yearly").tag(GraphDataModel.Timespan.year)
        }
          .pickerStyle(SegmentedPickerStyle())
    }
    
    /// Represents the picker for transport selection.
    public var transportPicker : some View {
        Picker(selection: $transportSelection.animation(), label: Image("")) {
            Text("All").tag(MeasuredActivity.MotionType.unknown)
            Image(systemName: "car").tag(MeasuredActivity.MotionType.car)
            Image(systemName: "person").tag(MeasuredActivity.MotionType.walking)
            Image(systemName: "tram.fill").tag(MeasuredActivity.MotionType.train)
            Image(systemName: "airplane").tag(MeasuredActivity.MotionType.plane)
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    /// Returns the colour of the bars in the graph, which change according to daily carbon footprint.
    public var barColour : Color {
        var colour: String = "graphBars"
        let carbonByTransport = dataGraph.carbonBreakdown[.week]!
        
        // graph changes colour depending on users's daily carbon footprint
        var todayTotal = 0.0
        for motion in MeasuredActivity.MotionType.allCases {
            if let labelledValue = carbonByTransport[motion]?.last {
                if motion != .walking {
                    todayTotal += labelledValue.data
                }
            }
        }

        if todayTotal > AVERAGE_UK_DAILY_CARBON {
            colour = "redGraphBar"
        }
        return Color(colour)
    }
    
    /// Returns whether the carbon shown was saved or emitted.
    public var savedOrEmittedLabel : String {
        return transportSelection == .walking ? "saved" : "emitted"
    }
    
    private func totalCarbonInKg() -> Double {
        var total = 0.0
        if let labelledPoints = dataGraph.carbonBreakdown[timespanSelection]![transportSelection] {
            for labelledPoint in  labelledPoints {
                total += labelledPoint.data
            }
        }
        return total
    }
    
    private func getLabels() -> [String] {
        var labels = [String]()
        let labelledPoints = dataGraph.carbonBreakdown[timespanSelection]![transportSelection]!
        for labelledPoint in labelledPoints {
            labels.append(labelledPoint.label)
        }
        return labels
    }
    
    private func getValues() -> [Double] {
        var values = [Double]()
        let labelledPoints = dataGraph.carbonBreakdown[timespanSelection]![transportSelection]!
        
        for labelledPoint in labelledPoints {
            values.append(labelledPoint.data)
        }
        
        let max = values.max()!
        if max < 1 {
            // convert to grams if less than 1kg
            values = values.map{$0 * 1000}
        }
        
        return values
    }
    
    private func getInfoOnBarTap() -> [String] {
        var infoOnBarTap = [String]()
        let labelledPoints = dataGraph.carbonBreakdown[timespanSelection]![transportSelection]!
         for labelledPoint in labelledPoints {
            let info = "Carbon: " + kgToReadableLabel(valueInKg: labelledPoint.data)
            infoOnBarTap.append(info)
        }
        return infoOnBarTap
    }
    
    private func kgToReadableLabel(valueInKg: Double) -> String {
        let format = "%.1f"
        switch valueInKg {
        case 0.0001..<1:
            return String(format: format + " g", 1000*valueInKg)
        case 1000..<Double.infinity:
            return String(format: format + " tonne", 0.001*valueInKg)
        default:
            return String(format: format + " kg", valueInKg)
        }
    }
}

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let DBMS = CoreDataManager(persistentContainer: container)
        return GraphView()
            .environmentObject(GraphDataModel(limit: Date(), DBMS: DBMS))
    }
}
