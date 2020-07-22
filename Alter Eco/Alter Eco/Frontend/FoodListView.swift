import SwiftUI

struct FoodListView: View {
    @Binding var isVisible: Bool
    @EnvironmentObject var viewModel: FoodListViewModel
    @State private var continuePressed = false
    
    var body: some View {
        return Group {
            if continuePressed && isVisible {
                endScreen.onAppear()
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
                            
                            if !viewModel.productsWithTypes.isEmpty {
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
        var carbonValue = viewModel.totalCarbon.value
        var carbonUnit = viewModel.totalCarbon.unit
        var carEquivalentStr = ""
        
        if carbonUnit == UnitMass.kilograms {
            var carEquivalent = viewModel.totalCarbon.value / CARBON_UNIT_CAR
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
                carbonValue = viewModel.totalCarbon.converted(to: .grams).value
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
                    self.viewModel.save()
                }, label: {
                    Text("Ok").font(.body).bold()
                }).padding(.horizontal)
            }
        }
    }
    
    private var itemsList: some View {
        List {
            if !viewModel.productsWithTypes.isEmpty {
                sectionForFoodsInDB(header: "Retrieved items: tap to edit", foods: viewModel.productsWithTypes, remover: viewModel.removeProductWithType(at:))
            }
            
            if !viewModel.typelessProducts.isEmpty {
                sectionForFoodsInDB(header: "Incomplete information: tap to complete", foods: viewModel.typelessProducts, remover: viewModel.removeTypeless(at:))
            }
                        
            if !viewModel.productsNotInDB.isEmpty {
                Section(header: Text("Items not found: tap to add").bold()) {
                    ForEach(viewModel.productsNotInDB, id: \.self) { food in
                        NavigationLink(destination: self.addProduct) {
                            Text(food.barcode)
                        }
                    }.onDelete(perform: {
                        $0.forEach { i in
                            self.viewModel.removeProductNotInDB(at: i) }
                    })
                }
            }
        }.listStyle(GroupedListStyle())
    }
    
    private var addProduct: some View {
        VStack (alignment: .leading){
            Text("This feature is not yet supported. In the meantime, please add this product to the database via the official OpenFoodFacts app.").padding()
            
            Button(action: {
                if let url = URL(string: "itms-apps://itunes.apple.com/app/id588797948"),
                UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                }) { Text("Open in AppStore")}.padding()
            
            Text("Make sure to add the categories, as that is what we use to compute the carbon footprint!").padding()
        }
    }
    
    private func sectionForFoodsInDB(header: String,
                                     foods: [Food],
                                     remover: @escaping (Int) -> Void) -> some View {
        Section(header: Text(header).bold()) {
            ForEach(foods, id: \.self) { food in
                NavigationLink(destination: FoodInfoView(food: food, parentModel: self.viewModel)) {
                    FoodSummaryBox(food: food)
                }
            }.onDelete(perform: { $0.forEach { i in remover(i) } })
        }
    }
}

public struct FoodInfoView: View {
    @ObservedObject var food: Food
    @ObservedObject var parentModel: FoodListViewModel
    @ObservedObject private var quantity = NumbersFilter(maxDigits: 4)
    @State private var editingQuantity = false
    @State private var editingType = false
    @State private var selectedType = ""
    
    public var body: some View {
        ScrollView {
            HStack(alignment: .top) {
                if food.image != nil {
                    Image(uiImage: UIImage(data: food.image!)!)
                        .resizable().scaledToFit().frame(width: 150, height: 150).padding()
                }
                
                infoLabels
            }
        }
    }

    private var infoLabels: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Barcode")
                .bold()
                .padding(.top)
            Text(food.barcode)
            
            quantityLabel.padding(.top)

            Text("Name").bold().padding(.top)
            Text((food.name ?? ""))
            
            foodTypeLabel.padding(.top)
                        
            Text("Carbon equivalent").bold().padding(.top)
            Text(getCarbonLabel(food: food))
        }
    }

    private var foodTypeLabel: some View {
        var list = Array(FoodToCarbonConverter.foodTypesInfo.keys)
        // only display this food's types if they are complete
        // that is, they include every possible type
        if let types = food.types, types.count >= list.count {
            list = types
        }
        
        return VStack(alignment: .leading, spacing: 3) {
            Text("Type").bold()
            HStack(alignment: .center) {
                Text((food.types?.first ?? "Unknown"))
                Button(action: { self.editingType = true }) {
                    Image(systemName: "pencil") }

            }
        }
        .sheet(isPresented: $editingType, onDismiss: {
            if !self.selectedType.isEmpty {
                self.food.setAsMostLikelyType(self.selectedType)
                // product has been given a type, so move it in the
                // right section of the list
                self.parentModel.update()
            }
        }) {
            SearchableList(list: list,
                           selected: self.$selectedType)
        }
    }

    private var quantityLabel: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Quantity").bold()
            
            if editingQuantity {
                HStack {
                    TextField(String(food.quantity?.value ?? 100), text: $quantity.value)
                    .keyboardType(.numberPad)
                    .padding(3).border(Color.primary)
                    
                    Text(self.food.quantity?.unit.symbol ?? UnitMass.grams.symbol)
                    
                    Button(action: {
                        let numericVal = Double(self.quantity.value)
                        self.food.quantity = Food.Quantity(
                            value: (numericVal ?? self.food.quantity?.value) ?? 100,
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
        if food.quantity == nil { // if no info, default to 100 g
            let quantity = parentModel.defaultQuantity
            product = Food(barcode: food.barcode, name: food.name, quantity: quantity, types: food.types, image: food.image)
        }
        guard var measure = parentModel.getCarbon(forFood: product) else {
            return "Unknown"
        }
        
        if measure.value < 1 {
            measure.convert(to: UnitMass.grams)
        }
        return String(format: "%.1f %@", measure.value, measure.unit.symbol)
    }
}

public struct FoodSummaryBox: View {
    @ObservedObject var food: Food
    
    public var body: some View {
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

struct FoodListView_Previews: PreviewProvider {
    static var previews: some View {
        let foods = [
            Food(barcode: "1234567", name: "Chocolate brownies TESCO", quantity: Food.Quantity(value: 200, unit: "g"), types: ["sweet snack"]),
                     Food(barcode: "4342347", name: "WR Premium Chicken", quantity: Food.Quantity(value: 250, unit: "g"), types: ["chicken", "egg"]),
            Food(barcode: "98238237", name: "Frozen Chickpeas TESCO", quantity: Food.Quantity(value: 500, unit: "g"), types: nil),
            Food(barcode: "98238237", name: "LoveChoc Doughnuts Special Edition", types: ["sweet snack"])
        ]
        
        let notFound = [Food(barcode: "8456743")]
        
        return FoodListView(isVisible: .constant(true)).environmentObject(FoodListViewModel(foods: foods, notFound: notFound, DBMS: CoreDataManager() ))
    }
}
