import SwiftUI

//data for conversions to CO2 of food production comes from:
//https://www.businessinsider.com/the-top-10-foods-with-the-biggest-environmental-footprint-2015-9?IR=T

//data for conversion to oxygen production of trees comes from:
//https://www.eea.europa.eu/articles/forests-health-and-climate-change/key-facts/trees-help-tackle-climate-change

func generateSentence() -> String {
    
    let currentDateTime = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    
    let value = try! DBMS.queryHourlyCarbonAll(hourStart: "00:00:00", hourEnd: formatter.string(from: currentDateTime))
    let number = Int.random(in: 0 ..< 5)
    
    if (value >= 2300) {
       
        if (number == 0) {return "Be careful! You're consuming more than the UK average! You can do better."}
        if (number == 1) {return "To make up for your transport emissions why don't you try buying local produce?"}
        if (number == 2) {return "To make up for your transport emissions why don't you try plastic alternatives?"}
        if (number == 3) {return "To make up for your transport emissions why don't you try going vegetarian for a day?"}
        if (number == 4) {return "To reduce your transport emissions why don't you try cycling more often?"}
    }
    
    if (value >= 1400 && value < 2300) {
     
        if (number == 0) {return "So far today you're consuming as much as an average tree can absorb in one month!"}
        if (number == 1) {return "Try to share car rides when you have to drive!"}
        if (number == 2) {return "Remember to avoid bottled water! Bring your own bottle. "}
        if (number == 3) {return "We are living on this planet as if we had another one to go to. -- Terri Swearingen"}
        if (number == 4) {return "The Earth is a fine place and worth fighting for. -- Ernest Hemingway"}
    }
    
    if (value >= 800 && value < 1400) {
        
        if (number == 0) {return "So far today you've emitted the same amount of carbon necessary to produce 2 jars of peanut butter! Not bad..."}
        if (number == 1) {return "Twenty-five years ago people could be excused for not knowing much, or doing much, about climate change. Today we have no excuse. -- Desmond Tutu"}
        if (number == 2) {return "We do not inherit the earth from our ancestors. We borrow it from our children.” – Native American Proverb"}
        if (number == 3) {return "You're doing well!"}
        if (number == 4) {return "Climate change is sometimes misunderstood as being about changes in the weather. In reality, it is about changes in our very way of life. -- Paul Polman"}
    }
    
    if (number == 0) {return "You're doing so well with your transport emissions. You're an absolute star!"}
    if (number == 1) {return "You're doing so well with your transport emissions. You can do even better by going plastic-free!"}
    if (number == 2) {return "You're doing so well with your transport emissions. You can do even better by going vegetarian for a day!"}
    if (number == 3) {return "Next time you need a toothbrush, why don't you try out a bamboo one?"}
    
    return "Did you know that up to 27% of total emissions come from transport? You're saving the world!"
}

struct HighlightView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements

    var body: some View {
  
        VStack {
            Text("Highlights & Tips")
                .font(.headline)
                .padding(.trailing, CGFloat(screenMeasurements.broadcastedWidth)/2.5)
            
            ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color("fill_colour"))
                .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.9, height: CGFloat(screenMeasurements.broadcastedHeight)/4)
                
            Text(generateSentence())
                .font(.headline)
                .fontWeight(.regular)
                .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.7, height: CGFloat(screenMeasurements.broadcastedHeight)/5)
            }
        }
    }
}

struct HighlightView_Previews: PreviewProvider {
    static var previews: some View {
        HighlightView()
    }
}

