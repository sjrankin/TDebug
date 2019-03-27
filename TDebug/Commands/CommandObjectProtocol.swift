//
//  CommandObjectProtocol.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

protocol CommandObjectProtocol: class
{
    func CommandName() -> String
    func OperandType() -> String
    func CommandID() -> Int
    func CommandFormat() -> String
}

extension CommandObjectProtocol
{
    func CommandFormat() -> String
    {
        return ""
    }
    
    func CommandID() -> Int
    {
        return -1
    }
    
    func CommandName() -> String
    {
        return ""
    }
    
    func OperandType() -> String
    {
        return ""
    }
}
