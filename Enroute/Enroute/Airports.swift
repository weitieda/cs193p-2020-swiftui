//
//  Airports.swift
//  Enroute
//
//  Created by CS193p Instructor.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import Combine

// a (shared) ViewModel that supplies info about all known airports
// see also: Airlines

class Airports: ObservableObject
{
    static let all: Airports = Airports()
    
    // ICAO codes of all airports which have ever been fetched
    var codes: [String] { AirportInfoRequest.all.compactMap { $0.icao }.sorted() }

    // convenience subscript
    subscript (airport: String?) -> AirportInfo? {
        airport == nil ? nil : fetch(airport!)
    }

    // get information about a specific airport
    // if this airport's info has never been fetched
    // this will return nil
    // but it will also fire off a fetch in that case
    // and then objectWillChange.send() will happen when it returns data
    @discardableResult
    func fetch(_ airport: String) -> AirportInfo? {
        let info = AirportInfoRequest.fetch(airport)
        if info == nil {
            AirportInfoRequest.fetch(airport) { [weak self] _ in
                self?.objectWillChange.send()
            }
        }
        return info
    }

    private init() { }
}
