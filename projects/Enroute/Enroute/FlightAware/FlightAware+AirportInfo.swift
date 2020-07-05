//
//  AirportInfo.swift
//  Enroute
//
//  Created by CS193p Instructor.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import Foundation
import Combine

// json decoded directly from what comes back from FlightAware's "AirportInfo?"

struct AirportInfo: Codable, Hashable, Identifiable, Comparable {
    fileprivate(set) var icao: String?
    private(set) var latitude: Double
    private(set) var longitude: Double
    private(set) var location: String
    private(set) var name: String
    private(set) var timezone: String
    
    var friendlyName: String {
        Self.friendlyName(name: name, location: location)
    }
    
    static func friendlyName(name: String, location: String) -> String {
        var shortName = name
            .replacingOccurrences(of: " Intl", with: " ")
            .replacingOccurrences(of: " Int'l", with: " ")
            .replacingOccurrences(of: "Intl ", with: " ")
            .replacingOccurrences(of: "Int'l ", with: " ")
        for nameComponent in location.components(separatedBy: ",").map({ $0.trim }) {
            shortName = shortName
                .replacingOccurrences(of: nameComponent+" ", with: " ")
                .replacingOccurrences(of: " "+nameComponent, with: " ")
        }
        shortName = shortName.trim
        shortName = shortName.components(separatedBy: CharacterSet.whitespaces).joined(separator: " ")
        if !shortName.isEmpty {
            return "\(shortName), \(location)"
        } else {
            return location
        }
    }

    var id: String { icao ?? name }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: AirportInfo, rhs: AirportInfo) -> Bool { lhs.id == rhs.id }
    static func < (lhs: AirportInfo, rhs: AirportInfo) -> Bool { lhs.id < rhs.id }
}

// TODO: share code with AirlineInfoRequest

class AirportInfoRequest: FlightAwareRequest<AirportInfo>, Codable {
    private(set) var airport: String?
    
    static var all: [AirportInfo] {
        requests.values.compactMap({ $0.results.value.first }).sorted()
    }
    
    var info: AirportInfo? { results.value.first }

    private static var requests = [String:AirportInfoRequest]()
    private static var cancellables = [AnyCancellable]()
    
    @discardableResult
    static func fetch(_ airport: String, perform: ((AirportInfo) -> Void)? = nil) -> AirportInfo? {
        let request = Self.requests[airport]
        if request == nil {
            Self.requests[airport] = AirportInfoRequest(airport: airport)
            Self.requests[airport]?.fetch()
            return self.fetch(airport, perform: perform)
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
        return Self.requests[airport]?.results.value.first
    }
    
    private init(airport: String) {
        super.init()
        self.airport = airport
    }
    
    override var query: String {
        var request = "AirportInfo?"
        request.addFlightAwareArgument("airportCode", airport)
        return request
    }
    
    override var cacheKey: String? { "\(type(of: self)).\(airport!)" }

    override func decode(_ data: Data) -> Set<AirportInfo> {
        var result = (try? JSONDecoder().decode(AirportInfoRequest.self, from: data))?.flightAwareResult
        result?.icao = airport
        return Set(result == nil ? [] : [result!])
    }

    private var flightAwareResult: AirportInfo?

    private enum CodingKeys: String, CodingKey {
        case flightAwareResult = "AirportInfoResult"
    }
}
