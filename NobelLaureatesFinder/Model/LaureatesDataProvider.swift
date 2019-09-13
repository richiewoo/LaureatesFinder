//
//  NobelLaureates.swift
//
//  Created by Xinbo Wu on 7/28/19.
//  Copyright © 2019 Xinbo Wu. All rights reserved.
//

import Foundation

//define type Timespan
public struct Timespan {
    public static var `default` : Timespan = { return Timespan(start: 1900, end: 2020) }()
    
    var start: Int
    var end: Int
}

public class LaureatesDataProvider {
    private let url: URL
    private var laureates: [Laureate]?
    private var laureatesGroupedByYear: Dictionary<String, [Int]>?
    
    public init(url: URL) {
        self.url = url
    }
    
    // fectch laureates from database and categorize them by year
    public func fectchLaureates(completionHandler: @escaping (Error?) -> Void) {
        DispatchQueue.global().async { [unowned self] in
            do {
                // load laureates from database
                let data = try Data(contentsOf: self.url)
                
                self.laureates = try Laureate.decoder.decode([Laureate].self, from: data)
                
                //grouping laureates index by year, one time cost
                self.laureatesGroupedByYear = Dictionary()
                for (index, laureate) in self.laureates!.enumerated() {
                    if var laureatesGroup = self.laureatesGroupedByYear![laureate.year] {
                        laureatesGroup.append(index)
                        self.laureatesGroupedByYear![laureate.year] = Array(laureatesGroup)
                    } else {
                        self.laureatesGroupedByYear![laureate.year] = [index]
                    }
                }
            } catch let error {
                completionHandler(error)
            }
            completionHandler(nil)
        }
    }
    
    // get closest laureates
    // Have to fectch laureates from database before calling this method
    public func closestLaureates(in location: Location, inYears timespan: Timespan = Timespan.default, of amount: Int = 20) -> [Laureate]?{
        let fromYear = min(timespan.start, timespan.end)
        let toYear = max(timespan.start, timespan.end)
        
        // gather all laureates between fromYear and toYear
        var laureatesBetweenYears = [Laureate]()
        for year in fromYear...toYear {
            guard let laureateIndexsInYear = laureatesGroupedByYear?["\(year)"] else {
                continue
            }
            // iterate the indices to gather lareates
            for index in laureateIndexsInYear {
                laureatesBetweenYears.append(laureates![index])
            }
        }
        // sort laureates by current location
        let sortedLaureates = laureatesBetweenYears.sorted{ location.distance(from: $0.location) < location.distance(from: $1.location) }
        if sortedLaureates.count > amount {
            return Array(sortedLaureates[0...(amount - 1)])
        }
        
        return sortedLaureates
    }
}
