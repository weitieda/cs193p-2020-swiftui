//
//  AirlineInfo.swift
//  Enroute
//
//  Created by CS193p Instructor.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import Foundation
import Combine

// json decoded directly from what comes back from FlightAware's "AirlineInfo?"

struct AirlineInfo: Codable, Hashable, Identifiable, Comparable {
    fileprivate(set) var code: String?
    private(set) var callsign: String
    private(set) var country: String
    private(set) var location: String
    private(set) var name: String
    private(set) var phone: String
    private(set) var shortname: String
    private(set) var url: String
    
    var friendlyName: String { shortname.isEmpty ? (name.isEmpty ? (code ?? "???") : name) : shortname }
    
    var id: String { code ?? callsign }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: AirlineInfo, rhs: AirlineInfo) -> Bool { lhs.id == rhs.id }
    static func < (lhs: AirlineInfo, rhs: AirlineInfo) -> Bool { lhs.id < rhs.id }
}

// TODO: share code with AirportInfoRequest

class AirlineInfoRequest: FlightAwareRequest<AirlineInfo>, Codable {
    private(set) var airline: String?
    
    static var all: [AirlineInfo] {
        requests.values.compactMap({ $0.results.value.first }).sorted()
    }
    
    var info: AirlineInfo? { results.value.first }

    private static var requests = [String:AirlineInfoRequest]()
    private static var cancellables = [AnyCancellable]()
    
    @discardableResult
    static func fetch(_ airline: String, perform: ((AirlineInfo) -> Void)? = nil) -> AirlineInfo? {
        let request = Self.requests[airline]
        if request == nil {
            Self.requests[airline] = AirlineInfoRequest(airline: airline)
            Self.requests[airline]?.fetch()
            return self.fetch(airline, perform: perform)
        } else if perform != nil {
            if let info = request!.info {
                perform!(info)
            } else {
                request!.results.sink { infos in
                    if let info = infos.first {
                        perform!(info)
                    }
                }.store(in: &Self.cancellables)
            }
        }
        return Self.requests[airline]?.results.value.first
    }
    
    private init(airline: String) {
        super.init()
        self.airline = airline
    }
    
    override var query: String {
        var request = "AirlineInfo?"
        request.addFlightAwareArgument("airlineCode", airline)
        return request
    }
    
    override var cacheKey: String? { "\(type(of: self)).\(airline!)" }

    override func decode(_ data: Data) -> Set<AirlineInfo> {
        var result = (try? JSONDecoder().decode(AirlineInfoRequest.self, from: data))?.flightAwareResult
        result?.code = airline
        return Set(result == nil ? [] : [result!])
    }

    private var flightAwareResult: AirlineInfo?

    private enum CodingKeys: String, CodingKey {
        case flightAwareResult = "AirlineInfoResult"
    }
}

