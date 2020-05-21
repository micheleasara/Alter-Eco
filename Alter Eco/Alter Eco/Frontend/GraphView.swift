import SwiftUI


struct GraphView: View {
    //Two picker variables set to 0 and the values are changed upon the users touch (changed values are found in the code below)
    //The following picker represents the options of 'day' 'week' 'month' 'year'
    @State var timePickerSelection = 0
    //The following picker represents the travel options of 'all' 'car' 'walk' 'train' 'plane'
    @State var transportPickerSelection = 0
    @EnvironmentObject var dataGraph : DataGraph

    var body: some View {
        //The top picker represents the time (e.g. day vs week) the user would like to view. For example, if the user selects the week picker, the picker would change to a value of 5. These values have been chosen to correctly index the dictionary above (when added to the picker value of the transport mode)
        
        return VStack {

            getTimePicker()
            ZStack{
                //Gridlines (as declared in gridlines.swift) dynamically change depending on the max value for the view. The value of the sum of the pickers is passed to the gridlines to ensure they adjust for the view.
                Gridlines(value:self.timePickerSelection+self.transportPickerSelection)
                //The bar chart is constructed here
                HStack {//The bar displayed depends on the two pickers chosen
                    ForEach(0..<dataGraph.data[timePickerSelection+transportPickerSelection].carbonByDate.count, id: \.self)
                    {
                        i in
                        BarView(height: self.dataGraph.data[self.timePickerSelection+self.transportPickerSelection].carbonByDate[i].carbon,label: self.dataGraph.data[self.timePickerSelection+self.transportPickerSelection].carbonByDate[i].day.shortName,wid: self.timePickerSelection)
                    }
                    
                }
            }
            
            //Transport option picker
            getTransportPicker()
        }
    }
    
    func getTimePicker() -> some View {
        Picker(selection: $timePickerSelection.animation(), label: Text("")) {
            Text("Daily").tag(0)
            Text("Weekly").tag(5)
            Text("Monthly").tag(10)
            Text("Yearly").tag(15)
        }
          .pickerStyle(SegmentedPickerStyle())
          .padding()
    }
    
    func getTransportPicker() -> some View {
        Picker(selection: $transportPickerSelection.animation(), label: Image("")) {
            Text("All").tag(0)
            Image(systemName: "car").tag(1)
            Image(systemName: "person").tag(2)
            Image(systemName: "tram.fill").tag(3)
            Image(systemName: "airplane").tag(4)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
}


struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView().environmentObject(DataGraph())
    }
}

