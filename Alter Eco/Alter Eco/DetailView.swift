import SwiftUI

struct DetailView: View {
    
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    
    var body: some View {
        ScrollView {
            ZStack {
                Color("app_background")
                
                VStack{
                
                    //welcome, and profile button
                    WelcomeView()
                    
                    //Bar chart view
                    GraphView()
                    
                    //Scores summary
                    ScoreView()
                    
                    //Highlights
                    HighlightView()
                        
                }
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView()
    }
}
