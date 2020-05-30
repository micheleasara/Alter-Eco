import SwiftUI

struct ChartView: View {
    @State private var timespanSelection = ChartDataModel.Timespan.day
    @State private var transportSelection = MeasuredActivity.MotionType.unknown
    @EnvironmentObject var chartData : ChartDataModel

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
            Text("Daily").tag(ChartDataModel.Timespan.day)
            Text("Weekly").tag(ChartDataModel.Timespan.week)
            Text("Monthly").tag(ChartDataModel.Timespan.month)
            Text("Yearly").tag(ChartDataModel.Timespan.year)
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
    
    /// Returns the colour of the bars in the chart, which change according to daily carbon footprint.
    public var barColour : Color {
        var colour: String = "graphBars"
        let carbonByTransport = chartData.carbonBreakdown[.week]!
        
        // chart changes colour depending on users's daily carbon footprint
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
        if let labelledPoints = chartData.carbonBreakdown[timespanSelection]![transportSelection] {
            for labelledPoint in  labelledPoints {
                total += labelledPoint.data
            }
        }
        return total
    }
    
    private func getLabels() -> [String] {
        var labels = [String]()
        let labelledPoints = chartData.carbonBreakdown[timespanSelection]![transportSelection]!
        for labelledPoint in labelledPoints {
            labels.append(labelledPoint.label)
        }
        return labels
    }
    
    private func getValues() -> [Double] {
        var values = [Double]()
        let labelledPoints = chartData.carbonBreakdown[timespanSelection]![transportSelection]!
        
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
        let labelledPoints = chartData.carbonBreakdown[timespanSelection]![transportSelection]!
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

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let DBMS = CoreDataManager(persistentContainer: container)
        return ChartView()
            .environmentObject(ChartDataModel(limit: Date().toLocalTime(), DBMS: DBMS))
    }
}
