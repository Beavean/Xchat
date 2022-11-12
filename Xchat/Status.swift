//
//  Status.swift
//  Xchat
//
//  Created by Beavean on 12.11.2022.
//

import Foundation

enum Status: String {
    
    case available = "Available"
    case busy = "Busy"
    case atSchool = "At School"
    case atTheMovies = "At The Movies"
    case atWork = "At Work"
    case batteryGettingLow = "Battery is getting low"
    case cantTalk = "Can't Talk"
    case inTheMeeting = "In the Meeting"
    case atTheGym = "At the gym"
    case sleeping = "Sleeping"
    case urgentCallsOnly = "Urgent calls only"
    
    static var array: [Status] {
        var arrayOfStatuses: [Status] = []
        
        switch Status.available {
        case .available:
            arrayOfStatuses.append(.available); fallthrough
        case .busy:
            arrayOfStatuses.append(.busy); fallthrough
        case .atSchool:
            arrayOfStatuses.append(.atSchool); fallthrough
        case .atTheMovies:
            arrayOfStatuses.append(.atTheMovies); fallthrough
        case .atWork:
            arrayOfStatuses.append(.atWork); fallthrough
        case .batteryGettingLow:
            arrayOfStatuses.append(.batteryGettingLow); fallthrough
        case .cantTalk:
            arrayOfStatuses.append(.cantTalk); fallthrough
        case .inTheMeeting:
            arrayOfStatuses.append(.inTheMeeting); fallthrough
        case .atTheGym:
            arrayOfStatuses.append(.atTheGym); fallthrough
        case .sleeping:
            arrayOfStatuses.append(.sleeping); fallthrough
        case .urgentCallsOnly:
            arrayOfStatuses.append(.urgentCallsOnly); fallthrough
        default:
            break
        }
        return arrayOfStatuses
    }
}
