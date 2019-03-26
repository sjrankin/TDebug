//
//  Comm.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Comm: NSObject, NetServiceDelegate, StreamDelegate
{
    static let kTDebugBonjourType = "_tdebug._tcp"
    var ServerStarted: Bool = false
    var Server: NetService? = nil
    var IStream: InputStream? = nil
    var OStream: OutputStream? = nil
    var StreamOpenCount: Int = 0
    var RegisteredName: String? = nil
    weak var CallerDelegate: CommDelegate? = nil
    
    override init()
    {
        super.init()
        print("Initializing Comm object.")
        Server = NetService(domain: "local.", type: Comm.kTDebugBonjourType, name: UIDevice.current.name, port: 0)
        Server?.includesPeerToPeer = true
        Server?.delegate = self
        Server?.publish(options: NetService.Options.listenForConnections)
    }
    
    func ConnectToRemote()
    {
        assert(Server != nil)
        assert(IStream == nil)
        assert(OStream == nil)
        if (Server?.getInputStream(&IStream, outputStream: &OStream))!
        {
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
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber])
    {
        assert(sender == Server)
    }
    
    func HandleEnteredForeground()
    {
        assert(!ServerStarted)
        Server?.publish(options: NetService.Options.listenForConnections)
        ServerStarted = true
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
