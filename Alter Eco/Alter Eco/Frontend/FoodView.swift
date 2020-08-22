import SwiftUI

public struct FoodView: View {
    @EnvironmentObject var measurementsOnLaunch: ScreenMeasurements
    @EnvironmentObject var foodAwards: FoodAwardsManager
    @EnvironmentObject var pieChartModel: FoodPieChartViewModel
    @EnvironmentObject var foodListModel: FoodListViewModel
    @State private var showFoodList: Bool = false
    @State private var showScanner: Bool = false
    @State private var scannerViewModel = FoodScannerViewModel(foodRetriever: OpenFoodFacts(),
                                                    scannerDelegate: ScannerViewController())
    
    public var body: some View {
        VStack {
            if showFoodList {
                FoodListView(isVisible: $showFoodList)
            }
            else {
                ScrollView {
                    VStack {
                        charts
                        Text("Powered by OpenFoodFacts").font(.caption).italic().padding()
                    }
                }
            }
        }
    }
    
    private var charts: some View {
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
                self.foodListModel.update(foods: self.scannerViewModel.retrievedFoods, notFound: self.scannerViewModel.foodsNotFound)
                self.scannerViewModel.reset()
                self.showFoodList = !self.foodListModel.isEmpty
            }) {
                // environment object required as ScannerView is UIViewControllerRepresentable
                FoodScannerView(viewModel: self.scannerViewModel, retrievalCompleted: self.$scannerViewModel.retrievalCompleted)
                .environmentObject(self.foodListModel)
            }
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
