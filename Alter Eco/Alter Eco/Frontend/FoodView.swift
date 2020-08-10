import SwiftUI

public struct FoodView: View {
    @EnvironmentObject var measurementsOnLaunch: ScreenMeasurements
    @EnvironmentObject var foodAwards: FoodAwardsManager
    @EnvironmentObject var pieChartModel: FoodPieChartViewModel
    @EnvironmentObject var foodListModel: FoodListViewModel
    @State private var showFoodList: Bool = false
    @State private var showScanner: Bool = false
    
    public var body: some View {
        VStack {
            if showFoodList {
                FoodListView(isVisible: $showFoodList)
            }
            else {
                ScrollView {
                    VStack {
                        chartsAndAchievements
                        Text("Powered by OpenFoodFacts").font(.caption).italic().padding()
                    }
                }
            }
        }
    }
    
    private var chartsAndAchievements: some View {
        VStack(alignment: .center) {
            
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
            
            Button(action: {
                self.showScanner.toggle()
            }) {
                HStack {
                    Text("Scan barcode")
                    Image(systemName: "camera.fill")
                }
                }.padding()
            .sheet(isPresented: $showScanner, onDismiss: {
                self.showFoodList = !self.foodListModel.isEmpty
            }) { ScannerView().environmentObject(self.foodListModel) }
            
//            Text("Achievements")
//                .font(.headline)
//                .fontWeight(.semibold)
//            AwardView(awardsManager: foodAwards)
        }
    }
}

struct FoodView_Previews: PreviewProvider {
    static var previews: some View {
        let DBMS = CoreDataManager()
        return FoodView()
            .environmentObject(ScreenMeasurements())
            .environmentObject(FoodPieChartViewModel(DBMS: DBMS))
    }
}
