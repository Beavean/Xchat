//
//  GlobalFunctions.swift
//  Xchat
//
//  Created by Beavean on 12.11.2022.
//

import Foundation

func fileNameFrom(fileUrl: String) -> String {
    guard let name = ((fileUrl.components(separatedBy: "_").last)?.components(separatedBy: "?").first)?.components(separatedBy: ".").first else { return "" }
    return name
}
