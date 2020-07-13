import SwiftUI

struct FoodListView: View {
    @Binding var isVisible: Bool
    @ObservedObject var model: FoodListViewModel
    @Environment(\.DBMS) var DBMS
    @State private var continuePressed = false
    
    var body: some View {
        return Group {
            if continuePressed && isVisible {
                endScreen.onAppear() {
                    self.model.categorised.forEach{ try? self.DBMS.append(food: $0) }
                }
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
                NavigationLink(destination: FoodInfoView(food: food, parentModel: self.model)) {
                    self.boxWithInfo(fromFood: food)
                }
            }.onDelete(perform: { $0.forEach { i in remover(i) } })
        }
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
                    Text(food.quantity!.description)
                        .padding(.top)
                }
                
                if !type.isEmpty {
                    Text(type).padding(.top)

                }
            }
        }.frame(height: 100)
    }
}

public struct FoodInfoView: View {
    @ObservedObject var food: Food
    @ObservedObject var parentModel: FoodListViewModel
    @ObservedObject private var quantity = NumbersFilter()
    @State private var editingQuantity = false
    @State private var editingType = false
    @State private var selectedType = ""
    
    public var body: some View {
        ScrollView {
            HStack(alignment: .top) {
                if food.image != nil {
                    Image(uiImage: UIImage(data: food.image!)!)
                        .resizable().scaledToFit().frame(width: 150, height: 150)
                }
                
                info.padding(.trailing)
            }
        }
    }

    private var info: some View {
        VStack(alignment: .leading) {
            Text("Barcode")
                .bold()
                .padding(.top)
            Text(food.barcode).padding(.bottom)
            
            Text("Name").bold()
            Text((food.name ?? "")).padding(.bottom)
            
            foodTypeLabel
            
            quantityLabel
            
            Text("Carbon equivalent").bold().padding(.top)
            Text(getCarbonLabel(food: food))
        }
    }

    private var foodTypeLabel: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Type").bold()
            HStack(alignment: .center) {
                Text((food.types?.first ?? "Unknown"))
                Button(action: { self.editingType = true }) {
                    Image(systemName: "pencil") }

            }
        }
        .sheet(isPresented: $editingType, onDismiss: {
            self.food.setAsMostLikelyType(self.selectedType)
        }) {
            SearchableList(list: self.food.types ?? Array(FoodToCarbonConverter.foodTypesInfo.keys),
                           selected: self.$selectedType)
        }
    }

    private var quantityLabel: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Quantity").bold().padding(.top)
            
            if editingQuantity {
                HStack {
                    TextField(String(food.quantity?.value ?? 100), text: $quantity.value)
                    .keyboardType(.numberPad)
                    .padding(3).border(Color.primary)
                    
                    Text(self.food.quantity?.unit.symbol ?? UnitMass.grams.symbol)
                    
                    Button(action: {
                           self.food.quantity = Food.Quantity(
                            value: Double(self.quantity.value) ?? self.food.quantity?.value ?? 100,
                                unit: self.food.quantity?.unit ?? UnitMass.grams)
                            self.editingQuantity = false
                        
                            // dismiss keyboard
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }) {
                            Text("Done")
                        }
                        .padding(.trailing)
                        .transition(.move(edge: .trailing))
                        .animation(.default)
                }
                
            } else {
                HStack(alignment: .center) {
                    Text((food.quantity?.description ?? "100 g"))
                    Button(action: { self.editingQuantity = true }) {
                    Image(systemName: "pencil") }
                }
            }
        }
    }

    private func getCarbonLabel(food: Food) -> String {
        var product = food
        if food.quantity == nil {
            let quantity = Food.Quantity(value: 100, unit: UnitMass.grams)
            product = Food(barcode: food.barcode, name: food.name, quantity: quantity, types: food.types, image: food.image)
        }
        
        guard let measure = parentModel.getCarbon(forFood: product) else {
            return "Could not determine carbon value"
        }
        
        return String(format: "%.1f %@", measure.value, measure.unit.symbol)
    }

    /// An observable object which only allows numeric values.
    private class NumbersFilter: ObservableObject {
        @Published var value = "" {
            didSet {
                let filtered = value.filter { $0.isNumber }
                
                if value != filtered {
                    value = filtered
                }
            }
        }
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
