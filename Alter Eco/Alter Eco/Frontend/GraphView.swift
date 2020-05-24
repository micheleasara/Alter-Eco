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
            timePicker().padding(.top).padding(.horizontal)
            
            Text("Carbon footprint chart")
                .font(.headline)
                .fontWeight(.semibold)
            
            BarChart(values: getValues(), labels: getLabels(), colour: Color("graphBars")).frame(height: screenMeasurements.height/3.8).padding(.horizontal)

            transportPicker().padding(.bottom).padding(.horizontal)
        }
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
    
    func timePicker() -> some View {
        Picker(selection: $timePickerSelection.animation(), label: Text("")) {
            Text("Daily").tag(0)
            Text("Weekly").tag(1)
            Text("Monthly").tag(2)
            Text("Yearly").tag(3)
        }
          .pickerStyle(SegmentedPickerStyle())
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
    }
    
//    func barColour() -> String {
//        var colour: String = "graphBars"
//        let todayCarbon = dataGraph.data[1].last!.carbonByMotion
//        var total = 0.0
//        for motion in MeasuredActivity.MotionType.allCases {
//            if let carbon = todayCarbon[motion] {
//                if motion != .walking {
//                    total += carbon
//                }
//            }
//        }
//
//        if total > AV_UK_DAILYCARBON {
//            colour = "redGraphBar"
//        }
//        return colour
//    }
}


struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
