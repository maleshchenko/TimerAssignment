//
//  ContentView.swift
//  SleepTimerAssignment
//
//  Created by Mykola Aleshchenko on 16.05.2020.
//  Copyright © 2020 Mykola Aleshchenko. All rights reserved.
//

import SwiftUI
import Combine

struct MainView: View {
    @State private var isShowingAlarmPicker = false
    @State private var isShowingTimerOptions = false
    @State private var isShowingAlert = false
    @State private var timerOption: Int = 0
    @State private var alarmOption = Date()
    
    @ObservedObject private var viewModel = SleepTimerViewModel()
    
    private let spacing: CGFloat = 30.0
    private let noTimerString = "Set Timer"
    
    private let alertPublisherNotification = NotificationCenter.default.publisher(for: NSNotification.Name(NotificationConstants.alertNotification))
    private let openAppFromNotification = NotificationCenter.default.publisher(for: NSNotification.Name(NotificationConstants.openAppFromNotification))
    
    // MARK: - Main view
    
    var body: some View {
        
        VStack(alignment: .center, spacing: self.spacing) {
            Text("\((viewModel.appState.rawValue).capitalized)")
                .bold()
            
            Spacer()
            Button(action: {
                self.viewModel.switchRecordingOff()
            }) {
                Text("Don't record this time")
            }.disabled(!viewModel.isRecordingAvailable)
                .foregroundColor(viewModel.isRecordingAvailable ? .blue : .gray)
            
            Spacer()
            Divider()
            
            HStack {
                Text("Sleep timer")
                Spacer()
                Button(action: {
                    self.isShowingTimerOptions = true
                }) {
                    Text(viewModel.description(timerOption))
                }.disabled(viewModel.appState == .idle ? false : true)
                    .foregroundColor(viewModel.appState == .idle ? .blue : .gray)
            }
            
            Divider()
            
            HStack {
                Text("Alarm")
                Spacer()
                Button(action: {
                    self.isShowingAlarmPicker = true
                }) {
                    Text(alarmOption.noSeconds == Date().noSeconds ? noTimerString : alarmOption.timeString())
                }.disabled(timerOption == 0 || viewModel.appState != .idle)
                    .foregroundColor(viewModel.appState == .idle ? .blue : .gray)
            }
            
            Divider()
            
            Button(action: {
                self.viewModel.appState == .idle ? self.viewModel.startTimers(timerOption: self.timerOption, alarmTime: self.alarmOption) : self.viewModel.proceed()
            }) {
                Text(self.viewModel.isStopped ? "Play" : "Pause").padding()
            }.foregroundColor(validateButton() ? .white : .clear )
                .background(validateButton() ? Color.blue : Color.clear)
                .cornerRadius(10.0)
                .frame(maxWidth: .infinity)
                .disabled(!validateButton())
        }.padding(.all, self.spacing)
            .sheet(isPresented: $isShowingAlarmPicker) {
                self.pickerView
        }.actionSheet(isPresented: self.$isShowingTimerOptions) {
            actionSheet
        }.alert(isPresented: self.$isShowingAlert) {
            alert
        }.onReceive(alertPublisherNotification) { _ in
            self.isShowingAlert = true
            self.viewModel.startAlarm()
            self.invalidateUI()
        }.onReceive(openAppFromNotification) { _ in
            self.invalidateUI()
            self.viewModel.didFinishFlow()
        }
    }
}

// MARK: - Child views

extension MainView {
    private var timerOptionsButtons: [ActionSheet.Button] {
        typealias ActionSheetButton = ActionSheet.Button
        var options = [ActionSheetButton]()
        for option in viewModel.timerOptions {
            options.append(ActionSheet.Button.default(Text(viewModel.description(option)), action: { self.timerOption = option }))
        }
        
        options.append(ActionSheetButton.cancel())
        
        return options
    }
    
    private var actionSheet: ActionSheet {
        ActionSheet(title: Text("Sleep Timer"),
                    message: Text(""),
                    buttons: timerOptionsButtons
        )
    }
    
    private var pickerView: TimePickerView {
        TimePickerView(isPresented: $isShowingAlarmPicker, option: $alarmOption)
    }
    
    private var alert: Alert {
        Alert(title: Text("Alarm went off"),
              message: Text(""),
              dismissButton: .default(Text("Stop"), action: { self.stopAlarm()}))
    }
}

// MARK: - Miscellaneous

extension MainView {
    private func stopAlarm() {
        viewModel.stopAlarm()
        invalidateUI()
    }
    
    private func validateButton() -> Bool {
        let timeDifference = -Date.timeDifference(startDate: alarmOption)
        return timerOption != 0 && timeDifference > 0 && timeDifference > timerOption * 60 || viewModel.appState != .idle
    }
    
    private func invalidateUI() {
        timerOption = 0
        alarmOption = Date()
    }
    
    #if DEBUG
    struct MainView_Previews: PreviewProvider {
        static var previews: some View {
            MainView()
        }
    }
    #endif
}
