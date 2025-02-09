import SwiftUI

// data for conversions to CO2 of food production comes from:
//https://www.businessinsider.com/the-top-10-foods-with-the-biggest-environmental-footprint-2015-9?IR=T

// data for conversion to oxygen production of trees comes from:
//https://www.eea.europa.eu/articles/forests-health-and-climate-change/key-facts/trees-help-tackle-climate-change

public struct HighlightView: View {
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    public let dailyCarbon: Double
    
    public var body: some View {
        VStack {
            Text("Highlights & Tips")
                .font(.headline)
                .fontWeight(.semibold)
            
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color("fill_colour"))
                .frame(width: screenMeasurements.trasversal*0.9, height: screenMeasurements.longitudinal/7)
                .overlay(
                    Text(generateSentence())
                    .allowsTightening(true)
                    .minimumScaleFactor(0.01)
                    .padding())
        }
    }
    
    private func generateSentence() -> String {
        let possibileSentences = getGreenSentences()
        let rnd = Int.random(in: 0..<possibileSentences.count)
        return possibileSentences[rnd]
    }
    
    private func getGreenSentences() -> [String] {
        switch dailyCarbon {
        case AVERAGE_UK_DAILY_CARBON..<Double.infinity:
            return ["Be careful! You're consuming more than the UK average! ⚠️",
            "To make up for your transport emissions why don't you try buying local products? 🍰",
            "To make up for your transport emissions why don't you try plastic-free alternatives? 🍀",
            "To make up for your transport emissions why don't you try going vegetarian for a day? 🥬",
            "To reduce your transport emissions why don't you try cycling more often? 🚲"]
            
        case 1.4..<AVERAGE_UK_DAILY_CARBON:
            return ["So far today you're consuming as much as an average tree can absorb in one month! 😥",
            "Try to share car rides when you have to drive! 🚘",
            "Remember to avoid bottled water! Bring your own bottle 🍃",
            "We are living on this planet as if we had another one to go to. -- Terri Swearingen 💬",
            "The Earth is a fine place and worth fighting for. -- Ernest Hemingway 💬"]
            
        case 0.8..<1.4:
            return ["So far today you've emitted the same amount of carbon necessary to produce 2 jars of peanut butter! 🥜",
            "Twenty-five years ago people could be excused for not knowing much, or doing much, about climate change. Today we have no excuse. -- Desmond Tutu 💬",
            "We do not inherit the earth from our ancestors. We borrow it from our children.” – Native American Proverb 💬",
            "You're doing well!",
            "Climate change is sometimes misunderstood as being about changes in the weather. In reality, it is about changes in our very way of life. -- Paul Polman 💬" ]
            
        default:
            return ["You're doing so well with your transport emissions. You're an absolute star! 🌟",
            "You're doing so well with your transport emissions. You can do even better by going plastic-free! 💚",
            "You're doing so well with your transport emissions. You can do even better by going vegetarian for a day! 🍏",
            "Next time you need a toothbrush, why don't you try out a bamboo one? 🐼",
            "Did you know that up to 27% of total emissions come from transport? You're saving the world! 👍"]
        }
    }
}

struct HighlightView_Previews: PreviewProvider {
    static var previews: some View {
        HighlightView(dailyCarbon: 0)
            .environmentObject(ScreenMeasurements())
    }
}

