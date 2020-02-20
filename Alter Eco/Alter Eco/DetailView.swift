
import SwiftUI
 
enum DataParts: Int, CaseIterable, Hashable, Identifiable {
    case day = 0
    case week
    case month
    case year
    case car
    case walk
    
    var name: String {
        return "\(self)".capitalized
    }
    var id: DataParts {self}
}
 
enum Transport: Int, CaseIterable, Hashable, Identifiable {
    case all = 0
    case car
    case walk
    case tube
    
    var name: String {
        return "\(self)".capitalized
    }
    
    
    var id: Transport {self}
}
 
enum Combined: Int, CaseIterable, Hashable, Identifiable {
    case dayall = 0
    case daycar
    case daywalk
    
 
    
    var name: String {
        return "\(self)".capitalized
    }
    
    
    var id: Combined {self}
}
 
 
 
enum DaySpecifics: CaseIterable, Hashable, Identifiable {
    case zerohour
    case twohour
    case threehour
    case fourhour
    case fivehour
    case sixhour
    case sevenhour
    case eighthour
    case ninehour
    case tenhour
    case elevenhour
    case twelvehour
    case thirteenhour
    case fourteenhour
    case fifteenhour
    case sixteenhour
    case seventeenhour
    case eighteenhour
    case nineteenhour
    case twentyhour
    case twentyonehour
    case twentytwohour
    case twentythreehour
    case twentyfourhour
    
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    case oneday
    case twoday
    case threeday
    case fourday
    case fiveday
    case sixday
    case sevenday
    
    
    case january
    case febuary
    case march
    case april
    case may
    case june
    case july
    case august
    case september
    case october
    case november
    case december
    
    case fourteen
    case fifteen
    case sixteen
    case seventeen
    case eighteen
    case nineteen
    case twenty
 
    
    
    var shortName: String {
        if (self==DaySpecifics.fourteen)
        { return "2014"}
        if (self==DaySpecifics.fifteen)
        { return "2015"}
        if (self==DaySpecifics.sixteen)
        { return "2016"}
        if (self==DaySpecifics.seventeen)
        { return "2017"}
        if (self==DaySpecifics.eighteen)
        { return "2018"}
        if (self==DaySpecifics.nineteen)
        { return "2019"}
        if (self==DaySpecifics.twenty)
        { return "2020"}
        if (self==DaySpecifics.zerohour)
        { return "00"}
        if (self==DaySpecifics.twohour)
        { return "02"}
        if (self==DaySpecifics.fourhour)
        { return "04"}
        if (self==DaySpecifics.sixhour)
        { return "06"}
        if (self==DaySpecifics.eighthour)
        { return "08"}
        if (self==DaySpecifics.tenhour)
        { return "10"}
        if (self==DaySpecifics.twelvehour)
        { return "12"}
        if (self==DaySpecifics.fourteenhour)
        { return "14"}
        if (self==DaySpecifics.sixteenhour)
        { return "16"}
        if (self==DaySpecifics.eighteenhour)
        { return "18"}
        if (self==DaySpecifics.twentyhour)
        { return "20"}
        if (self==DaySpecifics.twentytwohour)
        { return "22"}
        if (self==DaySpecifics.twentyfourhour)
        { return "24"}
        else
        {return String("\(self)".prefix(2)).capitalized}
    }
    var id: DaySpecifics {self}
    
}
 
struct DetailView: View {
    
    @State var pickerSelectedItem = 0
    @State var pickerSelectedTwoItem = 0
    @State var pickercombined = 0
    @State var days: [(Comb: Combined, carbonByDate: [(day:DaySpecifics, carbon:Int)])] =
           [                (
            Combined.dayall,
                    
                        [
                            (DaySpecifics.twohour, 10),
                            (DaySpecifics.fourhour, 10),
                            (DaySpecifics.sixhour, 10),
                            (DaySpecifics.eighthour, 10),
                            (DaySpecifics.tenhour, 50),
                            (DaySpecifics.twelvehour, 60),
                            (DaySpecifics.fourteenhour, 70),
                            (DaySpecifics.sixteenhour, 70),
                            (DaySpecifics.eighteenhour, 70),
                            (DaySpecifics.twentyhour, 70),
                            (DaySpecifics.twentytwohour, 70),
                            (DaySpecifics.twentyfourhour, 70),
                        ]
                ),
                
                (
                    Combined.daycar,
                  
                        [
                            (DaySpecifics.twohour, 20),
                            (DaySpecifics.fourhour, 20),
                            (DaySpecifics.sixhour, 20),
                            (DaySpecifics.eighthour, 20),
                            (DaySpecifics.tenhour, 50),
                            (DaySpecifics.twelvehour, 60),
                            (DaySpecifics.fourteenhour, 70),
                            (DaySpecifics.sixteenhour, 70),
                            (DaySpecifics.eighteenhour, 70),
                            (DaySpecifics.twentyhour, 70),
                            (DaySpecifics.twentytwohour, 70),
                            (DaySpecifics.twentyfourhour, 70),
 
                        ]
                ),
                (
                    Combined.daywalk,
                  
                        [
                            (DaySpecifics.twohour, 30),
                            (DaySpecifics.fourhour, 40),
                            (DaySpecifics.sixhour, 30),
                            (DaySpecifics.eighthour, 40),
                            (DaySpecifics.tenhour, 50),
                            (DaySpecifics.twelvehour, 60),
                            (DaySpecifics.fourteenhour, 70),
                            (DaySpecifics.sixteenhour, 70),
                            (DaySpecifics.eighteenhour, 70),
                            (DaySpecifics.twentyhour, 70),
                            (DaySpecifics.twentytwohour, 70),
                            (DaySpecifics.twentyfourhour, 70),
 
                        ]
                ),
//                (
//                    DataParts.month,
//
//                        [
//                            (DaySpecifics.january, 110),
//                            (DaySpecifics.febuary, 120),
//                            (DaySpecifics.march, 130),
//                            (DaySpecifics.april, 110),
//                            (DaySpecifics.may, 110),
//                            (DaySpecifics.june, 120),
//                            (DaySpecifics.july, 130),
//                            (DaySpecifics.august, 110),
//                            (DaySpecifics.september, 110),
//                            (DaySpecifics.october, 120),
//                            (DaySpecifics.november, 130),
//                            (DaySpecifics.december, 110),
//
//
//                        ]
//                ),
//
//                (
//                    DataParts.year,
//
//                        [
//                            (DaySpecifics.fourteen, 110),
//                            (DaySpecifics.fifteen, 110),
//                            (DaySpecifics.sixteen, 110),
//                            (DaySpecifics.seventeen, 110),
//                            (DaySpecifics.eighteen, 110),
//                            (DaySpecifics.nineteen, 120),
//                            (DaySpecifics.twenty, 130),
//
//                        ]
//                ),
////
//
        ]
    
    var body: some View {
        ZStack {
            Color("background").edgesIgnoringSafeArea(.all)
            
            VStack {
                Divider()
                                      
                Text("Hello, Alter Eco-er")
                .foregroundColor(Color("title_colour"))
                .font(.largeTitle)
                
                Picker(selection: $pickerSelectedItem.animation(), label: Text("")) {
          
                    Text(DataParts.day.name).tag(DataParts.day.rawValue)
                    Text(DataParts.week.name).tag(DataParts.week.rawValue)
                    Text(DataParts.month.name).tag(DataParts.month.rawValue)
                    Text(DataParts.year.name).tag(DataParts.year.rawValue)
                    
                }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 24)
                    .animation(.default)
                
              HStack (spacing: 5) {
                
                if (pickerSelectedItem==DataParts.day.rawValue) {
                    
                    if (pickerSelectedTwoItem == Transport.all.rawValue) {
                      
                        ForEach(0..<self.days[Combined.dayall.rawValue].carbonByDate.count, id: \.self) { i in
                           BarViewLong(
                            
                            value: self.days[Combined.dayall.rawValue].carbonByDate[i].carbon,
                            label: self.days[Combined.dayall.rawValue].carbonByDate[i].day.shortName
                                
                            )}
                    }
                    if (pickerSelectedTwoItem == Transport.car.rawValue) {
                        
                        ForEach(0..<self.days[Combined.daycar.rawValue].carbonByDate.count, id: \.self) { i in
                            BarViewLong(
                            value: self.days[Combined.daycar.rawValue].carbonByDate[i].carbon,
                            label: self.days[Combined.daycar.rawValue].carbonByDate[i].day.shortName
                                
                            )}
                    }
                    if (pickerSelectedTwoItem == Transport.walk.rawValue) {
                        
                        ForEach(0..<self.days[Combined.daywalk.rawValue].carbonByDate.count, id: \.self) { i in
                           BarViewLong(
                            value: self.days[Combined.daywalk.rawValue].carbonByDate[i].carbon,
                            label: self.days[Combined.daywalk.rawValue].carbonByDate[i].day.shortName
                                
                            )}
                    }
                }
                    
//                    if (pickerSelectedTwoItem == Transport.all.rawValue) {
//                        ForEach(0..<self.days[Combined.dayall.rawValue].carbonByDate.count, id: \.self) { i in
//                           BarViewLong(
//                                value: self.days[self.pickercombined].carbonByDate[i].carbon,
//                                label: self.days[self.pickercombined].carbonByDate[i].day.shortName
//
//                            )}
                 
                else
                {
                ForEach(0..<self.days[pickercombined].carbonByDate.count, id: \.self)
                  { i in
                   
                     
                     BarView(
                         value: self.days[self.pickercombined].carbonByDate[i].carbon,
                         label: self.days[self.pickercombined].carbonByDate[i].day.shortName
                         
                     )}
                }
                
              }
                
              .padding(.top, 24)
               .animation(.default)
                
                Picker(selection: $pickerSelectedTwoItem.animation(), label: Image("")) {
                    
                                               
                Image("all").tag(Transport.all.rawValue)
                Image("car2")
                    .resizable()
                    .frame(width: 1.0, height: 1.0)
                .tag(Transport.car.rawValue)
                    
                
                    
                Image("walk2").tag(Transport.walk.rawValue)
                Image("train2").tag(Transport.tube.rawValue)
                
 
                  }.pickerStyle(SegmentedPickerStyle())
                 .padding(.horizontal, CGFloat(140))
               .animation(.default)
                                      
            
                
            }//vs
        }//zs
        
    }
}
 
 
struct BarView:  View {
    
    var value: Int
    var label: String
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Capsule().frame(width: 30, height: CGFloat(200))
                    .foregroundColor(Color("app_background"))
                Rectangle().frame(width: 47, height: CGFloat(value))
                    .foregroundColor(Color("graphBars"))
            }
            Text(label)
                .padding(.top,CGFloat(8))
        }
    }
}
 
struct BarViewLong:  View {
    
    var value: Int
    var label: String
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Capsule().frame(width: 26, height: CGFloat(200))
                    .foregroundColor(Color("app_background"))
                Rectangle().frame(width: 26, height: CGFloat(value))
                    .foregroundColor(Color("graphBars"))
            }
            Text(label)
                .padding(.top,CGFloat(8))
      
        }
    }
}
 
struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView()
    }
}
 
 
 
/*
struct DayDataPoint: Identifiable {
    let id = UUID()
    let transportmode: String
    var value: CGFloat
}
 
let appDelegate = UIApplication.shared.delegate as! AppDelegate
 
//let dayInfo = ["Walking": 1,"Running": 2,"Car": 3,"Bike": 4,"Unknown": 5]
 
struct DetailView: View {
//transport mode and value to be pulled from the database!
//if the number of transport modes changes then the HStack below needs to change
    static var data: [DayDataPoint] = [
        .init(transportmode: "Walking", value: CGFloat(appDelegate.retrieve_database(query_motion_type: "walking", query_date: "06/02/2020")) ),
    .init(transportmode: "Running", value: CGFloat(appDelegate.retrieve_database(query_motion_type: "running", query_date: "06/02/2020"))),
    .init(transportmode: "Car", value: CGFloat(appDelegate.retrieve_database(query_motion_type: "automotive", query_date: "06/02/2020"))),
    .init(transportmode: "Bike", value: 0.7),
    .init(transportmode: "Bike", value: 0.7),
     ]
    
    static let eveningData: [DayDataPoint] = [
        .init(transportmode: "One", value: 0.9),
        .init(transportmode: "Two", value: 0.4),
        .init(transportmode: "Three", value: 0.3),
        .init(transportmode: "Four", value: 0.3),
        .init(transportmode: "x", value: 0.3),
 
    ]
    static let afternoonData: [DayDataPoint] = [
             .init(transportmode: "Walking", value: 0.6),
             .init(transportmode: "Running", value: 0.4),
             .init(transportmode: "Car", value: 0.8),
             .init(transportmode: "Bike", value: 0.7),
             .init(transportmode: "Unknown", value: 0.4),
      ]
    
    static let datapoints_norm: [DayDataPoint] = normalise_data(datapoints: data)
    
    @State var dataSet = [
        datapoints_norm, afternoonData, eveningData
    ]
    
    var spacing: CGFloat = 24
    
    @State var selectedTime = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("appbackground")
                    .edgesIgnoringSafeArea(.all)
                
                VStack (spacing: 16) {
                   
                    HStack {
                        Divider()
                       
                        Text("Hello, Alter Eco-er")
                        .foregroundColor(Color("title_colour"))
                        .font(.largeTitle)
                    }
                    Spacer()
                    
                    Text("Carbon Consumed")
                        .font(.system(size: 32))
                        .fontWeight(.regular)
                        .foregroundColor(Color("graphBars"))
                        .padding(.bottom, 0)
                    
                    Picker(selection: self.$selectedTime, label: Text("XXX")) {
                        Text("Daily").tag(0)
                        Text("Weekly").tag(1)
                        Text("Monthly").tag(2)
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    HStack (spacing: self.spacing) {
                        // WARNING: Don't use a ForEach here, it doesn't animate.
                        StackedBarView(dataPoint: self.dataSet[self.selectedTime][0], width: (geometry.size.width - 6 * self.spacing) / 5)
                        StackedBarView(dataPoint: self.dataSet[self.selectedTime][1], width: (geometry.size.width - 6 * self.spacing) / 5)
                        StackedBarView(dataPoint: self.dataSet[self.selectedTime][2], width: (geometry.size.width - 6 * self.spacing) / 5)
                        StackedBarView(dataPoint: self.dataSet[self.selectedTime][3], width: (geometry.size.width - 6 * self.spacing) / 5)
                        StackedBarView(dataPoint: self.dataSet[self.selectedTime][4], width: (geometry.size.width - 6 * self.spacing) / 5)
                    }.animation(.default)
                    Spacer()
                }
            }
        }
    }
}
 
 
func normalise_data(datapoints: [DayDataPoint]) -> [DayDataPoint] {
    var max = CGFloat(0)
    for element in datapoints {
        let current_max = element.value
        if current_max > max {
            max = current_max
        }
    }
    
    var element_norm: DayDataPoint
    var datapoints_norm: [DayDataPoint] = []
    
    for element in datapoints {
        element_norm = element
        element_norm.value = element.value / (max * 1.1)
        datapoints_norm.append(element_norm)
    }
    
    return datapoints_norm
}
 
struct StackedBarView: View {
    var dataPoint: DayDataPoint
    var width: CGFloat
    var body: some View {
        VStack {
        
            ZStack (alignment: .bottom) {
                Capsule()
                    .frame(width: width, height: 200)
                    .overlay(RoundedRectangle(cornerRadius: 20).fill(Color("graphBarBackground")))
                Capsule()
                    .frame(width: width, height: dataPoint.value * 200)
                    .overlay(RoundedRectangle(cornerRadius: 20).fill(Color("graphBars")))
                
            }.padding(.bottom, 8)
            Text(dataPoint.transportmode)
                .font(.system(size: 14))
        }
        
    }
}
 
extension AnyTransition {
    static var moveAndFade: AnyTransition {
        let insertion = AnyTransition.move(edge: .trailing)
            .combined(with: .opacity)
        let removal = AnyTransition.scale
            .combined(with: .opacity)
        return .asymmetric(insertion: insertion, removal: removal)
    }
}
*/
