# XCTestApplication

This application is an example on how to use XCTest on the device. 
The idea is to replace GHUnit that is no longer maintained.

## What it can do:
* Run all the test at once
* Run individual test case when the row is tap
* Run both Objective-C and Swift test at the same time as long as the test class is inherit from XCTest

## What it can't do for now:
* Stop button is not yet working, need to find a way how to stop the test at once
* The test can't be run on the background thread, it looks it is a limitation on the XCTest itself

## Some Remarks:
If it is needed to run on the device then change use XCTest-Device and XCTAutomationSupport-Device framework on libs folder
