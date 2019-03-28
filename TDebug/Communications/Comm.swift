//
//  Comm.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Comm: NSObject, NetServiceDelegate, NetServiceBrowserDelegate, StreamDelegate
{
    let NSNetServicesUnknownError = -72000
    let NSNetServicesCollisionError = -72001
    let NSNetServicesNotFoundError = -72002
    let NSNetServicesActivityInProgress = -72003
    let NSNetServicesBadArgumentError = -72004
    let NSNetServicesCancelledError = -72005
    let NSNetServicesInvalidError = -72006
    let NSNetServicesTimeoutError = -72007
    static let kTDebugBonjourType = "_tdebug._tcp"
    var ServerStarted: Bool = false
    var Server: NetService? = nil
    var IStream: InputStream? = nil
    var OStream: OutputStream? = nil
    var StreamOpenCount: Int = 0
    var RegisteredName: String? = nil
    var NetBrowser: NetServiceBrowser!
    weak var CallerDelegate: CommDelegate? = nil
    weak var AuxDelegate: CommDelegate? = nil
    var RemoteServers = [(String, NetService)]()
    var DeviceName: String = "{unknown}"
    
    /// Initializer.
    init(Name: String)
    {
        super.init()
        DeviceName = Name
        Reset(From: "init")
    }
    
    /// Reset the class to its initial state.
    func Reset(From: String)
    {
        print("\(DeviceName): Reset Comm called from \(From)")
        Server = nil
        ServerStarted = false
        IStream = nil
        OStream = nil
        StreamOpenCount = 0
        RegisteredName = nil
        NetBrowser = nil
        AuxDelegate = nil
        RemoteServers.removeAll()
    }
    
    /// Start the server.
    func Start()
    {
        print("\(DeviceName): Initializing Comm/server object.")
        CloseStreams()
        Server = nil
        Server = NetService(domain: "local.", type: Comm.kTDebugBonjourType, name: UIDevice.current.name, port: Port)
        Server?.includesPeerToPeer = true
        Server?.delegate = self
        Server?.publish(options: NetService.Options.listenForConnections)
        ServerStarted = true
        print("\(DeviceName): Server started.")
    }
    
    func SearchForServices(DelayDuration: Double = 2.0)
    {
        print("\(DeviceName): Initializing net service browser with delay of \(DelayDuration) seconds.")
        RemoteServers.removeAll()
        NetBrowser = NetServiceBrowser()
        NetBrowser.includesPeerToPeer = true
        NetBrowser.delegate = self
        NetBrowser.searchForServices(ofType: Comm.kTDebugBonjourType, inDomain: "local.")
        Delay(DelayDuration, closure: {self.NetBrowser.stop()})
    }
    
    func SearchForServices(Delegate: CommDelegate, DelayDuration: Double = 2.0) -> Bool
    {
        if AuxDelegate != nil
        {
            print("\(DeviceName): AuxDelegate in use.")
            return false
        }
        AuxDelegate = Delegate
        print("\(DeviceName): Initializing net service browser with auxiliary delegate with delay of \(DelayDuration) seconds.")
        RemoteServers.removeAll()
        NetBrowser = NetServiceBrowser()
        NetBrowser.includesPeerToPeer = true
        NetBrowser.delegate = self
        NetBrowser.searchForServices(ofType: Comm.kTDebugBonjourType, inDomain: "local.")
        Delay(DelayDuration, closure: {self.NetBrowser.stop()})
        return true
    }
    
    func SearchForDomains(DelayDuration: Double = 5.0)
    {
        if AuxDelegate != nil
        {
            print("\(DeviceName): AuxDelegate in use.")
            return
        }
        NetBrowser = NetServiceBrowser()
        NetBrowser.includesPeerToPeer = true
        NetBrowser.delegate = self
        NetBrowser.searchForBrowsableDomains()
        Delay(DelayDuration, closure: {self.NetBrowser.stop()})
    }
    
    //https://stackoverflow.com/questions/42717027/ios-bonjour-swift-3-search-never-stops
    func Delay(_ Duration: Double, closure: @escaping () -> ())
    {
        let When = DispatchTime.now() + Duration
        DispatchQueue.main.asyncAfter(deadline: When, execute: closure)
    }
    
    func AuxIsBusy() -> Bool
    {
        return AuxDelegate != nil
    }
    
    private var _Port: Int32 = 0
    /// Get or set the port to use. In general, don't change this property.
    public var Port: Int32
    {
        get
        {
            return _Port
        }
        set
        {
            _Port = newValue
        }
    }
    
    func ConnectToRemote(_ Remote: NetService)
    {
        print("Connecting to remote server: \(Remote.name)")
        if IStream != nil || OStream != nil
        {
            CloseStreams()
        }
        var InS: InputStream!
        var OutS: OutputStream!
        if Remote.getInputStream(&InS, outputStream: &OutS)
        {
            IStream = InS
            OStream = OutS
            OpenStreams()
        }
        else
        {
            print("\(DeviceName): Error getting remote server streams. Restarting.")
            Start()
        }
    }
    
    /// Open the input and output streams.
    func OpenStreams()
    {
        print("\(DeviceName): Opening streams.")
        assert(IStream != nil)
        assert(OStream != nil)
        assert(StreamOpenCount == 0)
        
        IStream?.delegate = self
        IStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.common)
        IStream?.open()
        
        OStream?.delegate = self
        OStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.common)
        OStream?.open()
    }
    
    /// Close the input and output streams. If the streams are already closed, do nothing.
    func CloseStreams()
    {
        print("\(DeviceName): Closing streams.")
        if let IS = IStream
        {
            IS.remove(from: RunLoop.current, forMode: RunLoop.Mode.common)
            IS.close()
            IStream = nil
        }
        if let OS = OStream
        {
            OS.remove(from: RunLoop.current, forMode: RunLoop.Mode.common)
            OS.close()
            OStream = nil
        }
        StreamOpenCount = 0
    }
    
    func SplitMessage(_ Raw: String) -> (String, String, String)
    {
        if Raw.isEmpty
        {
            return ("", "", "")
        }
        let Delimiter = String(Raw.first!)
        let Parts = Raw.split(separator: String.Element(Delimiter), maxSplits: 3, omittingEmptySubsequences: true)
        if Parts.count != 3
        {
            //Assume the last item in the parts list is the message and return only it.
            return ("", "", String(Parts[Parts.count - 1]))
        }
        return (String(Parts[0]), String(Parts[1]), String(Parts[2]))
    }
    
    func IsInString(_ InCommon: String, With: [String]) -> Bool
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
    
    func GetUnusedDelimiter(From: [String]) -> String
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
    
    let Delimiters = [",", ";", ".", "/", ":", "-", "_", "`", "~", "\"", "'", "$", "!", "\\", "¥", "°", "^", "·", "€", "‹", "›", "@"]
    
    func MakeMessageWithHeader(_ WithMessage: String) -> String
    {
        let Part1 = DeviceName
        let Part2 = Comm.MakeTimeStamp(FromDate: Date())
        let Part3 = WithMessage
        let Delimiter = GetUnusedDelimiter(From: [Part1, Part2, Part3])
        let Final = Delimiter + Part1 + Delimiter + Part2 + Delimiter + Part3
        return Final
    }
    
    /// Send a message to the remote host.
    ///
    /// - Parameter Message: The string message to send.
    func Send(Message: String)
    {
        print("\(DeviceName): Sending message to remote server.")
        let Final = MakeMessageWithHeader(Message)
        let Buffer: [UInt8] = Array(Final.utf8)
        if Buffer.count < 1
        {
            print("\(DeviceName): Empty message attempted to be sent to remote system.")
            return
        }
        let BufferPointer = UnsafePointer(Buffer)
        print("\(DeviceName): Sending \(Final): \(Buffer.count) bytes")
        let Written: Int = (OStream?.write(BufferPointer, maxLength: Buffer.count))!
        if Written == -1
        {
            print("\(DeviceName): Write error: \(OStream!.streamError!.localizedDescription)")
            return
        }
        if Written == 0
        {
            print("\(DeviceName): OutputStream at capacity.")
        }
        print("\(DeviceName): Wrote \(Written) bytes. Source size=\(Message.count)")
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event)
    {
        let IsInputStream = aStream == IStream
        print("\(DeviceName): Stream event code: \(eventCode), IsInput: \(IsInputStream)")
        switch eventCode
        {
        case Stream.Event.openCompleted:
            print("\(DeviceName): Stream.Event.openCompleted")
            StreamOpenCount = StreamOpenCount + 1
            assert(StreamOpenCount <= 2)
            if StreamOpenCount == 2
            {
                //If we have the input and output streams, we no longer need the
                //server so stop it.
                Server?.stop()
                ServerStarted = false
                RegisteredName = nil
            }
            
        case Stream.Event.hasSpaceAvailable:
            print("\(DeviceName): Stream.Event.hasSpaceAvailable")
            break
            
        case Stream.Event.hasBytesAvailable:
            //Receive data here.
            if let IsIn = aStream as? InputStream
            {
                //https://stackoverflow.com/questions/42561020/reading-an-inputstream-into-a-data-object
                print("\(DeviceName): Stream.Event.hasBytesAvailable")
                let Buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
                var ByteCount: Int = 0
                while IsIn.hasBytesAvailable
                {
                     ByteCount = IsIn.read(Buffer, maxLength: 1024)
                    if ByteCount == -1
                    {
                        print("Error reading InputBuffer: \(IsIn.streamError!.localizedDescription)")
                    }
                }
                var Message = String(cString: Buffer)
                //String(cString) sometimes seems to pad extraneous characters/junk to the end of the string so we
                //need to check how many bytes the InputStream things it sent versus the number of characters
                //String(cString) is and truncate the result of String(cString) if needed. This raises the question:
                //does String(cString) also report too _few_ characters?
                let ExtraneousCharacterCount = Message.count - ByteCount
                if ExtraneousCharacterCount > 0
                {
                    Message.removeLast(ExtraneousCharacterCount)
                    print("Fixed message length (reduced by \(ExtraneousCharacterCount) characters.")
                }
                Buffer.deallocate()
                print("\(DeviceName): Received message: \"\(Message)\", bytes read: \(ByteCount), string count: \(Message.count)")
                CallerDelegate?.RawDataReceived(Message, ByteCount)
                Start()
            }
            
        case Stream.Event.errorOccurred:
            let Error: String = aStream.streamError!.localizedDescription
            print("\(DeviceName): Stream.Event.errorOccurred: \(Error)")
            
        case Stream.Event.endEncountered:
            print("\(DeviceName): Stream.Event.endEncountered")
            
        default:
            print("\(DeviceName): Unhandled event: \(eventCode)")
            break
        }
    }
    
    func netServiceDidPublish(_ sender: NetService)
    {
        print("\(DeviceName): At netServiceDidPublish")
        assert(sender == Server)
        RegisteredName = Server?.name
        print("\(DeviceName): RegisteredName=\(RegisteredName!)")
        //SearchForServices()
    }
    
    func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: OutputStream)
    {
        OperationQueue.current!.addOperation(
            {
                assert(sender == self.Server)
                print("\(self.DeviceName): Accepted connection.")
                assert((self.IStream != nil) == (self.OStream != nil))
                if self.IStream != nil
                {
                    inputStream.open()
                    inputStream.close()
                    outputStream.open()
                    outputStream.close()
                }
                else
                {
                    self.Server?.stop()
                    self.ServerStarted = false
                    self.RegisteredName = nil
                    self.IStream = inputStream
                    self.OStream = outputStream
                    self.OpenStreams()
                }
            }
        )
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool)
    {
        if service.name == RegisteredName
        {
            print("\(DeviceName): Found self.")
            return
        }
        print("\(DeviceName): Found: \(service.name) in domain \(service.domain) on host \(service.hostName ?? "{unknown}")")
        RemoteServers.append((service.name, service))
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFindDomain domainString: String, moreComing: Bool)
    {
        print("\(DeviceName): Found domain: \(domainString)")
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber])
    {
        let NSServicesErrorCode: Int = Int(truncating: errorDict["NSNetServicesErrorCode"]!)
        let NSDomainErrorCode: Int = Int(truncating: errorDict["NSNetServicesErrorDomain"]!)
        print("\(DeviceName): Error searching from net service browser. Code=\(NSServicesErrorCode), Domain Error=\(NSDomainErrorCode)")
    }
    
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser)
    {
        print("\(DeviceName): Started searching.")
    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser)
    {
        print("\(DeviceName): Stopped searching.")
        if AuxDelegate != nil
        {
            AuxDelegate?.RemoteServerList(RemoteServers)
            AuxDelegate = nil
        }
        else
        {
            CallerDelegate?.RemoteServerList(RemoteServers)
        }
    }
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber])
    {
        assert(sender == Server)
    }
    
    func HandleEnteredForeground()
    {
        if !ServerStarted
        {
            Start()
            print("\(DeviceName): Server restarted.")
        }
    }
    
    func HandleEnteredBackground()
    {
        CloseStreams()
        if let CurrentServer = Server
        {
            CurrentServer.stop()
            ServerStarted = false
            RegisteredName = nil
        }
    }
}
