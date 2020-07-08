import SwiftUI

struct FoodListView: View {
    @Binding var isVisible: Bool
    @ObservedObject var model: FoodListViewModel
    @State private var continuePressed = false
    
    var body: some View {
        return Group {
            if continuePressed && isVisible {
                endScreen
            } else if isVisible {
                NavigationView() {
                    VStack {
                        itemsList
                        
                        HStack {
                            Button(action: {
                                self.isVisible = false
                            }, label: {
                                Text("Cancel")
                            }).padding(.horizontal)
                            
                            Spacer()
                            
                            if model.count > 0 {
                                Button(action: {
                                    self.continuePressed = true
                                }, label: {
                                    Text("Continue")
                                }).padding(.horizontal)
                            }
                        }
                    }.navigationBarTitle(Text("My groceries"), displayMode: .inline)
                }
            }
        }
    }
    
    private var endScreen: some View {
        // determine emission format to display and a car equivalent
        var carbonValue = model.totalCarbon.value
        var carbonUnit = model.totalCarbon.unit
        var carEquivalentStr = ""
        
        if carbonUnit == UnitMass.kilograms {
            var carEquivalent = model.totalCarbon.value / CARBON_UNIT_CAR
            var carUnit = UnitLength.kilometers
            
            // show up to 1 decimal place (only if needed!)
            carEquivalent = (carEquivalent / 0.1).rounded() * 0.1
            if carEquivalent < 1 {
                carUnit = .meters
                carEquivalent = Measurement(value: carEquivalent, unit: UnitLength.kilometers).converted(to: .meters).value
            }
            // do not display an equivalence for 0 m
            if carEquivalent > 0 {
                carEquivalentStr = String(format: "%g %@", carEquivalent, carUnit.symbol)
            }
            
            if carbonValue < 1 {
                carbonUnit = .grams
                carbonValue = model.totalCarbon.converted(to: .grams).value
            }
        }
        carbonValue = (carbonValue / 0.01).rounded() * 0.01
        let carbonStr = String(format: "%g %@", carbonValue, carbonUnit.symbol)
        
        return getEndScreen(emission: carbonStr, carEquivalent: carEquivalentStr)
    }
    
    private func getEndScreen(emission: String, carEquivalent: String) -> some View {
        VStack() {
            VStack {
                Text("Today you").font(.title)
                Text("have emitted").font(.title)
                
                Text("\(emission)")
                    .font(.largeTitle).bold()
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.blue, lineWidth: 5)).padding()
                
                Text("with your groceries").font(.title)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            
            if carEquivalent != "" {
                Spacer()
                Text("The equivalent of " + carEquivalent + " with a car 🚗").italic()
            }
            Spacer()
            
            HStack {
                Spacer()
                Button(action: {
                    self.isVisible = false
                }, label: {
                    Text("Ok")
                }).padding(.horizontal)
            }
        }
    }
    
    private var itemsList: some View {
        List {
            if !model.categorised.isEmpty {
                sectionForFoodsInDB(header: "Retrieved items: tap to edit", foods: model.categorised, remover: model.removeFromCategorised(at:))
            }
            
            if !model.uncategorised.isEmpty {
                sectionForFoodsInDB(header: "Incomplete information: tap to complete", foods: model.uncategorised, remover: model.removeFromUncategorised(at:))
            }
            
            if !model.notInDatabase.isEmpty {
                Section(header: Text("Items not found: tap to add").bold()) {
                    ForEach(model.notInDatabase, id: \.self) { food in
                        NavigationLink(destination: Text("hello")) {
                            Text(food.barcode)
                        }
                    }.onDelete(perform: {
                        $0.forEach { i in
                            self.model.removeFromNotInDatabase(at: i) }
                    })
                }
            }
        }.listStyle(GroupedListStyle())
    }
    
    private func sectionForFoodsInDB(header: String,
                                     foods: [Food],
                                     remover: @escaping (Int) -> Void) -> some View {
        Section(header: Text(header).bold()) {
            ForEach(foods, id: \.self) { food in
                NavigationLink(destination: Text(self.getCarbonLabel(food: food))) {
                    self.boxWithInfo(fromFood: food)
                }
            }.onDelete(perform: { $0.forEach { i in remover(i) } })
        }
    }
    
    private func getCarbonLabel(food: Food) -> String {
        guard let measure = model.getCarbon(forFood: food) else {
            return "Could not determine carbon value"
        }
        return "Carbon: \(measure.value) \(measure.unit.symbol)"
    }
    
    private func boxWithInfo(fromFood food: Food) -> some View {
        let type = food.types?.first ?? ""
        var image: UIImage? = nil
        if let data = food.image {
            image = UIImage(data: data)
        }
        
        return HStack {
            if image != nil {
                Image(uiImage: image!).resizable().aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
            }
            
            VStack(alignment:.leading) {
                Text(food.name ?? "Product name not available")
                if food.quantity == nil {
                    Text("100 g")
                        .foregroundColor(Color.orange)
                        .padding(.top)
                } else {
                    // display value to 1 decimal place and only if needed
                    Text(String(format: "%g %@", (food.quantity!.value / 0.1).rounded() * 0.1, food.quantity!.unit.symbol))
                        .padding(.top)
                }
                
                if !type.isEmpty {
                    Text(type).padding(.top)

                }
            }
        }.frame(height: 100)
    }
}

struct FoodListView_Previews: PreviewProvider {
    static var previews: some View {
        let foods = [Food(barcode: "1234567", name: "Chocolate brownies TESCO", quantity: Food.Quantity(value: 200, unit: "g"), types: ["sweet snack"]),
                     Food(barcode: "4342347", name: "WR Premium Chicken", quantity: Food.Quantity(value: 250, unit: "g"), types: ["chicken"]),
            Food(barcode: "98238237", name: "Frozen Chickpeas TESCO", quantity: Food.Quantity(value: 500, unit: "g"), types: []),
            Food(barcode: "98238237", name: "LoveChoc Doughnuts Special Edition", types: ["sweet snack"])
        ]
        
        let notFound = [Food(barcode: "8456743")]
        
        return FoodListView(isVisible: .constant(true), model: FoodListViewModel(foods: foods, notFound: notFound ))
    }
}
