import SwiftUI

public struct SearchableList: View {
    public var list: [String]
    @Binding public var selected: String
    @State private var text: String = ""
    
    public var body: some View {
        let filtered = list.filter {
            self.text.isEmpty ? true : $0.contains(self.text.lowercased())
        }
        
        return VStack {
            searchBar
            
            List() {
                ForEach(0..<filtered.count, id: \.self) { i in
                    SearchableListItem(selection: self.$selected, text: filtered[i])
                }
            }
        
        }
    }
    
    private var searchBar: some View {
        HStack {
            TextField("Search ...", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                    }
                )
                .padding(.horizontal).padding(.top)
            
        }
    }
}


struct SearchableListItem: View {
    @Binding var selection: String
    let text: String
    
    var body: some View {
        GeometryReader { geo in
            Text(self.text)
                .frame(width: geo.size.width, height: geo.size.height)
                .contentShape(Rectangle()) // allows tapping wider area
                .onTapGesture {
                self.selection = (self.selection == self.text) ? "" : self.text
            }.opacity(self.selection == self.text ? 1 : 0.5)
        }
    }
    
}

struct SearchableList_Previews: PreviewProvider {
    static var previews: some View {
        SearchableList(list: Array(FoodToCarbonConverter.foodTypesInfo.keys), selected: .constant(""))
    }
}
