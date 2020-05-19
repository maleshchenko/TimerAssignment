//
//  SleepTimerAssignmentTests.swift
//  SleepTimerAssignmentTests
//
//  Created by Mykola Aleshchenko on 16.05.2020.
//  Copyright © 2020 Mykola Aleshchenko. All rights reserved.
//

import XCTest
@testable import SleepTimerAssignment

final class SleepTimerAssignmentTests: XCTestCase {
    
    let viewModel = SleepTimerViewModel()
    
    func testRecordingSwitch() {
        viewModel.switchRecordingOff()
        XCTAssertFalse(viewModel.isRecordingAvailable)
    }
    
    func testRecordingState() {
        viewModel.switchRecordingOff()
        
        viewModel.proceed()
        XCTAssertTrue(viewModel.appState == .playing)
    }
    
    func testFinishedFlow() {
        viewModel.didFinishFlow()
        XCTAssertTrue(viewModel.isRecordingAvailable)
    }

}
