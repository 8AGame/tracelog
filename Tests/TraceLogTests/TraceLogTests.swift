//
//  TraceLogTests.swift
//  TraceLog
//
//  Created by Tony Stone on 11/1/15.
//  Copyright © 2015 Tony Stone. All rights reserved.
//

import XCTest
import TraceLog

///
/// Log Writer which captures the expected value and fulfills the XCTestExpectation when it matches the message
///
class ExpectationValues : Writer {
    
    let expectation: XCTestExpectation
    
    let level: LogLevel
    let tag: String
    let message: String
    let file: String
    let function: String
    let testFileFunction: Bool
    
    init(expectation: XCTestExpectation, level: LogLevel, tag: String, message: String, file: String = #file, function: String = #function, testFileFunction: Bool = true) {
        self.expectation = expectation
        self.level = level
        self.tag = tag
        self.message = message
        self.file = file
        self.function = function
        self.testFileFunction = testFileFunction
    }
    
    func log(_ timestamp: Double, level: LogLevel, tag: String, message: String, runtimeContext: RuntimeContext, staticContext: StaticContext) {
        
        if level == self.level &&
            tag == self.tag &&
            message == self.message {
            
            if !testFileFunction ||
                staticContext.file == self.file &&
                staticContext.function == self.function
            {
                expectation.fulfill()
            }
        }
    }
}

///
/// Main test class for Swift
///
class TraceLogTests_Swift : XCTestCase {
    
    let testTag = "Test Tag"
    
    func testinitialize_NoArgs() {
        TraceLog.initialize()
    }
    
    func testinitialize_LogWriters() {
        let testMessage = "TraceLog initialized with configuration: {\n\tglobal: {\n\n\t\tALL = INFO\n\t}\n}"
        
        let expectedValues = ExpectationValues(expectation: self.expectation(description: testMessage), level: .info, tag: "TraceLog", message: testMessage, testFileFunction: false)
        
        TraceLog.initialize(writers: [expectedValues])
        
        self.waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }
    
    func testinitialize_LogWriters_Environment() {

        let testMessage = "TraceLog initialized with configuration: {\n\ttags: {\n\n\t\tTraceLog = TRACE4\n\t}\n\tprefixes: {\n\n\t\tNS = OFF\n\t}\n\tglobal: {\n\n\t\tALL = TRACE4\n\t}\n}"
        
        let expectedValues = ExpectationValues(expectation: self.expectation(description: testMessage), level: .info, tag: "TraceLog", message: testMessage, testFileFunction: false)
        
        TraceLog.initialize(writers: [expectedValues], environment: ["LOG_ALL": "TRACE4",
                                                                         "LOG_PREFIX_NS" : "OFF",
                                                                         "LOG_TAG_TraceLog" : "TRACE4"])
        
        self.waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }
    
    func testinitialize_LogWriters_Environment_GlobalInvalidLogLevel() {
        
        let testMessage = "invalidLogLevel(\"Variable \\\'LOG_ALL\\\' has an invalid logLevel of \\\'TRACE5\\\'. \\\'LOG_ALL\\\' will be set to INFO.\")"
        
        let expectedValues = ExpectationValues(expectation: self.expectation(description: testMessage), level: .warning, tag: "TraceLog", message: testMessage, testFileFunction: false)
        
        TraceLog.initialize(writers: [expectedValues], environment: ["LOG_ALL": "TRACE5"])
        
        self.waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }
    
    func testinitialize_LogWriters_Environment_PrefixInvalidLogLevel() {
        
        let testMessage = "invalidLogLevel(\"Variable \\\'LOG_PREFIX_NS\\\' has an invalid logLevel of \\\'TRACE5\\\'. \\\'LOG_PREFIX_NS\\\' will NOT be set.\")"
        
        let expectedValues = ExpectationValues(expectation: self.expectation(description: testMessage), level: .warning, tag: "TraceLog", message: testMessage, testFileFunction: false)
        
        TraceLog.initialize(writers: [expectedValues], environment: ["LOG_PREFIX_NS": "TRACE5"])
        
        self.waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }
    
    func testinitialize_LogWriters_Environment_TagInvalidLogLevel() {
        
        let testMessage = "invalidLogLevel(\"Variable \\\'LOG_TAG_TRACELOG\\\' has an invalid logLevel of \\\'TRACE5\\\'. \\\'LOG_TAG_TRACELOG\\\' will NOT be set.\")"
        
        let expectedValues = ExpectationValues(expectation: self.expectation(description: testMessage), level: .warning, tag: "TraceLog", message: testMessage, testFileFunction: false)
        
        TraceLog.initialize(writers: [expectedValues], environment: ["LOG_TAG_TraceLog": "TRACE5"])
        
        self.waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }
    
    func testLogError() {
        let testMessage = "Swift: " + #function
        
        let expectedValues = ExpectationValues(expectation: self.expectation(description: testMessage), level: .error, tag: testTag, message: testMessage)

        TraceLog.initialize(writers: [expectedValues], environment: ["LOG_ALL": "ERROR"])
        
        logError(testTag) { testMessage }
        
        self.waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }
    
    func testLogWarning() {
        let testMessage = "Swift: " + #function
        
        let expectedValues = ExpectationValues(expectation: self.expectation(description: testMessage), level: .warning, tag: testTag, message: testMessage)
        
        TraceLog.initialize(writers: [expectedValues], environment: ["LOG_ALL": "WARNING"])
        
        logWarning(testTag) { testMessage }
        
        self.waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }

    func testLogInfo() {
        let testMessage = "Swift: " + #function
        
        let expectedValues = ExpectationValues(expectation: self.expectation(description: testMessage), level: .info, tag: testTag, message: testMessage)
        
        TraceLog.initialize(writers: [expectedValues], environment: ["LOG_ALL": "INFO"])
        
        logInfo(testTag) { testMessage }
        
        self.waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }
    
    func testLogTrace() {
        let testMessage = "Swift: " + #function
        
        let expectedValues = ExpectationValues(expectation: self.expectation(description: testMessage), level: .trace1, tag: testTag, message: testMessage)
        
        TraceLog.initialize(writers: [expectedValues], environment: ["LOG_ALL": "TRACE1"])
        
        logTrace(testTag, level: 1) { testMessage }
        
        self.waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }
    
    func testLogTrace1() {
        let testMessage = "Swift: " + #function
        
        let expectedValues = ExpectationValues(expectation: self.expectation(description: testMessage), level: .trace1, tag: testTag, message: testMessage)
        
        TraceLog.initialize(writers: [expectedValues], environment: ["LOG_ALL": "TRACE1"])
        
        logTrace(testTag, level: 1) { testMessage }
        
        self.waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }
    
    func testLogTrace2() {
        let testMessage = "Swift: " + #function
        
        let expectedValues = ExpectationValues(expectation: self.expectation(description: testMessage), level: .trace2, tag: testTag, message: testMessage)
        
        TraceLog.initialize(writers: [expectedValues], environment: ["LOG_ALL": "TRACE2"])
        
        logTrace(testTag, level: 2) { testMessage }
        
        self.waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }
    
    func testLogTrace3() {
        let testMessage = "Swift: " + #function
        
        let expectedValues = ExpectationValues(expectation: self.expectation(description: testMessage), level: .trace3, tag: testTag, message: testMessage)
        
        TraceLog.initialize(writers: [expectedValues], environment: ["LOG_ALL": "TRACE3"])
        
        logTrace(testTag, level: 3) { testMessage }
        
        self.waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }
    
    func testLogTrace4() {
        let testMessage = "Swift: " + #function
        
        let expectedValues = ExpectationValues(expectation: self.expectation(description: testMessage), level: .trace4, tag: testTag, message: testMessage)
        
        TraceLog.initialize(writers: [expectedValues], environment: ["LOG_ALL": "TRACE4"])
        
        logTrace(testTag, level: 4) { testMessage }
        
        self.waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }    
}
