//
//  MessageHelper.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class MessageHelper
{
    private static func DecodeKVP(_ Raw: String, Delimiter: String) -> (String, String)?
    {
        if Delimiter.isEmpty
        {
            print("Empty delimiter.")
            return nil
        }
        let Parts = Raw.split(separator: String.Element(Delimiter))
        if Parts.count != 2
        {
            print("Split into incorrect number of parts: \(Parts.count), expected 2.")
            return nil
        }
        return (String(Parts[0]), String(Parts[1]))
    }
    
    public static func DecodeMessage(_ Raw: String) -> (MessageTypes, String, String, String)
    {
        if Raw.isEmpty
        {
            return (MessageTypes.Unknown, "", "", "")
        }
        let Delimiter = String(Raw.first!)
        var Next = Raw
        Next.removeFirst()
        let Parts = Next.split(separator: String.Element(Delimiter), maxSplits: 4, omittingEmptySubsequences: false)
        if Parts.count != 4
        {
            //Assume the last item in the parts list is the message and return it as an unknown type.
            return (MessageTypes.Unknown, "", "", String(Parts[Parts.count - 1]))
        }
        return (MessageTypeFromID(String(Parts[0])), String(Parts[1]), String(Parts[2]), String(Parts[3]))
    }
    
    public static func DecodeHeartbeat(_ Raw: String) -> (Int, String?)?
    {
        if Raw.isEmpty
        {
            return nil
        }
        let Delimiter = String(Raw.first!)
        var Next = Raw
        Next.removeFirst()
        let Parts = Next.split(separator: String.Element(Delimiter), maxSplits: 2, omittingEmptySubsequences: false)
        var NextExpeced = 0
        if let (Key1, Value1) = DecodeKVP(String(Parts[0]), Delimiter: "=")
        {
            if Key1 == "Next"
            {
                if let NextIn = Int(Value1)
                {
                    NextExpeced = NextIn
                }
                else
                {
                    print("Invalid Next= value.")
                    return nil
                }
            }
        }
        else
        {
            print("Badly formed KVP.")
            return nil
        }
        var FinalPayload: String? = nil
        if String(Parts[1]).count > 0
        {
            if let (Key2, Value2) = DecodeKVP(String(Parts[1]), Delimiter: "=")
            {
                if (Key2 == "Payload")
                {
                    FinalPayload = Value2
                }
                else
                {
                    print("Unexpected key found: \(Key2)")
                    return nil
                }
            }
        }
        return (NextExpeced, FinalPayload)
    }
    
    public static func GetMessageType(_ Raw: String) -> MessageTypes
    {
        let (MType, _, _, _) = DecodeMessage(Raw)
        return MType
    }
    
    public static func MessageTypeFromID(_ RawID: String) -> MessageTypes
    {
        let FixedID = RawID.lowercased()
        for (SomeType, StringedID) in MessageTypeIndicators
        {
            if StringedID.lowercased() == FixedID
            {
                return SomeType
            }
        }
        return .Unknown
    }
    
    /// Create a time-stamp string from the passed date.
    ///
    /// - Parameters:
    ///   - FromDate: The date from which a string will be created.
    ///   - TimeSeparator: Separator to use for the time part.
    /// - Returns: String in the format: dd MMM yyyy HH:MM:SS
    public static func MakeTimeStamp(FromDate: Date, TimeSeparator: String = ":") -> String
    {
        let Cal = Calendar.current
        let Year = Cal.component(.year, from: FromDate)
        let Month = Cal.component(.month, from: FromDate)
        let MonthName = ["Zero", "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"][Month]
        let Day = Cal.component(.day, from: FromDate)
        let DatePart = "\(Year)-\(MonthName)-\(Day) "
        let Hour = Cal.component(.hour, from: FromDate)
        var HourString = String(describing: Hour)
        if Hour < 10
        {
            HourString = "0" + HourString
        }
        let Minute = Cal.component(.minute, from: FromDate)
        var MinuteString = String(describing: Minute)
        if Minute < 10
        {
            MinuteString = "0" + MinuteString
        }
        let Second = Cal.component(.second, from: FromDate)
        var Result = HourString + TimeSeparator + MinuteString
        var SecondString = String(describing: Second)
        if Second < 10
        {
            SecondString = "0" + SecondString
        }
        Result = Result + TimeSeparator + SecondString
        return DatePart + Result
    }
    
    private static func IsInString(_ InCommon: String, With: [String]) -> Bool
    {
        for SomeString in With
        {
            if SomeString.contains(InCommon)
            {
                return true
            }
        }
        return false
    }
    
    private static func GetUnusedDelimiter(From: [String]) -> String
    {
        for Delimiter in Delimiters
        {
            if !IsInString(Delimiter, With: From)
            {
                return Delimiter
            }
        }
        return "\u{2}"
    }
    
    private static let Delimiters = [",", ";", ".", "/", ":", "-", "_", "`", "~", "\"", "'", "$", "!", "\\", "¥", "°", "^", "·", "€", "‹", "›", "@"]
    
    private static func EncodeTextToSend(Message: String, DeviceName: String, Command: String) -> String
    {
        let Now = MakeTimeStamp(FromDate: Date())
        let Delimiter = GetUnusedDelimiter(From: [Now, Message, DeviceName, Command])
        let Final = Delimiter + Command + Delimiter + DeviceName + Delimiter + Now + Delimiter + Message
        return Final
    }
    
    public static func MakeMessage(WithType: MessageTypes, _ WithText: String, _ HostName: String) -> String
    {
        return EncodeTextToSend(Message: WithText, DeviceName: HostName, Command: MessageTypeIndicators[WithType]!)
    }
    
    public static func MakeMessage(_ WithText: String, _ HostName: String) -> String
    {
        return EncodeTextToSend(Message: WithText, DeviceName: HostName, Command: MessageTypeIndicators[.TextMessage]!)
    }
    
    public static func MakeHeartbeatMessage(NextExpectedIn: Int, _ HostName: String) -> String
    {
        let Delimiter = GetUnusedDelimiter(From: ["="])
        let Message = Delimiter + "Next=\(NextExpectedIn)"
        return MakeMessage(WithType: .Heartbeat, Message, HostName)
    }
    
    public static func MakeHeartbeatMessage(Payload: String, NextExpectedIn: Int, _ HostName: String) -> String
    {
        var Message = "Next=\(NextExpectedIn)"
        let Delimiter = GetUnusedDelimiter(From: ["="])
        Message = Delimiter + Message + Delimiter + "Payload=" + Payload
        return MakeMessage(WithType: .Heartbeat, Message, HostName)
    }
    
    private static let MessageTypeIndicators: [MessageTypes: String] =
        [
            MessageTypes.TextMessage: "a8d8c35e-f638-47fe-8819-bd04d59c6989",
            MessageTypes.CommandMessage: "a11cac68-6298-4d21-bb84-8746ee544a7b",
            MessageTypes.ControlIdiotLight: "76d9f217-d2b8-4b65-93b4-182e4b38eab2",
            MessageTypes.EchoMessage: "9a904bd0-117b-4548-b31f-da2b4c3807dd",
            MessageTypes.Acknowledge: "73783e04-cad4-42a4-a3b3-449efcabf592",
            MessageTypes.Heartbeat: "5d8a38fd-878a-458f-aa80-62d810e520c1",
            MessageTypes.Unknown: "dfc5b2d5-521b-46a8-b459-a4947089312c",
    ]
}

enum MessageTypes: Int
{
    case TextMessage = 0
    case CommandMessage = 1
    case ControlIdiotLight = 2
    case EchoMessage = 3
    case Acknowledge = 4
    case Heartbeat = 5
    case Unknown = 10000
}
