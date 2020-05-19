//
//  TimePickerView.swift
//  SleepTimerAssignment
//
//  Created by Mykola Aleshchenko on 17.05.2020.
//  Copyright © 2020 Mykola Aleshchenko. All rights reserved.
//

import SwiftUI

struct TimePickerView: View {
    @Binding var isPresented: Bool
    @State private var isShowingAlert = false
    
    @State private var selectedOption = Date()
    @Binding var option: Date
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.dismiss()
                }) {
                    Text("Cancel")
                }
                
                Spacer()
                Text("Alarm").bold()
                Spacer()
                
                Button(action: {
                    self.dismiss()
                }) {
                    Text("Done")
                }
                
            }.padding()
            
            Divider()
            
            DatePicker("", selection: $selectedOption, displayedComponents: .hourAndMinute)
                .onReceive([self.selectedOption].publisher.first()) { (value) in
                    self.selectedOption = value
                    if self.validateInput(date: value) {
                        self.option = value
                    } else {
                        self.isShowingAlert = true
                    }
            }
        }.alert(isPresented: $isShowingAlert) {
            self.alert
        }
    }
    
    // MARK: - Actions
    
    private func dismiss() {
        isPresented = false
    }
    
    // MARK: - Child views
    
    private var alert: Alert {
        Alert(title: Text("Please pick a longer period"),
              message: Text(""),
              dismissButton: .default(Text("Ok"), action: { self.isShowingAlert = false }))
    }
    
    // MARK: - Validation
    
    private func validateInput(date: Date) -> Bool {
        let timeFromNow = -Date.timeDifference(startDate: date)
        if timeFromNow != 0 && timeFromNow <= 60 {
            return false
        }
        
        return true
    }
}
