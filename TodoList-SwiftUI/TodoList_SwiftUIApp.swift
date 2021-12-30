//
//  TodoList_SwiftUIApp.swift
//  TodoList-SwiftUI
//
//  Created by Александр Сенюк on 29.12.2021.
//

import SwiftUI

@main
struct TodoList_SwiftUIApp: App {
  let persistenceController = PersistenceController.shared
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
