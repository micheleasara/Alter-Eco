import SwiftUI

public struct GameView: View {
    @State private var editMode = false
    @State private var selectedObjectName: String?
    @State private var isSmogOn: Bool = false

    public var body: some View {
        Group {
            ZStack {
                Text("Loading 3D scene...")
                SceneKitView(editMode: $editMode,
                         selectedObjectName: $selectedObjectName,
                         isSmogOn: $isSmogOn)
                OptionMenu(editMode: $editMode, selectedObjectName: $selectedObjectName)
                // DEBUG ONLY:
    //                    Button(action: { self.isSmogOn.toggle() }) {
    //                        Text("Toggle smog")
    //                    }
            }
            
            if selectedObjectName != nil {
                Text("Double tap where you would like to place the item.").bold()
            }
        }
    }
}

public struct SceneKitView: UIViewControllerRepresentable {
    @Binding var editMode: Bool
    @Binding var selectedObjectName: String?
    @Binding var isSmogOn: Bool
    @Environment(\.DBMS) var DBMS: DBManager
    
    public typealias UIViewControllerType = GameViewController

    public func makeUIViewController(context: Context) -> GameViewController {
        return GameViewController(mainScenePath: "MainScene.scn", DBMS: DBMS)
    }
    
    public func updateUIViewController(_ uiViewController: GameViewController, context: Context) {
        uiViewController.isEditModeOn(editMode)
        if let name = selectedObjectName, let url = Bundle.main.url(forResource: name, withExtension: "scn") {
            uiViewController.letUserPlaceNode(withName: name, fromSceneFile: url, nodePlacedCallback: { self.selectedObjectName = nil })
        }
        uiViewController.isSmogOn(isSmogOn)
    }
}

public struct OptionMenu: View {
    @Binding var editMode: Bool
    @Binding var selectedObjectName: String?
    
    @State private var showingObjectList = false
    @State private var showingConfirmation = false
    @State private var selectedObjectIdx: Int = 0
    @EnvironmentObject private var isGameOpen: Observable<Bool>
    
    private let availableObjects: [(displayedName: String, internalName: String, points: Int)] =
        [("Apple tree", "appleTree", 500), ("Pine", "pine", 350), ("Rounded tree", "roundedTree", 300)]
    
    public var body: some View {
        HStack(alignment: .top) {
            Group {
                if showingObjectList {
                    objectListPopup
                } else {
                    shopButton
                }
            }
            .padding(.leading).padding(.top)
            
            if !showingObjectList {
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
                self.isGameOpen.rawValue = false
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
                self.editMode.toggle()
            }) {
                HStack {
                    Text(self.editMode ? "Done" : "Edit")
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
                self.showingObjectList = true
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
    
    private var objectListPopup: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                   objectList.padding()
                }
                
                Spacer()
                Button(action: { self.showingObjectList = false }) {
                    Image(systemName: "xmark.circle")
                }.foregroundColor(Color.white).padding()
            }
            .background(Color.yellow)
            .cornerRadius(20)
            .padding()
            Spacer()
        }
    }
    
    private var objectList: some View {
        ForEach(0..<availableObjects.count, id: \.self) { i in
            VStack(alignment: .leading, spacing: 1) {
                HStack() {
                    Text(self.availableObjects[i].displayedName).bold().foregroundColor(Color.black)
                    Button(action: {
                        self.selectedObjectIdx = i
                        self.showingConfirmation = true
                    }) { Image(systemName: "plus.square")
                    }.foregroundColor(Color.black)
                }
                Text(String(format: "%d points", self.availableObjects[i].points)).italic().foregroundColor(Color.init(red: 0.3, green: 0.3, blue: 0.3))
            }
        }.alert(isPresented: $showingConfirmation) {
            let objectInfo = self.availableObjects[self.selectedObjectIdx]
            return Alert(title: Text("Confirm"),
                  message: Text(String(format: "Are you sure you want to spend %d points for one %@?", objectInfo.points, objectInfo.displayedName)),
                  primaryButton: .default(Text("Yes"), action: { self.selectedObjectName = objectInfo.internalName }), secondaryButton: .cancel(Text("No")))
        }
    }
}

struct OptionMenu_Previews: PreviewProvider {
    static var previews: some View {
        OptionMenu(editMode: .constant(false), selectedObjectName: .constant(nil))
    }
}
