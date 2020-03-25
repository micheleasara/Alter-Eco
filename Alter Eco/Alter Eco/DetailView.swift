import SwiftUI

struct DetailView: View {
    
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    
    var body: some View {
            
        ZStack {
            Color("app_background")
            
            VStack{
                
                //welcome, and profile button
                WelcomeView().padding(.top, CGFloat(screenMeasurements.broadcastedHeight/100))
                Spacer()
                
                //Bar chart view
                GraphView()
                Spacer()
                
                //Scores summary
                ScoreView()
                Spacer()
                
                //Highlights
                HighlightView()
                Spacer()
                    
            }//vs
        }//zs
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView()
    }
}
