//
//  LogItem.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Contains one log item.
class LogItem
{
    /// Initializer. The ID and timestamp are generated automatically.
    ///
    /// - Parameter Text: The text of the item.
    init(Text: String)
    {
        _ID = UUID()
        Title = Comm.MakeTimeStamp(FromDate: Date())
        Message = Text
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - TimeStamp: Timestamp value.
    ///   - Text: Message value.
    init(TimeStamp: String, Text: String)
    {
        _ID = UUID()
        Title = TimeStamp
        Message = Text
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - TimeStamp: Timestamp value.
    ///   - Host: Name of the host where the message originated.
    ///   - Text: Message value.
    init(TimeStamp: String, Host: String, Text: String)
    {
        _ID = UUID()
        Title = TimeStamp
        Message = Text
        HostName = Host
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - ItemID: ID of the log item.
    ///   - TimeStamp: Timestamp value.
    ///   - Text: Message value.
    init(ItemID: UUID, TimeStamp: String, Text: String)
    {
        _ID = ItemID
        Title = TimeStamp
        Message = Text
    }
    
    private var _ID: UUID? = nil
    /// Get or set the ID of the log item.
    public var ID: UUID?
    {
        get
        {
            return _ID
        }
        set
        {
            _ID = newValue
        }
    }
    
    private var _Title: String = ""
    /// Get or set the title/time-stamp of the log item.
    public var Title: String
    {
        get
        {
            return _Title
        }
        set
        {
            _Title = newValue
        }
    }
    
    private var _Message: String = ""
    /// Get or set the contents/message of the log item.
    public var Message: String
    {
        get
        {
            return _Message
        }
        set
        {
            _Message = newValue
        }
    }
    
    private var _HostName: String? = nil
    public var HostName: String?
    {
        get
        {
            return _HostName
        }
        set
        {
            _HostName = newValue
        }
    }
    
    private var _FGColor: UIColor? = nil
    /// Get or set the foreground (eg, text) color. If nil, the default color is used.
    public var FGColor: UIColor?
    {
        get
        {
            return _FGColor
        }
        set
        {
            _FGColor = newValue
        }
    }
    
    private var _BGColor: UIColor? = nil
    /// Get or set the background color. If nil, the default color is used.
    public var BGColor: UIColor?
    {
        get
        {
            return _BGColor
        }
        set
        {
            _BGColor = newValue
        }
    }
    
    private var _DoAnimateBGColor: Bool = false
    public var DoAnimateBGColor: Bool
    {
        get
        {
            return _DoAnimateBGColor
        }
        set
        {
            _DoAnimateBGColor = newValue
        }
    }
    
    private var _BGAnimateColorDuration: Double = 2.0
    public var BGAnimateColorDuration: Double
    {
        get
        {
            return _BGAnimateColorDuration
        }
        set
        {
            _BGAnimateColorDuration = newValue
        }
    }
    
    private var _BGAnimateTargetColor: UIColor = UIColor.white
    public var BGAnimateTargetColor: UIColor
    {
        get
        {
            return _BGAnimateTargetColor
        }
        set
        {
            _BGAnimateTargetColor = newValue
        }
    }
    
    private var _HasAnimated: Bool = false
    public var HasAnimated: Bool
    {
        get
        {
            return _HasAnimated
        }
        set
        {
            _HasAnimated = newValue
        }
    }
}
