import SwiftUI


struct GraphView: View {
    //Two picker variables set to 0 and the values are changed upon the users touch (changed values are found in the code below)
    //The following picker represents the options of 'day' 'week' 'month' 'year'
    @State var pickerSelectedItem = 0
    //The following picker represents the travel options of 'all' 'car' 'walk' 'train' 'plane'
    @State var pickerSelectedTwoItem = 0
    @EnvironmentObject var dataGraph : DataGraph

    var body: some View {
        //The top picker represents the time (e.g. day vs week) the user would like to view. For example, if the user selects the week picker, the picker would change to a value of 5. These values have been chosen to correctly index the dictionary above (when added to the picker value of the transport mode)
        
        return VStack {

            Picker(selection: $pickerSelectedItem.animation(), label: Text("")) {
                Text(DataParts.day.name).tag(0)
                Text(DataParts.week.name).tag(5)
                Text(DataParts.month.name).tag(10)
                Text(DataParts.year.name).tag(15)
            }
              .pickerStyle(SegmentedPickerStyle())
              .padding()
            ZStack{
                //Gridlines (as declared in gridlines.swift) dynamically change depending on the max value for the view. The value of the sum of the pickers is passed to the gridlines to ensure they adjust for the view.
                Gridlines(value:self.pickerSelectedItem+self.pickerSelectedTwoItem)
                //The bar chart is constructed here
                HStack {//The bar displayed depends on the two pickers chosen
                    ForEach(0..<dataGraph.data[pickerSelectedItem+pickerSelectedTwoItem].carbonByDate.count, id: \.self)
                    { i in
                        BarView(height: self.dataGraph.data[self.pickerSelectedItem+self.pickerSelectedTwoItem].carbonByDate[i].carbon,label: self.dataGraph.data[self.pickerSelectedItem+self.pickerSelectedTwoItem].carbonByDate[i].day.shortName,wid: self.pickerSelectedItem)}}
                
            }
            
            //Transport option picker
            Picker(selection: $pickerSelectedTwoItem.animation(), label: Image("")) {
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
}


struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView()
    }
}

