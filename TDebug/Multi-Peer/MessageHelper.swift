//
//  MessageHelper.swift
//  TDDebug
//
//  Created by Stuart Rankin on 4/1/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
#if FOR_MACOS
import AppKit
#else
import UIKit
#endif

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
            //print("Split into incorrect number of parts: \(Parts.count), expected 2. Raw=\"\(Raw)\"")
            return nil
        }
        return (String(Parts[0]), String(Parts[1]))
    }
    
    public static func DecodeEncapsulatedCommand(_ Raw: String) -> (UUID, String)?
    {
        let Delimiter = String(Raw.first!)
        var Next = Raw
        Next.removeFirst()
        let Parts = Next.split(separator: String.Element(Delimiter))
        if Parts.count != 3
        {
            return nil
        }
        let (_, IDS) = DecodeKVP(String(Parts[1]), Delimiter: "=")!
        if let ID = UUID(uuidString: IDS)
        {
            return (ID, String(Parts[2]))
        }
        return nil
    }
    
    public static func DecodeHandShakeCommand(_ Raw: String) -> HandShakeCommands
    {
        let Delimiter = String(Raw.first!)
        var Next = Raw
        Next.removeFirst()
        let Parts = Next.split(separator: String.Element(Delimiter))
        if Parts.count != 2
        {
            return HandShakeCommands.Unknown
        }
        let SCmd = String(Parts[1])
        for (Command, Indicator) in HandShakeIndicators
        {
            if Indicator.lowercased() == SCmd.lowercased()
            {
                return Command
            }
        }
        return HandShakeCommands.Unknown
    }
    
    public static func DecodeSpecialCommand(_ Raw: String) -> SpecialCommands
    {
        let Delimiter = String(Raw.first!)
        var Next = Raw
        Next.removeFirst()
        let Parts = Next.split(separator: String.Element(Delimiter))
        if Parts.count != 2
        {
            return SpecialCommands.Unknown
        }
        let SCmd = String(Parts[1])
        for (Command, Indicator) in SpecialCommmandIndicators
        {
            if Indicator.lowercased() == SCmd.lowercased()
            {
                return Command
            }
        }
        return SpecialCommands.Unknown
    }
    
    public static func DecodeKVPMessage(_ Raw: String) -> (UUID?, String, String)
    {
        let Delimiter = String(Raw.first!)
        var Next = Raw
        Next.removeFirst()
        let Parts = Next.split(separator: String.Element(Delimiter))
        var PartsList = [(String, String)]()
        for Part in Parts
        {
            if let (Key, Value) = DecodeKVP(String(Part), Delimiter: "=")
            {
                PartsList.append((Key, Value))
            }
        }
        var IDs = ""
        var KeyValue = ""
        var ValueValue = ""
        for (Key, Value) in PartsList
        {
            switch Key
            {
            case "ID":
                IDs = Value
                
            case "Key":
                KeyValue = Value
                
            case "Value":
                ValueValue = Value
                
            default:
                break
            }
        }
        if let FinalID = UUID(uuidString: IDs)
        {
            return (FinalID, KeyValue, ValueValue)
        }
        return (nil, KeyValue, ValueValue)
    }
    
    public static func DecodeEchoMessage(_ Raw: String) -> (String, String, Int, Int)
    {
        //[Command, ReturnAddress, EchoMessage, EchoDelay, EchoCount]
        let Delimiter = String(Raw.first!)
        var Next = Raw
        Next.removeFirst()
        let Parts = Next.split(separator: String.Element(Delimiter))
        var PartsList = [(String, String)]()
        for Part in Parts
        {
            if let (Key, Value) = DecodeKVP(String(Part), Delimiter: "=")
            {
                PartsList.append((Key, Value))
            }
        }
        var Message = ""
        var EchoTo = ""
        var Delay = 1
        var Count = 1
        for (Key, Value) in PartsList
        {
            switch Key
            {
            case "Delay":
                if let D = Int(Value)
                {
                    Delay = D
                }
                
            case "Count":
                if let C = Int(Value)
                {
                    Count = C
                }
                
            case "Message":
                Message = Value
                
            case "EchoBackTo":
                EchoTo = Value
                
            default:
                break
            }
        }
        return (Message, EchoTo, Delay, Count)
    }
    
    //Format of command: command,address{,data}
    //returns command, address, text, fg color, bg color
    public static func DecodeIdiotLightMessage(_ Raw: String) ->(IdiotLightCommands, String, String?, OSColor?, OSColor?)
    {
        let Delimiter = String(Raw.first!)
        var Next = Raw
        Next.removeFirst()
        let Parts = Next.split(separator: String.Element(Delimiter))
        
        if Parts.count < 2
        {
            return (.Unknown, "", nil, nil, nil)
        }
        var PartsList = [(String, String)]()
        for Part in Parts
        {
            if let (Key, Value) = DecodeKVP(String(Part), Delimiter: "=")
            {
                PartsList.append((Key, Value))
            }
        }
        var Address = ""
        var Text: String? = nil
        var Command: IdiotLightCommands = .Unknown
        var BGColor: OSColor? = nil
        var FGColor: OSColor? = nil
        for Part in PartsList
        {
            switch Part.0
            {
            case "Address":
                Address = Part.1
                
            case "Enable":
                if Part.1.lowercased() == "yes"
                {
                    Command = .Enable
                }
                else
                {
                    Command = .Disable
                }
                break
                
            case "Text":
                Command = .SetText
                Text = Part.1
                
            case "BGColor":
                Command = .SetBGColor
                BGColor = OSColor(HexString: Part.1)!
                
            case "FGColor":
                Command = .SetFGColor
                FGColor = OSColor(HexString: Part.1)!
                
            default:
                continue
            }
        }
        return (Command, Address, Text, FGColor, BGColor)
    }
    
    public static func GetMessageType(_ Raw: String) -> MessageTypes
    {
        if Raw.isEmpty
        {
            return .Unknown
        }
        let Delimiter = String(Raw.first!)
        var Next = Raw
        Next.removeFirst()
        let Parts = Next.split(separator: String.Element(Delimiter))
        for Part in Parts
        {
            if Part.isEmpty
            {
                continue
            }
            let MessageType = MessageTypeFromID(String(Part))
            return MessageType
        }
        return .Unknown
    }
    
    public static func DecodeMessageEx(_ Raw: String) -> (String, MessageTypes, String, String, String)
    {
        if Raw.isEmpty
        {
            return ("", MessageTypes.Unknown, "", "", "")
        }
        let Delimiter = String(Raw.first!)
        var Next = Raw
        Next.removeFirst()
        let Parts = Next.split(separator: String.Element(Delimiter), maxSplits: 4, omittingEmptySubsequences: false)
        if Parts.count != 4
        {
            //Assume the last item in the parts list is the message and return it as an unknown type.
            return (Delimiter, MessageTypes.Unknown, "", "", String(Parts[Parts.count - 1]))
        }
        return (Delimiter, MessageTypeFromID(String(Parts[0])), String(Parts[1]), String(Parts[2]), String(Parts[3]))
    }
    
    public static func DecodeMessage(_ Raw: String) -> (MessageTypes, String, String, String)
    {
        let (_, MType, P1, P2, P3) = DecodeMessageEx(Raw)
        return (MType, P1, P2, P3)
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
        if Parts.count > 1
        {
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
        }
        return (NextExpeced, FinalPayload)
    }
    
    public static func DecodeIdiotLightCommand(_ Raw: String) -> (MessageTypes, String, String, String)
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
    
    private static func GetUnusedDelimiter(From: [[String]]) -> String
    {
        let FinalList = From.flatMap{$0}
        return GetUnusedDelimiter(From: FinalList)
    }
    
    private static let Delimiters = [",", ";", ".", "/", ":", "-", "_", "`", "~", "\"", "'", "$", "!", "\\", "¥", "°", "^", "·", "€", "‹", "›", "@"]
    
    private static func EncodeTextToSend(Message: String, DeviceName: String, Command: String) -> String
    {
        let Now = MakeTimeStamp(FromDate: Date())
        let Delimiter = GetUnusedDelimiter(From: [Now, Message, DeviceName, Command])
        let Final = AssembleCommand(FromParts: [Command, DeviceName, Now, Message], WithDelimiter: Delimiter)
        //let Final = Delimiter + Command + Delimiter + DeviceName + Delimiter + Now + Delimiter + Message
        return Final
    }
    
    public static func MakeMessage(WithType: MessageTypes, _ WithText: String, _ HostName: String) -> String
    {
        return EncodeTextToSend(Message: WithText, DeviceName: HostName,
                                Command: MessageTypeIndicators[WithType]!)
    }
    
    public static func MakeMessage(_ WithText: String, _ HostName: String) -> String
    {
        return EncodeTextToSend(Message: WithText, DeviceName: HostName,
                                Command: MessageTypeIndicators[.TextMessage]!)
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
        let MPayload = "Payload=\(Payload)"
        let Delimiter = GetUnusedDelimiter(From: [Message, MPayload])
        Message = Delimiter + Message + Delimiter + MPayload
        return MakeMessage(WithType: .Heartbeat, Message, HostName)
    }
    
    public static func MakeIdiotLightMessage(Address: String, State: UIFeatureStates) -> String
    {
        let Command = MessageTypeIndicators[.ControlIdiotLight]!
        let Addr = "Address=\(Address)"
        let Action = "Enable=" + [UIFeatureStates.Disabled: "No", UIFeatureStates.Enabled: "Yes"][State]!
        let Delimiter = GetUnusedDelimiter(From: [Command, Addr, Action])
        let Final = Delimiter + Command + Delimiter + Addr + Delimiter + Action
        return Final
    }
    
    public static func MakeIdiotLightMessage(Address: String, Text: String) -> String
    {
        let Command = MessageTypeIndicators[.ControlIdiotLight]!
        let Addr = "Address=\(Address)"
        let Action = "Text=" + Text
        let Delimiter = GetUnusedDelimiter(From: [Command, Addr, Action])
        let Final = Delimiter + Command + Delimiter + Addr + Delimiter + Action
        return Final
    }
    
    public static func MakeIdiotLightMessage(Address: String, FGColor: OSColor) -> String
    {
        let Command = MessageTypeIndicators[.ControlIdiotLight]!
        let Addr = "Address=\(Address)"
        let Action1 = "FGColor=" + FGColor.AsHexString()
        let Delimiter = GetUnusedDelimiter(From: [Command, Addr, Action1])
        let Final = Delimiter + Command + Delimiter + Addr + Delimiter + Action1
        return Final
    }
    
    public static func MakeIdiotLightMessage(Address: String, BGColor: OSColor) -> String
    {
        let Command = MessageTypeIndicators[.ControlIdiotLight]!
        let Addr = "Address=\(Address)"
        let Action1 = "BGColor=" + BGColor.AsHexString()
        let Delimiter = GetUnusedDelimiter(From: [Command, Addr, Action1])
        let Final = Delimiter + Command + Delimiter + Addr + Delimiter + Action1
        return Final
    }
    
    public static func MakeEchoMessage(Message: String, Delay: Int, Count: Int, Host: String) -> String
    {
        let Command = MessageTypeIndicators[.EchoMessage]!
        let ReturnAddress = "EchoBackTo=\(Host)"
        let EchoCount = "Count=\(Count)"
        let EchoDelay = "Delay=\(Delay)"
        let EchoMessage = "Message=\(Message)"
        let Delimiter = GetUnusedDelimiter(From: [Command, ReturnAddress, EchoCount, EchoDelay, EchoMessage])
        let Final = AssembleCommand(FromParts: [Command, ReturnAddress, EchoMessage, EchoDelay, EchoCount], WithDelimiter: Delimiter)
        return Final
    }
    
    public static func MakeKVPMessage(ID: UUID, Key: String, Value: String) -> String
    {
        let Command = MessageTypeIndicators[.KVPData]!
        let IDCmd = "ID=\(ID.uuidString)"
        let KeyString = "Key=\(Key)"
        let ValueString = "Value=\(Value)"
        let Delimiter = GetUnusedDelimiter(From: [Command, IDCmd, KeyString, ValueString])
        let Final = AssembleCommand(FromParts: [Command, IDCmd, KeyString, ValueString], WithDelimiter: Delimiter)
        return Final
    }
    
    public static func MakeSpcialCommand(_ Command: SpecialCommands) -> String
    {
        let Cmd = MessageTypeIndicators[.SpecialCommand]!
        let SCmd = SpecialCommmandIndicators[Command]!
        let Delimiter = GetUnusedDelimiter(From: [Cmd, SCmd])
        let Final = AssembleCommand(FromParts: [Cmd, SCmd], WithDelimiter: Delimiter)
        return Final
    }
    
    public static func MakeHandShake(_ Command: HandShakeCommands) -> String
    {
        let Cmd = MessageTypeIndicators[.HandShake]!
        let SCmd = HandShakeIndicators[Command]!
        let Delimiter = GetUnusedDelimiter(From: [Cmd, SCmd])
        let Final = AssembleCommand(FromParts: [Cmd, SCmd], WithDelimiter: Delimiter)
        return Final
    }
    
    public static func MakeGetCommandCount() -> String
    {
        return MessageTypeIndicators[.RequestCommandCount]!
    }
    
    /// Make a command string that requests a client command at the CommandIndexth position.
    ///
    /// - Parameter CommandIndex: Determines the client command to return.
    /// - Returns: Command string for retrieving the CommandIndexth client command.
    public static func MakeGetCommand(CommandIndex: Int) -> String
    {
        let Cmd = MessageTypeIndicators[.GetCommand]!
        let Payload = "Index=\(CommandIndex)"
        let Delimiter = GetUnusedDelimiter(From: [Cmd, Payload])
        let Final = AssembleCommand(FromParts: [Cmd, Payload], WithDelimiter: Delimiter)
        return Final
    }
    
    /// Make a command string returning the Indexth client command. Sent in response to a `MakeGetCommand` command string.
    ///
    /// - Parameters:
    ///   - Index: Index of the returned command - corresonds to the `CommandIndex` parameter in `MakeGetCommand`.
    ///   - Command: ID of the command.
    ///   - CommandName: Name of the command.
    ///   - Description: Description of the command.
    ///   - Parameters: List of parameter names.
    /// - Returns: String representing the client command returnable by multi-peer messaging.
    public static func MakeReturnCommandByIndex(Index: Int, Command: UUID, CommandName: String,
                                                Description: String, Parameters: [String]) -> String
    {
        let Cmd = MessageTypeIndicators[.CommandByIndex]!
        let SIndex = "Index=\(Index)"
        let CmdVal = "Command=\(Command.uuidString)"
        let CName = "Name=\(CommandName)"
        let CDesc = "Description=\(Description)"
        let PCount = "ParameterCount=\(Parameters.count)"
        var PList = [String]()
        for Param in Parameters
        {
            PList.append("Param=\(Param)")
        }
        let Delimiter = GetUnusedDelimiter(From: [[Cmd, SIndex, CmdVal, CName, CDesc, PCount], PList])
        let Final = AssembleCommandsEx(FromParts: [[Cmd, SIndex, CmdVal, CName, CDesc, PCount], PList], WithDelimiter: Delimiter)
        return Final
    }
    
    /// Make a string command to execute a client command in the client app on the remote system.
    ///
    /// - Parameters:
    ///   - CommandID: Client command ID.
    ///   - Parameters: List of tuples in the format (Parameter Name, Parameter Value).
    /// - Returns: String command to execute a client command.
    public static func MakeCommandForClient(CommandID: UUID, Parameters: [(String, String)]) -> String
    {
        let Cmd = MessageTypeIndicators[.SendCommandToClient]!
        let CmdID = "Command=\(CommandID)"
        let Count = "ParameterCount=\(Parameters.count)"
        var PList = [String]()
        for Param in Parameters
        {
            PList.append("\(Param.0)=\(Param.1)")
        }
        let Delimiter = GetUnusedDelimiter(From: [[Cmd, CmdID, Count], PList])
        let Final = AssembleCommandsEx(FromParts: [[Cmd, CmdID, Count], PList], WithDelimiter: Delimiter)
        return Final
    }
    
    /// Make a string command to return client command execution results to the caller.
    ///
    /// - Parameters:
    ///   - Result: Result of the client command execution (eg, true, false indicating success or failure of executing
    ///             the command).
    ///   - ReturnValue: The return value (if any) from the command execution. Not considered valid if `Result` in some
    ///                  way indicates a failure to execute the command.
    /// - Returns: String to send to the caller with the results of the client command execution.
    public static func MakeClientCommandResult(Result: String, ReturnValue: String) -> String
    {
        let Cmd = MessageTypeIndicators[.ClientCommandResult]!
        let SResult = "Result=\(Result)"
        let SValue = "Value=\(ReturnValue)"
        let Delimiter = GetUnusedDelimiter(From: [Cmd, SResult, SValue])
        let Final = AssembleCommand(FromParts: [Cmd, SResult, SValue], WithDelimiter: Delimiter)
        return Final
    }
    
    /// Make a command to return all client commands.
    public static func MakeGetAllClientCommands() -> String
    {
        return MessageTypeIndicators[.GetAllClientCommands]!
    }
    
    /// Make a command string returning all client commands.
    ///
    /// - Parameter Commands: The client command manager, populated with all supported client commands.
    /// - Returns: String with all client commands in the passed client command manager.
    public static func MakeAllClientCommands(Commands: ClientCommands) -> String
    {
        let CommandList = Commands.MakeCommandList()
        let Cmd = MessageTypeIndicators[.AllClientCommandsReturned]!
        let CmdCount = "Count=\(CommandList.count)"
        let Delimiter = GetUnusedDelimiter(From: [[Cmd, CmdCount], CommandList])
        let Final = AssembleCommandsEx(FromParts: [[Cmd, CmdCount], CommandList], WithDelimiter: Delimiter)
        return Final
    }
    
    /// Make an encapsulated command. Encapsulated commands are used to coordinate asynchronous commands with
    /// their asynchronous results.
    ///
    /// - Parameters:
    ///   - WithID: The asynchronous command ID - each time this is called, a different UIID should be used.
    ///   - Payload: The command to encapsulate.
    /// - Returns: Encpasulated command string.
    public static func MakeEncapsulatedCommand(WithID: UUID, Payload: String) -> String
    {
        let Cmd = MessageTypeIndicators[.IDEncapsulatedCommand]!
        let CmdID = "ID=\(WithID.uuidString)"
        let Delimiter = GetUnusedDelimiter(From: [Cmd, CmdID, Payload])
        let Final = AssembleCommand(FromParts: [Cmd, CmdID, Payload], WithDelimiter: Delimiter)
        return Final
    }
    
    /// Assemble the list of string into a command that can be sent to another TDebug instance or other app that implements
    /// at least the MultiPeerManager.
    ///
    /// - Note: The format of the returned string is Delimiter Part {Delimiter Part}. This is so the parsing code can easily
    ///         determine what the delimiter is to seperate the parts of the raw string into coherent parts.
    ///
    /// - Parameters:
    ///   - FromParts: List of parts of the command to assemble. Order is presevered.
    ///   - WithDelimiter: The delimiter to use to separate the parts from each other.
    /// - Returns: Command string that can be sent to another TDebug instance.
    static func AssembleCommand(FromParts: [String], WithDelimiter: String) -> String
    {
        var Final = ""
        for Part in FromParts
        {
            if Part.isEmpty
            {
                continue
            }
            Final = Final + WithDelimiter + Part
        }
        return Final
    }
    
    /// Assemble the list of string into a command that can be sent to another TDebug instance or other app that implements
    /// at least the MultiPeerManager.
    ///
    /// - Note: The format of the returned string is Delimiter Part {Delimiter Part}. This is so the parsing code can easily
    ///         determine what the delimiter is to seperate the parts of the raw string into coherent parts.
    ///
    /// - Parameters:
    ///   - FromParts: List of list of parts of the command to assemble. Order is presevered.
    ///   - WithDelimiter: The delimiter to use to separate the parts from each other.
    /// - Returns: Command string that can be sent to another TDebug instance.
    static func AssembleCommandsEx(FromParts: [[String]], WithDelimiter: String) -> String
    {
        let FinalList = FromParts.flatMap{$0}
        return AssembleCommand(FromParts: FinalList, WithDelimiter: WithDelimiter)
    }
    
    /// Given a message type ID in string format, return the actual message type.
    ///
    /// - Parameter Raw: Message type ID in string format.
    /// - Returns: MessageType enumeration on success, nil if not found.
    public static func MessageTypeFromString(_ Raw: String) -> MessageTypes?
    {
        if let FindMe = UUID(uuidString: Raw)
        {
            for (MType, RawString) in MessageTypeIndicators
            {
                let MID = UUID(uuidString: RawString)
                if MID == FindMe
                {
                    return MType
                }
            }
        }
        return nil
    }
    
    private static let MessageTypeIndicators: [MessageTypes: String] =
        [
            MessageTypes.TextMessage: "a8d8c35e-f638-47fe-8819-bd04d59c6989",
            MessageTypes.CommandMessage: "a11cac68-6298-4d21-bb84-8746ee544a7b",
            MessageTypes.ControlIdiotLight: "76d9f217-d2b8-4b65-93b4-182e4b38eab2",
            MessageTypes.EchoMessage: "9a904bd0-117b-4548-b31f-da2b4c3807dd",
            MessageTypes.Acknowledge: "73783e04-cad4-42a4-a3b3-449efcabf592",
            MessageTypes.Heartbeat: "5d8a38fd-878a-458f-aa80-62d810e520c1",
            MessageTypes.KVPData: "4c2805b8-d5ad-4c68-a5f8-1f554a90671a",
            MessageTypes.EchoReturn: "970bac64-f399-499d-8db6-c65e508ae40d",
            MessageTypes.SpecialCommand: "e83a5588-b285-49ee-b2fe-95f803f073b7",
            MessageTypes.HandShake: "52c4be7a-b84f-4812-880e-98b4c67543fb",
            MessageTypes.RequestCommandCount: "7eea42d3-7cda-4c4d-bb06-39b52f2cbac9",
            MessageTypes.GetCommand: "ec0d895a-2648-4db8-8d67-20be849edb32",
            MessageTypes.CommandByIndex: "37b02db4-f425-48a8-b6e7-7bbced7a0990",
            MessageTypes.SendCommandToClient: "9cfc1d01-f1f0-4d26-bb38-300ff3df0c92",
            MessageTypes.ClientCommandResult: "79726762-3eeb-450f-8c29-4701857a5073",
            MessageTypes.GetAllClientCommands: "582e3f52-a9ad-4ef3-8842-b8334a547500",
            MessageTypes.AllClientCommandsReturned: "6b3c2e18-879d-488e-b333-2d43eacb9c71",
            MessageTypes.IDEncapsulatedCommand: "c0e8487c-840a-4799-9d9d-906adb96f0a3",
            MessageTypes.Unknown: "dfc5b2d5-521b-46a8-b459-a4947089312c",
    ]
    
    private static let SpecialCommmandIndicators: [SpecialCommands: String] =
        [
            .ClearKVPList: "a1a4974c-ed8f-41bc-bdbf-49570f67cc03",
            .ClearLogList: "283c06c3-dca6-4044-a8ba-b034efd51594",
            .ClearIdiotLights: "1600bf5d-ffa7-474b-ab55-c8298f056969",
            .Unknown: "bbfb4205-d9f6-49cf-bd96-630641d4fb16",
    ]
    
    private static let HandShakeIndicators: [HandShakeCommands: String] =
        [
            .RequestConnection: "6dc88b50-15c0-41e0-aa6f-c1c33d93303b",
            .ConnectionGranted: "fceee865-ccdc-4c6b-8944-3a959a64d894",
            .ConnectionRefused: "b32f179c-c1b4-40c3-8bb0-ad84a985bad4",
            .ConnectionClose: "70b6f26c-92fc-423f-9ea4-418d51cc0528",
            .Disconnected: "78dfa276-48f3-47bc-88bc-4f46bd9f74ce",
            .Unknown: "1f9e85e3-446b-4c93-b93d-ea8d6955f4bb",
    ]
}

enum SpecialCommands: Int
{
    case ClearKVPList = 0
    case ClearLogList = 1
    case ClearIdiotLights = 2
    case Unknown = 10000
}

enum HandShakeCommands: Int
{
    case RequestConnection = 0
    case ConnectionGranted = 1
    case ConnectionRefused = 2
    case ConnectionClose = 3
    case Disconnected = 4
    case Unknown = 10000
}

enum MessageTypes: Int
{
    case TextMessage = 0
    case CommandMessage = 1
    case ControlIdiotLight = 2
    case EchoMessage = 3
    case Acknowledge = 4
    case Heartbeat = 5
    case KVPData = 6
    case EchoReturn = 7
    case SpecialCommand = 8
    case HandShake = 9
    case RequestCommandCount = 10
    case GetCommand = 11
    case CommandByIndex = 12
    case SendCommandToClient = 13
    case ClientCommandResult = 14
    case GetAllClientCommands = 15
    case AllClientCommandsReturned = 16
    case IDEncapsulatedCommand = 17
    case Unknown = 10000
}

enum UIFeatureStates: Int
{
    case Disabled = 0
    case Enabled = 1
}

enum IdiotLightCommands: Int
{
    case Disable = 0
    case Enable = 1
    case SetText = 2
    case SetFGColor = 3
    case SetBGColor = 4
    case Unknown = 10000
}
