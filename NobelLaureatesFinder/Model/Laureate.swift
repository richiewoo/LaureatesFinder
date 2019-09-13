//
//  Laureate.swift
//
//  Created by Xinbo Wu on 7/28/19.
//  Copyright © 2019 Xinbo Wu. All rights reserved.
//
import Foundation

public struct Location: Decodable {
    public var lat: Double
    public var lng: Double
    
    public init(lat: Double, lng: Double) {
        self.lat = lat
        self.lng = lng
    }
    
    // distance from location
    public func distance(from location: Location) -> Double {
        return sqrt(pow((location.lat - lat), 2) + pow((location.lng - lng), 2))
    }
}

public struct Laureate: Decodable {    
    public var id: Int
    public var category: String
    public var died: Date
    public var diedcity: String
    public var borncity:  String
    public var born:  Date
    public var surname:  String
    public var firstname:  String
    public var motivation:  String
    public var location: Location
    public var city:  String
    public var borncountry:  String
    public var year:  String
    public var diedcountry:  String
    public var country:  String
    public var gender:  String
    public var name:  String
}

// nest encoder object
extension Laureate {
    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.dateFormatter)
        return  decoder
    }()
}

// date format for date members
extension DateFormatter {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
