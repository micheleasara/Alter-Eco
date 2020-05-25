import SwiftUI

struct GraphView: View {
    //The following picker represents the options of 'day' 'week' 'month' 'year'
    @State var timePickerSelection = 0
    //The following picker represents the travel options of 'all' 'car' 'walk' 'train' 'plane'
    @State var transportPickerSelection = MeasuredActivity.MotionType.unknown
    @EnvironmentObject var dataGraph : DataGraph
    @EnvironmentObject var screenMeasurements: ScreenMeasurements

    var body: some View {        
        return VStack {
            timePicker.padding(.top).padding(.horizontal)
            
            Text("Total carbon " + savedOrEmittedLabel + ": " +
                kgToReadableLabel(valueInKg: totalCarbonInKg()))
                .font(.headline)
                .fontWeight(.semibold)
            
            BarChart(values: getValues(), labels: getLabels(), infoOnBarTap: getInfoOnBarTap(), colour: barColour).frame(height: screenMeasurements.height/3.8).padding()

            transportPicker.padding(.bottom).padding(.horizontal)
        }
    }
    
    var savedOrEmittedLabel : String {
        return transportPickerSelection == .walking ? "saved" : "emitted"
    }
    
    func totalCarbonInKg() -> Double {
        var total = 0.0
        if let labelledPoints = dataGraph.data[timePickerSelection][transportPickerSelection] {
            for labelledPoint in  labelledPoints {
                total += labelledPoint.data
            }
        }
        return total
    }
    
    func getLabels() -> [String] {
        var labels = [String]()
        let labelledPoints = dataGraph.data[timePickerSelection][transportPickerSelection]!
        for labelledPoint in labelledPoints {
            labels.append(labelledPoint.label)
        }
        return labels
    }
    
    func getValues() -> [Double] {
        var values = [Double]()
        let labelledPoints = dataGraph.data[timePickerSelection][transportPickerSelection]!
        for labelledPoint in labelledPoints {
            values.append(labelledPoint.data)
        }
        return values
    }
    
    func getInfoOnBarTap() -> [String] {
        var infoOnBarTap = [String]()
        let labelledPoints = dataGraph.data[timePickerSelection][transportPickerSelection]!
         for labelledPoint in labelledPoints {
            let info = "Carbon: " + kgToReadableLabel(valueInKg: labelledPoint.data)
            infoOnBarTap.append(info)
        }
        return infoOnBarTap
    }
    
    var timePicker : some View {
        Picker(selection: $timePickerSelection.animation(), label: Text("")) {
            Text("Daily").tag(0)
            Text("Weekly").tag(1)
            Text("Monthly").tag(2)
            Text("Yearly").tag(3)
        }
          .pickerStyle(SegmentedPickerStyle())
    }
    
    var transportPicker : some View {
        Picker(selection: $transportPickerSelection.animation(), label: Image("")) {
            Text("All").tag(MeasuredActivity.MotionType.unknown)
            Image(systemName: "car").tag(MeasuredActivity.MotionType.car)
            Image(systemName: "person").tag(MeasuredActivity.MotionType.walking)
            Image(systemName: "tram.fill").tag(MeasuredActivity.MotionType.train)
            Image(systemName: "airplane").tag(MeasuredActivity.MotionType.plane)
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    var barColour : Color {
        var colour: String = "graphBars"
        let carbonByTransport = dataGraph.data[1]
        
        // graph changes colour depending on users's daily carbon footprint
        var todayTotal = 0.0
        for motion in MeasuredActivity.MotionType.allCases {
            if let labelledValue = carbonByTransport[motion]?.last {
                if motion != .walking {
                    todayTotal += labelledValue.data
                }
            }
        }

        if todayTotal > AV_UK_DAILYCARBON {
            colour = "redGraphBar"
        }
        return Color(colour)
    }
    
    func kgToReadableLabel(valueInKg: Double) -> String {
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
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
