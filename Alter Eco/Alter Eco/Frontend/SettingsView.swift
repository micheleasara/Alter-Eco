import SwiftUI

struct SettingsView: View {
    @State private var cycleEnabled = UserDefaults.standard.bool(forKey: "cycleEnabled")
    @State private var autoPauseEnabled = UserDefaults.standard.bool(forKey: "autoPauseEnabled")
    @State private var speed = UserDefaults.standard.double(forKey: "cycleSpeed")
    @State private var showingCycleInfo = false
    @State private var showingPauseInfo = false

    var body: some View {
        VStack(alignment: .leading) {
            pauseTrackingToggle
                .padding(.horizontal)
                .padding(.bottom)
            
            cycleToggle.padding(.horizontal)
            if cycleEnabled {
                VStack {
                    Slider(value: $speed,
                           in: AUTOMOTIVE_SPEED_THRESHOLD...2*DEFAULT_CYCLE_SPEED, step: 0.5)
                    Text(String(format: "My usual speed is %.1f km/h (or %.1f m/s)", MPSToKMPH(speed), speed))
                }.padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top)
        .onDisappear() {
            self.saveSettings()
        }
    }
    
    private func MPSToKMPH(_ speedInMPS: Double) -> Double {
        return speedInMPS * KM_CONVERSION * HOUR_IN_SECONDS
    }
    
    private var pauseTrackingToggle: some View {
        Toggle(isOn: $autoPauseEnabled) {
            HStack {
                Text("Pause tracking if idle")
                Button(action: { self.showingPauseInfo = true }) {
                    Image(systemName: "info.circle")
                }.alert(isPresented: $showingPauseInfo) {
                    Alert(title: Text("Info"),
                          message: Text("Enable this feature if you wish for Alter Eco to stop tracking your location when you haven't moved in a while or there is no signal."),
                          dismissButton: .default(Text("Got it!")))
                }
            }
        }
    }
    
    private var cycleToggle: some View {
        Toggle(isOn: $cycleEnabled) {
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
    
    private func saveSettings() {
        UserDefaults.standard.set(cycleEnabled, forKey: "cycleEnabled")
        UserDefaults.standard.set(speed, forKey: "cycleSpeed")
        UserDefaults.standard.set(autoPauseEnabled, forKey: "autoPauseEnabled")
        (UIApplication.shared.delegate as? AppDelegate)?.manager.pausesLocationUpdatesAutomatically = autoPauseEnabled
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
