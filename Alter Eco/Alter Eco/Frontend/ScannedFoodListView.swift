import SwiftUI

struct ScannedFoodListView: View {
    @Binding var isVisible: Bool
    @State private var foods = [["Baguette", "Bread", "120g"],
    ["Premium free range chicken", "Chicken", "250g"],
    ["Nachos", "Salty snack", "175g"]]
    @State private var incompleteFoods = ["Olive oil", "Walkers"]
    
    var body: some View {
        NavigationView() {
            VStack {
                List {
                    Section(header: Text("Retrieved items: tap to edit").bold()) {
                        ForEach(foods, id: \.self) { food in
                            NavigationLink(destination: Text("hello")) {
                                VStack(alignment:.leading) {
                                    Text(food[0])
                                    Text(food[2])
                                    Text(food[1])
                                }
                            }
                        }.onDelete(perform: delete)
                    }
                        
                    Section(header: Text("Incomplete information: tap to complete").bold()) {
                        ForEach(incompleteFoods, id: \.self) { food in
                            NavigationLink(destination: Text("hello")) {
                                Text(food)
                            }
                        }.onDelete(perform: delete)
                    }
                    
                    Section(header: Text("Items not found: tap to add").bold()) {
                        NavigationLink(destination: Text("hello")) {
                            Text("3086123499140")
                        }
                    }
                }
                //.listStyle(GroupedListStyle())
                Button(action: {
                    self.isVisible = false
                }, label: {
                    Text("Continue")
                })
            }.navigationBarTitle(Text("My groceries"))
            
        }
    }
    
    
    func delete(at offsets: IndexSet) {
        print(offsets)
    }
}
