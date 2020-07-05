//
//  EnroutRequest.swift
//  Enroute
//
//  Created by CS193p Instructor.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import Foundation
import Combine

// fetches FAFlight objects from FlightAware using "Enroute?"
// (flights enroute to a specified airport)
// generally supports fetching only one airport's enroute flights at a time
// (just to minimize FlightAware API requests)

class EnrouteRequest: FlightAwareRequest<FAFlight>, Codable
{
    private(set) var airport: String!
    
    private static var requests = [String:EnrouteRequest]()
    
    static func create(airport: String, howMany: Int? = nil) -> EnrouteRequest {
        if let request = requests[airport] {
            request.howMany = howMany ?? request.howMany
            return request
        } else {
            let request = EnrouteRequest(airport: airport, howMany: howMany)
            requests[airport] = request
            return request
        }
    }
    
    private init(airport: String, howMany: Int? = nil) {
        super.init()
        self.airport = airport
        if howMany != nil { self.howMany = howMany! }
    }
    
    private static var sharedFetchTimer: Timer?
    
    override var fetchTimer: Timer? {
        get { Self.sharedFetchTimer }
        set {
            Self.sharedFetchTimer?.invalidate()
            Self.sharedFetchTimer = newValue
        }
    }

    override var cacheKey: String? { "\(type(of: self)).\(airport!)" }
    
    override func decode(_ data: Data) -> Set<FAFlight> {
        let result = (try? JSONDecoder().decode(EnrouteRequest.self, from: data))?.flightAwareResult
        offset = result?.next_offset ?? 0
        return Set(result?.enroute ?? [])
    }
    
    override func filter(_ results: Set<FAFlight>) -> Set<FAFlight> {
        results.filter { $0.arrival > Date.currentFlightTime }
    }
    
    override var query: String {
        var request = "Enroute?"
        request.addFlightAwareArgument("airport", airport)
        request.addFlightAwareArgument("howMany", batchSize)
        request.addFlightAwareArgument("filter", "airline")
        request.addFlightAwareArgument("offset", offset)
        return request
    }
    
    private var flightAwareResult: EnrouteResult?
    
    private enum CodingKeys: String, CodingKey {
        case flightAwareResult = "EnrouteResult"
    }
    
    private struct EnrouteResult: Codable {
        var next_offset: Int
        var enroute: [FAFlight]
    }
}
