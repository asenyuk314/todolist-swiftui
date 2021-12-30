//
//  ItemsListView.swift
//  TodoList-SwiftUI
//
//  Created by Александр Сенюк on 30.12.2021.
//

import SwiftUI
import CoreData
import ChameleonFramework

struct ItemsListView: View {
  @Environment(\.managedObjectContext) private var viewContext
  var itemsRequest: FetchRequest<Item>
  var selectedCategory: Category
  private var itemsArray: FetchedResults<Item> {
    itemsRequest.wrappedValue
  }
  
  init (selectedCategory: Category, searchText: String) {
    self.selectedCategory = selectedCategory
    let sortDescriptors = [NSSortDescriptor(keyPath: \Item.date, ascending: true)]
    let categoryPredicate = NSPredicate(format: "parentCategory.id == %@", selectedCategory.id! as CVarArg)
    let searchPredicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
    let totalPredicate = searchText.isEmpty
    ? categoryPredicate
    : NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, searchPredicate])
    self.itemsRequest = FetchRequest(sortDescriptors: sortDescriptors, predicate: totalPredicate, animation: .default)
  }
  
  var body: some View {
    List {
      ForEach(Array(itemsArray.enumerated()), id: \.element.id) { index, item in
        let itemColor = UIColor(hexString: selectedCategory.color!)?.darken(byPercentage: CGFloat(index) / CGFloat(itemsArray.count)) ?? .white
        
        Button {
          checkItem(item)
        } label: {
          HStack {
            Text(item.name!)
            Spacer()
            Image(systemName: item.done ? "checkmark.circle.fill" : "circle")
          }
        }
        .frame(height: 60)
        .foregroundColor(Color(ContrastColorOf(itemColor, returnFlat: true)))
        .listRowBackground(Color(itemColor))
      }
      .onDelete(perform: deleteItems)
    }
  }
  
  // MARK: - Data Manipulation Methods
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      offsets.map { itemsArray[$0] }.forEach(viewContext.delete)
      
      do {
        try viewContext.save()
      } catch {
        let nsError = error as NSError
        fatalError("DeleteItems error \(nsError), \(nsError.userInfo)")
      }
    }
  }
  
  private func checkItem(_ item: Item) {
    item.done.toggle()
    do {
      try viewContext.save()
    } catch {
      let nsError = error as NSError
      fatalError("CheckItem error \(nsError), \(nsError.userInfo)")
    }
  }
}

struct ItemsListView_Previews: PreviewProvider {
  static var previews: some View {
    ItemsListView(selectedCategory: Category(), searchText: "").environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
