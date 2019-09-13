//
//  NobelLaureates.swift
//  Test
//
//  Created by Xinbo Wu on 7/26/19.
//  Copyright © 2019 Xinbo Wu. All rights reserved.
//

import Foundation

public class LaureatesDataProvider {
    let url: URL
    var laureates: [Laureate]?
    
    public init(url: URL) {
        self.url = url
    }
    
    public func fectchLaureates(completionHandler: @escaping (Error?) -> Void) {
        DispatchQueue.global().async { [unowned self] in
            do {
                let data = try Data(contentsOf: self.url)
                self.laureates = try Laureate.decoder.decode([Laureate].self, from: data)
            } catch let error {
                completionHandler(error)
            }
            completionHandler(nil)
        }
    }
    
    
    public func closestLaureates(of amount: Int, in location: Location, from start: Int, to end: Int) -> [Laureate]?{
        
        let startYear = start > end ? "\(end)" : "\(start)"
        let endYear = start > end ? "\(start)" : "\(end)"
        
        let laureatesBetweenYears = laureates?.filter { ($0.year >= startYear) && ($0.year <= endYear) }
        guard let filteredLaureates = laureatesBetweenYears else {
            return nil
        }
        
        let laureatesSortedByDistance = filteredLaureates.sorted{ location.distance(from: $0.location) < location.distance(from: $1.location) }
        if laureatesSortedByDistance.count > amount {
            return Array(laureatesSortedByDistance[0...(amount - 1)])
        }
        
        return laureatesSortedByDistance
    }
}
