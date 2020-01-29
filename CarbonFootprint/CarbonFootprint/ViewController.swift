import UIKit
import CoreMotion

class ViewController: UIViewController {
    let motionManager = CMMotionActivityManager()
    var motionActivity = CMMotionActivity()
    
    func startMotionActivityManager(){
        if CMMotionActivityManager.isActivityAvailable(){
            motionManager.startActivityUpdates(to: OperationQueue.main){
                (motion) in
                if let motionActivityUnwrap = motion {
                    self.motionActivity = motionActivityUnwrap
                    self.activityOut.text = self.getActivity()
                }
            }
        }
        
        else {
            activityOut.text = "Motion activity not available"
        }
        }
    
    func getActivity() -> String{
        var activityString = ""
        switch motionActivity.confidence{
        case .low:
            activityString = "Low"
        case .medium:
            activityString = "Medium"
        case .high:
            activityString = "High"
        @unknown default:
            activityString = "Unknown"
        }
        if motionActivity.stationary{activityString += ":Stationary"}
        if motionActivity.walking{activityString += ":Walking"}
        if motionActivity.running{activityString += ":Running"}
        if motionActivity.automotive{activityString += ":Car"}
        if motionActivity.cycling{activityString += ":Bike"}
        if motionActivity.unknown{activityString += ":Unknown"}
        if (!motionActivity.stationary && !motionActivity.walking
            && !motionActivity.running && !motionActivity.automotive
            && !motionActivity.cycling && !motionActivity.unknown)
            {return ""}
        
        return activityString
    }
    
    @IBOutlet weak var activityOut: UILabel!
    //@IBOutlet weak var activityLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readActivityData()
       // startMotionActivityManager()
        // Do any additional setup after loading the view.
    }
 func activity(motionActivity:CMMotionActivity)-> String{
       var activityString = "unknown"
       switch motionActivity.confidence{
       case .low:
           activityString = "Low"
       case .medium:
           activityString = "Medium"
       case .high:
           activityString = "High"
       }
       if motionActivity.stationary{activityString += ":Stationary"}
       if motionActivity.walking{activityString += ":Walking"}
       if motionActivity.running{activityString += ":Running"}
       if motionActivity.automotive{activityString += ":Car"}
       if motionActivity.cycling{activityString += ":Bike"}
       if motionActivity.unknown{activityString += ":Unknown"}
       if (!motionActivity.stationary && !motionActivity.walking
       && !motionActivity.running && !motionActivity.automotive
       && !motionActivity.cycling && !motionActivity.unknown)
       {return ""}
       
       return activityString
   }
    
    func readActivityData(){
        let now = Date()
        let yesterday = Date(timeIntervalSinceNow: (-3600*24*10))
        let dateFormatter = DateFormatter()
           dateFormatter.dateStyle = .short
           dateFormatter.timeStyle = .long
           motionManager.queryActivityStarting(from: yesterday, to: now, to: OperationQueue.main) { (motionActivities, error) in
               if let motionActivities = motionActivities {
                   for motionActivity in motionActivities{
                       let activityString = dateFormatter.string(from: motionActivity.startDate) + "  " + self.activity(motionActivity: motionActivity)
                    if (self.activity(motionActivity: motionActivity) != ""){
                        print(activityString)
                    }
                    else {continue}
                   }
               }
           }
       }
    
    
}
    



