//
//  Status.swift
//  Xchat
//
//  Created by Beavean on 12.11.2022.
//

import Foundation

enum Status: String, CaseIterable {
    
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
}
