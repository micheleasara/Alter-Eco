import SwiftUI

struct SettingsView: View {
    @ObservedObject private var cycleEnabled = (UIApplication.shared.delegate as! AppDelegate).cycleEnabled
    @ObservedObject private var pauseTrackingEnabled = (UIApplication.shared.delegate as! AppDelegate).autoPauseEnabled
    @ObservedObject private var speed = (UIApplication.shared.delegate as! AppDelegate).cycleSpeed
    @State private var showingCycleInfo = false
    @State private var showingPauseInfo = false
    @Environment(\.DBMS) var DBMS

    var body: some View {
        VStack(alignment: .leading) {
            pauseTrackingToggle
                .padding(.horizontal)
                .padding(.bottom)
            
            cycleToggle.padding(.horizontal)
            if cycleEnabled.rawValue {
                VStack {
                    Slider(value: $speed.rawValue,
                           in: AUTOMOTIVE_SPEED_THRESHOLD...2*DEFAULT_CYCLE_SPEED, step: 0.5)
                    Text(String(format: "My usual speed is %.1f km/h (or %.1f m/s)", MPSToKMPH(speed.rawValue), speed.rawValue))
                }.padding(.horizontal)
            }
            Text("Press 'Back' to save your settings.").italic()
                .padding().padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top)
        .onDisappear() {
            self.saveSettings()
        }
    }
    
    func MPSToKMPH(_ speedInMPS: Double) -> Double {
        return speedInMPS * KM_CONVERSION * HOUR_IN_SECONDS
    }
    
    var pauseTrackingToggle: some View {
        Toggle(isOn: $pauseTrackingEnabled.rawValue) {
            HStack {
                Text("Pause tracking if idle")
                Button(action: { self.showingPauseInfo = true }) {
                    Image(systemName: "info.circle")
                }.alert(isPresented: $showingPauseInfo) {
                    Alert(title: Text("Info"),
                          message: Text("Enable this feature if you wish for Alter Eco to stop tracking automatically when you haven't moved in a while."),
                          dismissButton: .default(Text("Got it!")))
                }
            }
        }
    }
    
    var cycleToggle: some View {
        Toggle(isOn: $cycleEnabled.rawValue) {
            HStack {
                Text("I cycle very often")
                Button(action: { self.showingCycleInfo = true }) {
                    Image(systemName: "info.circle")
                }.alert(isPresented: $showingCycleInfo) {
                    Alert(title: Text("Info"),
                          message: Text("Enable this feature if you cycle very often (or you are about to).\n\nIt will lower the accuracy for low speed car/train journeys, but it will decrease false positives when you cycle.\n\nAs cycling is considered not polluting, the data will be displayed as if you were walking."),
                          dismissButton: .default(Text("Got it!")))
                }
            }
        }
    }
    
    func saveSettings() {
        try? DBMS.deleteAll(entity: "UserPreference")
        
        try? DBMS.setValuesForKeys(entity: "UserPreference",
            keyedValues:
            ["firstLaunch": false,
             "cycleEnabled": cycleEnabled.rawValue!,
             "cycleRelaxation": speed.rawValue!,
             "autoPauseEnabled": pauseTrackingEnabled.rawValue!])
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
