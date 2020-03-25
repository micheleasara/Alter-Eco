import SwiftUI

struct ScoreView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    let WALKING_PTS: Double = 10
    let TUBE_PTS: Double = 7
    let CAR_PTS: Double = 3

    func calculateScore() -> String {
        
        //ADD TO THE OLD POINTS TOTAL
        //MAKE IT SUCH THAT THE QUERY HAPPENS ONCE A DAY
        
        //query walking
        let walkingKm = queryDailyKm(motionType: MeasuredActivity.MotionType.walking, hourStart: "00:00:00", hourEnd: "23:59:59")
       
        //query car
        let carKm = queryDailyKm(motionType: MeasuredActivity.MotionType.car, hourStart: "00:00:00", hourEnd: "23:59:59")
       
        //query tube
        let tubeKm = queryDailyKm(motionType: MeasuredActivity.MotionType.train, hourStart: "00:00:00", hourEnd: "23:59:59")
        
        //query plane
        //queryDailyKm(motionType: MeasuredActivity.MotionType.plane, hourStart: "00:00:00", hourEnd: "23:59:59")
        
        //total kms
        let total = walkingKm + carKm + tubeKm
        
        //prevent division by 0
        if total == 0 {return String(total)}
        
        let walkingPoints = (walkingKm/total) * WALKING_PTS
        let carPoints = (walkingKm/total) * CAR_PTS
        let tubePoints = (walkingKm/total) * TUBE_PTS
        
        return String(walkingPoints+carPoints+tubePoints)
        
    }
    
    var body: some View {
    
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color("fill_colour"))
                .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.9, height: CGFloat(screenMeasurements.broadcastedHeight)/10)
                    

            HStack {
                
                Text("Total Score: \(calculateScore())" )
                    .font(.title)
            }
        }
    }
}

struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreView()
    }
}


