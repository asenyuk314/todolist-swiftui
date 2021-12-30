//
//  ContentView.swift
//  TodoList-SwiftUI
//
//  Created by Александр Сенюк on 29.12.2021.
//

import SwiftUI
import CoreData
import ChameleonFramework

struct ContentView: View {
  @Environment(\.managedObjectContext) private var viewContext
  
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Category.date, ascending: true)],
    animation: .default)
  private var categories: FetchedResults<Category>
  @State private var isCategoryAlertShown = false
  @State private var textEntered = ""
  
  var body: some View {
    NavigationView {
      ZStack {
        List {
          ForEach(categories) { category in
            NavigationLink {
              ItemsView(selectedCategory: category)
            } label: {
              Text(category.name!)
                .foregroundColor(Color(ContrastColorOf(UIColor(hexString: category.color!) ?? .systemBlue, returnFlat: true)))
            }
            .frame(height: 60)
            .listRowBackground(Color(UIColor(hexString: category.color!) ?? .white))
          }
          .onDelete(perform: deleteCategories)
        }
        .navigationTitle("TodoList")
        .listStyle(.grouped)
        .toolbar {
          ToolbarItem {
            Button(action: toggleAlert) {
              Label("Добавить Категорию", systemImage: "plus")
            }
          }
        }
        AlertView(textEntered: $textEntered, showingAlert: $isCategoryAlertShown, title: "Добавить категорию", delegate: self)
      }
    }
  }
  
  // MARK: - Data Manipulation Methods
  
  private func addCategory() {
    withAnimation {
      let newCategory = Category(context: viewContext)
      newCategory.id = UUID()
      newCategory.date = Date()
      newCategory.color = UIColor.randomFlat().hexValue()
      newCategory.name = textEntered
      newCategory.items = []
      
      
      do {
        try viewContext.save()
      } catch {
        let nsError = error as NSError
        fatalError("AddCategory error \(nsError), \(nsError.userInfo)")
      }
    }
  }
  
  private func deleteCategories(offsets: IndexSet) {
    withAnimation {
      offsets.map { categories[$0] }.forEach(viewContext.delete)
      
      do {
        try viewContext.save()
      } catch {
        let nsError = error as NSError
        fatalError("DeleteCategories error \(nsError), \(nsError.userInfo)")
      }
    }
  }
  
  // MARK: - Alert Methods
  
  private func toggleAlert() {
    textEntered = ""
    withAnimation {
      self.isCategoryAlertShown.toggle()
    }
  }
}

extension ContentView: AlertDelegate{
  func onAlertSaveHandler() {
    addCategory()
    toggleAlert()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
