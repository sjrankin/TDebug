//
//  CommandParser.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class CommandParser
{
    let PartSeparator = "¥"
    
    func ParseRaw(_ Raw: String) -> Command?
    {
        return nil
    }
    
    func MakeCommand(_ Parts: [String]) -> String
    {
        var Final = ""
        for Part in Parts
        {
            Final = Final + Part
            Final = Final + PartSeparator
        }
        Final.removeLast(1)
        return Final
    }
    
    func MakeCoordinate(Row: String, Column: Int) -> String
    {
        return "\(Row)\(Column)"
    }
    
    func MakeColor(_ Color: UIColor) -> String
    {
        return ""
    }
}
