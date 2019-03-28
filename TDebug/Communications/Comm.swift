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
    var RemoteServers = [String]()
    
    override init()
    {
        super.init()
    }
    
    func Start()
    {
        print("Initializing Comm object.")
        Server = nil
        Server = NetService(domain: "local.", type: Comm.kTDebugBonjourType, name: UIDevice.current.name, port: Port)
        Server?.includesPeerToPeer = true
        Server?.delegate = self
        Server?.publish(options: NetService.Options.listenForConnections)
    }
    
    func SearchForServices(DelayDuration: Double = 2.0)
    {
        print("Initializing net service browser.")
        RemoteServers.removeAll()
        NetBrowser = NetServiceBrowser()
        NetBrowser.includesPeerToPeer = true
        NetBrowser.delegate = self
        NetBrowser.searchForServices(ofType: Comm.kTDebugBonjourType, inDomain: "local.")
        Delay(DelayDuration, closure: {self.NetBrowser.stop()})
        //NetBrowser.searchForBrowsableDomains()
    }
    
    func SearchForServices(Delegate: CommDelegate, DelayDuration: Double = 2.0) -> Bool
    {
        if AuxDelegate != nil
        {
            print("AuxDelegate in use.")
            return false
        }
        AuxDelegate = Delegate
        print("Initializing net service browser.")
        RemoteServers.removeAll()
        NetBrowser = NetServiceBrowser()
        NetBrowser.includesPeerToPeer = true
        NetBrowser.delegate = self
        
        NetBrowser.searchForServices(ofType: Comm.kTDebugBonjourType, inDomain: "local.")
        Delay(DelayDuration, closure: {self.NetBrowser.stop()})
        return true
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
    
    func ConnectToRemote()
    {
        assert(Server != nil)
        assert(IStream == nil)
        assert(OStream == nil)
        if (Server?.getInputStream(&IStream, outputStream: &OStream))!
        {
            print("Opening streams.")
            OpenStreams()
        }
    }
    
    func OpenStreams()
    {
        assert(IStream != nil)
        assert(OStream != nil)
        assert(StreamOpenCount == 0)
        
        IStream?.delegate = self
        IStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        IStream?.open()
        
        OStream?.delegate = self
        OStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        OStream?.open()
    }
    
    func CloseStreams()
    {
        assert((IStream != nil) == (OStream != nil))
        if IStream != nil
        {
            //If IStream isn't nil, then OStream is also not nil (as per the assert above).
            IStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
            IStream?.close()
            IStream = nil
            OStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
            OStream?.close()
            OStream = nil
        }
        StreamOpenCount = 0
    }
    
    /// Send a message to the remote host.
    ///
    /// - Parameter Message: The string message to send.
    func Send(Message: String)
    {
        if OStream!.hasSpaceAvailable
        {
            let Buffer: [UInt8] = Array(Message.utf8)
            let BufferPointer = UnsafePointer(Buffer)
            let Written = OStream?.write(BufferPointer, maxLength: Buffer.count)
            if Written != Buffer.count
            {
                //Is this bad?
            }
        }
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event)
    {
        switch eventCode
        {
        case Stream.Event.openCompleted:
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
            break
            
        case Stream.Event.hasBytesAvailable:
            var Buffer = [UInt8](repeating: 0, count: 1024)
            let BufferPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: Buffer.count)
            BufferPointer.initialize(from: &Buffer, count: Buffer.count)
            let BytesRead = IStream?.read(BufferPointer, maxLength: Buffer.count)
            if let Message = String(bytes: Buffer, encoding: String.Encoding.utf8)
            {
                print("Received message: \(Message)")
                CallerDelegate?.RawDataReceived(Message, BytesRead!)
            }
            
        default:
            break
        }
    }
    
    func netServiceDidPublish(_ sender: NetService)
    {
        assert(sender == Server)
        RegisteredName = Server?.name
        print("RegisteredName=\(RegisteredName!)")
        SearchForServices()
    }
    
    func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: OutputStream)
    {
        OperationQueue.current!.addOperation(
            {
                assert(sender == self.Server)
                print("Accepted connection: Host=\(sender.hostName!).")
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
            print("Found self.")
            return
        }
        print("Found: \(service.name) in domain \(service.domain) on host \(service.hostName ?? "{unknown}")")
        RemoteServers.append(service.name)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFindDomain domainString: String, moreComing: Bool)
    {
        print("Found domain: \(domainString)")
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber])
    {
        let NSServicesErrorCode: Int = Int(truncating: errorDict["NSNetServicesErrorCode"]!)
        let NSDomainErrorCode: Int = Int(truncating: errorDict["NSNetServicesErrorDomain"]!)
        print("Error searching from net service browser. Code=\(NSServicesErrorCode), Domain Error=\(NSDomainErrorCode)")
    }
    
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser)
    {
        print("Started searching.")
    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser)
    {
        print("Stopped searching.")
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
            print("Server restarted.")
        }
    }
    
    func HandleEnteredBackground()
    {
        CloseStreams()
        if !ServerStarted
        {
            Server?.publish(options: NetService.Options.listenForConnections)
            ServerStarted = true
        }
    }
}
