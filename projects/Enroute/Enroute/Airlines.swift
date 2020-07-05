//
//  Airlines.swift
//  Enroute
//
//  Created by CS193p Instructor.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import Combine

// a (shared) ViewModel that supplies info about all known airlines
// see Airports for more commentary on this (since it's almost identical)
// TODO: share code with Airports object?

class Airlines: ObservableObject
{
    static let all: Airlines = Airlines()
        
    var codes: [String] { AirlineInfoRequest.all.compactMap { $0.code }.sorted() }

    subscript (airline: String?) -> AirlineInfo? {
        airline == nil ? nil : fetch(airline!)
    }
    
    @discardableResult
    func fetch(_ airline: String!) -> AirlineInfo? {
        let info = AirlineInfoRequest.fetch(airline)
        if info == nil {
            AirlineInfoRequest.fetch(airline) { [weak self] _ in
                self?.objectWillChange.send()
            }
        }
        return info
    }
    
    private init() { }
}
