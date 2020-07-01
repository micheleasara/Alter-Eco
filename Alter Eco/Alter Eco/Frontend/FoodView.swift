import SwiftUI

struct FoodView: View {
    @EnvironmentObject var measurementsOnLaunch: ScreenMeasurements
    @EnvironmentObject var foodAwards: FoodAwardsManager
    @EnvironmentObject var pieChartModel: FoodPieChartModel
    @State private var showFoodList: Bool = false
    @State private var showScanner: Bool = false
    @State private var foodListModel = FoodListViewModel()
    
    var body: some View {
        ScrollView {
            if showFoodList {
                FoodListView(isVisible: $showFoodList, model: foodListModel)
            }
            else {
                chartsAndAchievements
            }
        }
    }
    
    private var chartsAndAchievements: some View {
        VStack(alignment: .center) {
            FoodChart().frame(height: measurementsOnLaunch.longitudinal / 2.5)

            Button(action: {
                self.showScanner.toggle()
            }) {
                HStack {
                    Text("Scan barcode")
                    Image(systemName: "camera.fill")
                }
            }.sheet(isPresented: $showScanner, onDismiss: { self.showFoodList = self.foodListModel.count > 0 }) { ScannerView(foodListModel: self.$foodListModel) }
            
            // show pie chart only if we have data
            if pieChartModel.values.reduce(0, +) > 0 {
                PieChart(model: pieChartModel)
                    .padding()
                    .frame(width: 0.8*measurementsOnLaunch.trasversal,
                           height: 0.8*measurementsOnLaunch.trasversal)
                    .padding(.horizontal)
            } else {
                PieChart.empty()
                    .frame(width: 0.45*measurementsOnLaunch.trasversal,
                           height: 0.45*measurementsOnLaunch.trasversal,
                           alignment: .center)
            }
            
            Text("Achievements")
                .font(.headline)
                .fontWeight(.semibold)
            AwardView(awardsManager: foodAwards)
        }
    }
}

struct FoodChart: View {
    @State private var timespanSelection: String = ""
    @State private var foodSelection: String = ""

    var body: some View {
        VStack () {
            timePicker.padding(.horizontal)

            Text("Total carbon emitted: 140 g").bold()
            BarChart(values: self.getValues(), xLabels: self.getLabels(), infoOnBarTap: self.getInfoOnBarTap(), colour: Color.blue, yAxisTicksCount: 4).padding(.horizontal)
            
            foodPicker.padding()
        }
    }
    
    /// Represents the picker for the timespan the user's wishes to see.
    public var timePicker : some View {
        Picker(selection: $foodSelection.animation(), label: Text("")) {
            Text("Weekly").tag("a")
            Text("Monthly").tag("b")
            Text("Yearly").tag("c")
        }
          .pickerStyle(SegmentedPickerStyle())
    }
    
    /// Represents the picker for the food type the user's wishes to see.
    public var foodPicker : some View {
        Picker(selection: $timespanSelection.animation(), label: Text("")) {
            Text("All").tag("a")
            Text("Meat").tag("1")
            Text("Dairies").tag("2")
            Text("Veggies").tag("3")
            Text("Other").tag("4")
        }
          .pickerStyle(SegmentedPickerStyle())
    }
    
    private func getValues() -> [Double] {
        return [10, 30, 20, 20, 45, 23, 12]
    }
    
    private func getLabels() -> [String] {
        return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    }
    
    private func getInfoOnBarTap() -> [String] {
        return ["","","","","","",""]
    }
}

struct FoodView_Previews: PreviewProvider {
    static var previews: some View {
        FoodView()
            .environmentObject(ScreenMeasurements())
        .environmentObject(FoodAwardsManager(DBMS: CoreDataManager()))
    }
}
