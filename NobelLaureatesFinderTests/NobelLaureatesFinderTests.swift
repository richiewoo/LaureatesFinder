//
//  NobelLaureatesFinderTests.swift
//  NobelLaureatesFinderTests
//
//  Created by Xinbo Wu on 7/27/19.
//  Copyright © 2019 Xinbo Wu. All rights reserved.
//

import XCTest
@testable import NobelLaureatesFinder

class NobelLaureatesFinderTests: XCTestCase {
    lazy var laureatesDataProvider: LaureatesDataProvider? = {
        guard let fileUrl = Bundle.main.url(forResource: "nobel-prize-laureates", withExtension: "json") else {
            return nil
        }
        return LaureatesDataProvider(url: fileUrl)
    }()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPerformanceDataLoading() {
        self.measure {
            // Put the code you want to measure the time of here.
            self .testFetchingLaureates()
        }
    }
    
    func testPerformanceCloestLaureates() {
        self .testFetchingLaureates()
        self.measure {
            // Put the code you want to measure the time of here.
            self .testClosestLaureates()
        }
    }
    
    func testPerformanceCloestLaureatesInSameYear() {
        self .testFetchingLaureates()
        self.measure {
            // Put the code you want to measure the time of here.
            self .testClosestLaureatesInSameYear()
        }
    }
    
    func testFetchingLaureates() {
        // 1. given
        let expectation = XCTestExpectation(description: "load laureates from database")
        // 2. when
        laureatesDataProvider?.fectchLaureates {
            // 3. then
            XCTAssertNil($0)
            expectation.fulfill()
        }
        
        //wait the expectation is fulfilled, with a timeout of 5 seconds
        wait(for: [expectation], timeout: 5)
    }
    
    func testClosestLaureates() {
        self .testFetchingLaureates()
        
        // 1. given
        let location =  Location(lat: 37.334922, lng: -122.009033)
        
        // 2. when
        let closestLaureates = laureatesDataProvider?.closestLaureates(in: location)
        
        // 3. then
        XCTAssertNotNil(closestLaureates)
        XCTAssertTrue(closestLaureates!.count == 20)
    }
    
    func testClosestLaureatesInSameYear() {
        self .testFetchingLaureates()
        
        // 1. given
        let location =  Location(lat: 37.334922, lng: -122.009033)
        
        // 2. when
        let closestLaureates = laureatesDataProvider?.closestLaureates(in: location, inYears: Timespan(start: 2000, end: 2000))
        
        // 3. then
        XCTAssertNotNil(closestLaureates)

    }
}
