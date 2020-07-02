import SwiftUI

struct FoodListView: View {
    @Binding var isVisible: Bool
    @ObservedObject var model: FoodListViewModel
    private let carbonConverter = FoodToCarbonConverter()
    
    var body: some View {
        NavigationView() {
            VStack {
                List {
                    if !model.categorised.isEmpty {
                        sectionForFoodsInDB(header: "Retrieved items: tap to edit", foods: model.categorised)
                    }
                    
                    if !model.uncategorised.isEmpty {
                        sectionForFoodsInDB(header: "Incomplete information: tap to complete", foods: model.uncategorised)
                    }
                    
                    if !model.notInDatabase.isEmpty {
                        Section(header: Text("Items not found: tap to add").bold()) {
                            ForEach(model.notInDatabase, id: \.self) { food in
                                NavigationLink(destination: Text("hello")) {
                                    Text(food.barcode)
                                }
                            }.onDelete(perform: delete)
                        }
                    }
                }.listStyle(GroupedListStyle())

                HStack {
                    Button(action: {
                        self.isVisible = false
                    }, label: {
                        Text("Cancel")
                    }).padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: {
                        self.isVisible = false
                    }, label: {
                        Text("Continue")
                    }).padding(.horizontal)
                }
            }.navigationBarTitle(Text("My groceries"), displayMode: .inline)
        }.onDisappear() {
            // clean up model
            self.model.update(foods: [], notFound: [])
        }
    }
    
    private func sectionForFoodsInDB(header: String, foods: [Food]) -> some View {
        Section(header: Text(header).bold()) {
            ForEach(foods, id: \.self) { food in
                NavigationLink(destination: Text(self.getCarbonLabel(food: food))) {
                    self.boxWithInfo(fromFood: food)
                }
            }.onDelete(perform: delete)
        }
    }
    
    private func getCarbonLabel(food: Food) -> String {
        guard let carbon = carbonConverter.getCarbon(fromFood: food) else {
            return "Could not determine carbon"
        }
        return "Carbon: \(carbon) kg"
    }
    
    private func boxWithInfo(fromFood food: Food) -> some View {
        let category = food.categories?.first ?? ""
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
                
                if !category.isEmpty {
                    Text(category).padding(.top)

                }
            }
        }.frame(height: 100)
    }
    
    private func delete(at offsets: IndexSet) {
        print(offsets)
    }
}

struct FoodListView_Previews: PreviewProvider {
    static var previews: some View {
        let foods = [Food(barcode: "1234567", name: "Chocolate brownies TESCO", quantity: Food.Quantity(value: 200, unit: "g"), categories: ["sweet snack"]),
                     Food(barcode: "4342347", name: "WR Premium Chicken", quantity: Food.Quantity(value: 250, unit: "g"), categories: ["chicken"]),
            Food(barcode: "98238237", name: "Frozen Chickpeas TESCO", quantity: Food.Quantity(value: 500, unit: "g"), categories: []),
            Food(barcode: "98238237", name: "LoveChoc Doughnuts Special Edition", categories: ["sweet snack"])
        ]
        
        let notFound = [Food(barcode: "8456743")]
        
        return FoodListView(isVisible: .constant(true), model: FoodListViewModel(foods: foods, notFound: notFound ))
    }
}
