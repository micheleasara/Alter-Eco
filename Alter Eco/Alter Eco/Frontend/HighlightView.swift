import SwiftUI

// data for conversions to CO2 of food production comes from:
//https://www.businessinsider.com/the-top-10-foods-with-the-biggest-environmental-footprint-2015-9?IR=T

// data for conversion to oxygen production of trees comes from:
//https://www.eea.europa.eu/articles/forests-health-and-climate-change/key-facts/trees-help-tackle-climate-change

public struct HighlightView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements

    public var body: some View {
        VStack {
            Text("Highlights & Tips")
                .font(.headline)
                .fontWeight(.semibold)
            
            ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color("fill_colour"))
                .frame(width: screenMeasurements.trasversal*0.9, height: screenMeasurements.longitudinal/6)
                
            Text(generateSentence())
                .font(.headline)
                .fontWeight(.regular)
                .frame(width: screenMeasurements.trasversal*0.7, height: screenMeasurements.longitudinal/7)
            }
        }
    }
    
    private func generateSentence() -> String {
        let possibileSentences = getGreenSentences()
        let rnd = Int.random(in: 0..<possibileSentences.count)
        return possibileSentences[rnd]
    }
    
    private func getGreenSentences() -> [String] {
        let currentDateTime = Date()
        dateFormatter.dateFormat = "HH:mm:ss"
        let value = try! DBMS.queryHourlyCarbonAll(hourStart: "00:00:00", hourEnd: dateFormatter.string(from: currentDateTime))
        
        switch value {
        case AV_UK_DAILYCARBON..<Double.infinity:
            return ["Be careful! You're consuming more than the UK average! You can do better.",
            "To make up for your transport emissions why don't you try buying local products?",
            "To make up for your transport emissions why don't you try plastic alternatives?",
            "To make up for your transport emissions why don't you try going vegetarian for a day?",
            "To reduce your transport emissions why don't you try cycling more often?"]
            
        case 1.4..<AV_UK_DAILYCARBON:
            return ["So far today you're consuming as much as an average tree can absorb in one month!",
            "Try to share car rides when you have to drive!",
            "Remember to avoid bottled water! Bring your own bottle.",
            "We are living on this planet as if we had another one to go to. -- Terri Swearingen",
            "The Earth is a fine place and worth fighting for. -- Ernest Hemingway"]
            
        case 0.8..<1.4:
            return ["So far today you've emitted the same amount of carbon necessary to produce 2 jars of peanut butter! Not bad...",
            "Twenty-five years ago people could be excused for not knowing much, or doing much, about climate change. Today we have no excuse. -- Desmond Tutu",
            "We do not inherit the earth from our ancestors. We borrow it from our children.” – Native American Proverb",
            "You're doing well!",
            "Climate change is sometimes misunderstood as being about changes in the weather. In reality, it is about changes in our very way of life. -- Paul Polman"]
            
        default:
            return ["You're doing so well with your transport emissions. You're an absolute star!",
            "You're doing so well with your transport emissions. You can do even better by going plastic-free!",
            "You're doing so well with your transport emissions. You can do even better by going vegetarian for a day!",
            "Next time you need a toothbrush, why don't you try out a bamboo one?",
            "Did you know that up to 27% of total emissions come from transport? You're saving the world!"]
        }
    }
}

struct HighlightView_Previews: PreviewProvider {
    static var previews: some View {
        HighlightView().environmentObject(ScreenMeasurements())
    }
}

