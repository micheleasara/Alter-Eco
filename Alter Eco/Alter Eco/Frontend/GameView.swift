import SwiftUI

/// Represents the view of the virtual forest.
public struct GameView: View {
    @EnvironmentObject private var viewModel: GameViewModel

    public var body: some View {
        Group {
            ZStack {
                Text("Loading 3D scene...")
                SceneKitView(itemToAdd: $viewModel.itemToAdd, isSmogOn: $viewModel.isSmogOn, isEditModeOn: $viewModel.isEditModeOn)
                GameOverlayView()
            }
            
            if viewModel.itemToAdd != nil {
                Text("Double tap where you would like to place the item.").bold()
            }
        }
    }
}

/// Bridges between SwiftUI and SceneKit.
public struct SceneKitView: UIViewControllerRepresentable {
    @Environment(\.DBMS) private var DBMS
    @EnvironmentObject private var viewModel: GameViewModel
    // using Binding instead of the EnvironmentObject as it forces
    // updateUIViewController to be called with the new values being already set
    @Binding var itemToAdd: ShopItem?
    @Binding var isSmogOn: Bool
    @Binding var isEditModeOn: Bool
    
    public typealias UIViewControllerType = GameViewController

    public func makeUIViewController(context: Context) -> GameViewController {
        return GameViewController(mainScenePath: "MainScene.scn", DBMS: DBMS)
    }
    
    public func updateUIViewController(_ uiViewController: GameViewController, context: Context) {
        uiViewController.isEditModeOn(isEditModeOn)
        if let item = itemToAdd {
            uiViewController.letUserPlaceNode(fromShopItem: item, nodePlacedCallback: {
                self.itemToAdd = nil
                self.viewModel.refreshCurrentPoints()
            })
        }
        uiViewController.isSmogOn(isSmogOn)
    }
}

/// Represents the view overlaying the 3D scene.
public struct GameOverlayView: View {
    @EnvironmentObject private var viewModel: GameViewModel
    @State private var showingItems = false
    @State private var showingConfirmation = false
    @State private var selectedItemIdx: Int = 0
    
    private let availableItems: [ShopItem] =
        [ShopItem(displayedName: "Apple tree", internalName: "appleTree", cost: 500, imageName: "appleTree"),
         ShopItem(displayedName: "Pine", internalName: "pine", cost: 350, imageName: "pineTree"),
         ShopItem(displayedName: "Rounded tree", internalName: "roundedTree", cost: 300, imageName: "roundedTree")]
    
    public var body: some View {
        HStack(alignment: .top) {
            Group {
                if showingItems {
                    itemsListPopup
                } else if !viewModel.isEditModeOn {
                    shopButton
                }
            }
            .padding(.leading).padding(.top)
            
            if !showingItems {
                Spacer()
                editModeButton.padding(.top)
            }
            Spacer()
            closeGameButton
                .padding(.trailing).padding(.top)
        }
    }
    
    private var closeGameButton: some View {
        VStack {
            Button(action: {
                self.viewModel.isGameOn = false
            }) {
                Image(systemName: "xmark")
            }.foregroundColor(Color.white).padding()
        }
        .foregroundColor(.white)
        .background(Color.yellow)
        .cornerRadius(40)

    }
    
    private var editModeButton: some View {
        VStack {
            Button(action: {
                self.viewModel.isEditModeOn.toggle()
            }) {
                HStack {
                    Text(self.viewModel.isEditModeOn ? "Done" : "Edit")
                        .bold()
                        .font(.body)
                        .foregroundColor(.white)
                    Image(systemName: "hammer.fill")
                }
                .padding(10)
                .foregroundColor(.white)
                .background(Color.yellow)
                .cornerRadius(40)
            }
            Spacer()
        }
    }
    
    private var shopButton: some View {
        VStack(alignment: .leading) {
            Button(action: {
                self.showingItems = true
            }) {
                HStack {
                    Text("Shop")
                        .bold()
                        .font(.body)
                        .foregroundColor(.white)
                    Image(systemName: "bag.fill.badge.plus")
                }
                .padding(10)
                .foregroundColor(.white)
                .background(Color.yellow)
                .cornerRadius(40)
            }
                Spacer()
        }
    }
    
    private var itemsListPopup: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    itemsList
                    Text(String(format: "Available points: %.0f", viewModel.currentPoints)).padding(.top)
                }
                
                Spacer()
                Button(action: { self.showingItems = false }) {
                    Image(systemName: "xmark.circle")
                }.foregroundColor(Color.white)
            }
            .padding()
            .background(Color.yellow)
            .cornerRadius(20)
            Spacer()
        }
    }
    
    private var itemsList: some View {
        ForEach(0..<availableItems.count, id: \.self) { i in
            HStack() {
                Image(self.availableItems[i].imageName).resizable().frame(width: 30, height: 35).border(Color.black)
                
                VStack(alignment: .leading, spacing: 1) {
                    HStack() {
                        Text(self.availableItems[i].displayedName).bold().foregroundColor(Color.black)
                        Button(action: {
                            self.selectedItemIdx = i
                            self.showingConfirmation = true
                            self.viewModel.refreshCurrentPoints()
                        }) { Image(systemName: "plus.square")
                        }.foregroundColor(Color.black)
                    }
                    
                    Text(String(format: "%.0f points", self.availableItems[i].cost)).italic().foregroundColor(Color.init(red: 0.3, green: 0.3, blue: 0.3))
                }
            }
        }.alert(isPresented: $showingConfirmation) {
            let shopItem = self.availableItems[self.selectedItemIdx]
            if viewModel.currentPoints >= shopItem.cost {
                return getConfirmationAlert(item: shopItem)
            } else {
                return notEnoughPointsAlert
            }
        }
    }
    
    private func getConfirmationAlert(item: ShopItem) -> Alert {
        Alert(title: Text("Confirm"),
              message: Text(String(format: "Are you sure you want to spend %.0f points for one %@?", item.cost, item.displayedName)),
              primaryButton: .default(Text("Yes"), action: {
                print("Tapped yes")
                self.viewModel.itemToAdd = item }),
              secondaryButton: .cancel(Text("No")))
    }
    
    private var notEnoughPointsAlert: Alert {
        Alert(title: Text("Not enough points"),
              message: Text("It seems you don't have enough points yet. Keep using Alter Eco and come back when you do!"), dismissButton: .default(Text("OK")))
    }
}

struct OptionMenu_Previews: PreviewProvider {
    static var previews: some View {
        GameOverlayView().environmentObject(GameViewModel(DBMS: CoreDataManager()))
    }
}
