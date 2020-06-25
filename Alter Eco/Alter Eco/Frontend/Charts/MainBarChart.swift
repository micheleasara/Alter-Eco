import SwiftUI

struct MainBarChart: View {
    var body: some View {
        VStack () {
            Text("Emissions of the week: 300 g").bold()
            BarChart(values: self.getValues(), xLabels: self.getLabels(), infoOnBarTap: self.getInfoOnBarTap(), colour: Title.colour, yAxisTicksCount: 4).padding(.horizontal)
        }
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

struct MainBarChart_Previews: PreviewProvider {
    static var previews: some View {
        MainBarChart()
    }
}
