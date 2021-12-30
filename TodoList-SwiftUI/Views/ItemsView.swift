//
//  ItemsView.swift
//  TodoList-SwiftUI
//
//  Created by Александр Сенюк on 29.12.2021.
//

import SwiftUI

struct ItemsView: View {
  @Environment(\.managedObjectContext) private var viewContext
  var selectedCategory: Category
  @State private var isCategoryAlertShown = false
  @State private var alertText = ""
  @State private var searchText = ""
  
  var body: some View {
    ZStack {
      VStack {
        HStack {
          Image(systemName: "magnifyingglass")
          TextField("Поиск", text: $searchText)
            .foregroundColor(.primary)
          Button {
            UIApplication.shared.hideKeyboard()
            self.searchText = ""
          } label: {
            Image(systemName: "xmark.circle.fill").opacity(searchText == "" ? 0 : 1)
          }
          
        }
        .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
        .foregroundColor(.secondary)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10.0)
        ItemsListView(selectedCategory: selectedCategory, searchText: searchText)
          .navigationTitle(selectedCategory.name ?? "")
          .listStyle(.grouped)
          .toolbar {
            ToolbarItem {
              Button(action: toggleAlert) {
                Label("Добавить", systemImage: "plus")
              }
            }
          }
      }
      
      AlertView(textEntered: $alertText, showingAlert: $isCategoryAlertShown, title: "Добавить", delegate: self)
    }
  }
  
  
  // MARK: - Data Manipulation Methods
  
  private func addItem() {
    withAnimation {
      let newItem = Item(context: viewContext)
      newItem.id = UUID()
      newItem.date = Date()
      newItem.done = false
      newItem.name = alertText
      newItem.parentCategory = selectedCategory
      
      do {
        try viewContext.save()
      } catch {
        let nsError = error as NSError
        fatalError("AddItem error \(nsError), \(nsError.userInfo)")
      }
    }
  }
  
  // MARK: - Alert Methods
  
  private func toggleAlert() {
    alertText = ""
    withAnimation {
      self.isCategoryAlertShown.toggle()
    }
  }
}

extension ItemsView: AlertDelegate {
  func onAlertSaveHandler() {
    addItem()
    toggleAlert()
  }
}

// MARK: - HideKeyboard extension

extension UIApplication {
  func hideKeyboard() {
    sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}

struct ItemsView_Previews: PreviewProvider {
  static var previews: some View {
    ItemsView(selectedCategory: Category()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
