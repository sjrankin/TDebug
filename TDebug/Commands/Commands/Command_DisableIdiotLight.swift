//
//  Command_DisableIdiotLight.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Command_DisableIdiotLight: CommandObject
{
    override init()
    {
        super.init()
        Operator = .DisableIdiotLight
        Operand = nil
    }
    
    func CommandName() -> String
    {
        return "DisableIdiotLight"
    }
    
    func OperandType() -> String
    {
        return "Coordinate"
    }
    
    func CommandID() -> Int
    {
        return CommandOperators.DisableIdiotLight.rawValue
    }
    
    func CommandFormat() -> String
    {
        return "CMD,Coordinate"
    }
}
