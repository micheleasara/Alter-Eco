import SwiftUI

struct GraphView: View {
    //The following picker represents the options of 'day' 'week' 'month' 'year'
    @State var timePickerSelection = 0
    //The following picker represents the travel options of 'all' 'car' 'walk' 'train' 'plane'
    @State var transportPickerSelection = MeasuredActivity.MotionType.unknown
    @EnvironmentObject var dataGraph : DataGraph

    var body: some View {
        let max = dataGraph.getMax(i: timePickerSelection, type: transportPickerSelection)
        print("max is ", max)
        let axisMax = maxAxisValue(actualMax: max)
        
        return VStack {
            timePicker()
            ZStack {
                Gridlines(numGridLines: 8, maximumValue: axisMax)
                dataBars(normalizeWith: max)
            }
            transportPicker()
        }
    }
    
    func timePicker() -> some View {
        Picker(selection: $timePickerSelection.animation(), label: Text("")) {
            Text("Daily").tag(0)
            Text("Weekly").tag(1)
            Text("Monthly").tag(2)
            Text("Yearly").tag(3)
        }
          .pickerStyle(SegmentedPickerStyle())
          .padding()
    }
    
    func dataBars(normalizeWith: Double) -> some View {
        var normalisation = normalizeWith
        if normalisation == 0.0 {
            normalisation = 1.0 // avoid divide-by-zero errors
        }
        return HStack {
            ForEach(dataGraph.data[timePickerSelection], id: \.self)
            {
                labelledDataPoint in
                BarView(height: labelledDataPoint.carbonByMotion[self.transportPickerSelection]! / normalisation,
                        label: labelledDataPoint.label,
                        timePickerSelection: self.timePickerSelection,
                        colour: self.barColour())
            }
        }
    }
    
    func maxAxisValue(actualMax: Double) -> Double {
        switch actualMax {
        case 0.001..<1:
            return actualMax * 1000
        case 1000..<Double.infinity:
            return actualMax / 1000
        default:
            return actualMax
        }
    }
    
    func transportPicker() -> some View {
        Picker(selection: $transportPickerSelection.animation(), label: Image("")) {
            Text("All").tag(MeasuredActivity.MotionType.unknown)
            Image(systemName: "car").tag(MeasuredActivity.MotionType.car)
            Image(systemName: "person").tag(MeasuredActivity.MotionType.walking)
            Image(systemName: "tram.fill").tag(MeasuredActivity.MotionType.train)
            Image(systemName: "airplane").tag(MeasuredActivity.MotionType.plane)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
    
    func barColour() -> String {
        var colour: String = "graphBars"
        let todayCarbon = dataGraph.data[1].last!.carbonByMotion
        var total = 0.0
        for motion in MeasuredActivity.MotionType.allCases {
            if let carbon = todayCarbon[motion] {
                if motion != .walking {
                    total += carbon
                }
            }
        }
        
        if total > AV_UK_DAILYCARBON {
            colour = "redGraphBar"
        }
        return colour
    }
}


struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView().environmentObject(DataGraph())
    }
}

