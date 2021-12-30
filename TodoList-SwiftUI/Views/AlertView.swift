//
//  AlertView.swift
//  TodoList-SwiftUI
//
//  Created by Александр Сенюк on 29.12.2021.
//

import SwiftUI

protocol AlertDelegate {
  func onAlertSaveHandler()
}

struct AlertView: View {
  @Binding var textEntered: String
  @Binding var showingAlert: Bool
  var title: String = "Добавить"
  var delegate: AlertDelegate?
  
  var body: some View {
    if showingAlert {
      Rectangle()
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(.black)
        .opacity(0.5)
        .ignoresSafeArea()
        .onTapGesture(perform: toggleAlert)
      ZStack {
        RoundedRectangle(cornerRadius: 20)
          .fill(.white)
        VStack {
          Text(title)
            .font(.title3)
          
          Divider()
          
          TextField("Введите текст", text: $textEntered)
            .padding()
          
          Divider()
            .padding(.bottom)
          
          HStack {
            Button("Сохранить") {
              self.delegate?.onAlertSaveHandler()
            }
            .padding(.horizontal)
            Button("Отменить", action: toggleAlert)
              .foregroundColor(.red)
              .padding(.horizontal)
          }
        }
      }
      .frame(width: 300, height: 200)
      .zIndex(1)
    }
  }
  
  func toggleAlert() {
    withAnimation {
      self.showingAlert.toggle()
    }
  }
}

struct AlertView_Previews: PreviewProvider {
  static var previews: some View {
    AlertView(textEntered: .constant(""), showingAlert: .constant(true))
      .previewLayout(.sizeThatFits)
  }
}
