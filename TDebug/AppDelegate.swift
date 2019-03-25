//
//  AppDelegate.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import UIKit

let kTDebugBonjourType = "_tdebug._tcp"

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate, NetServiceDelegate, StreamDelegate
{
    
    var window: UIWindow?
    var ServerStarted: Bool = false
    var Server: NetService? = nil
    var IStream: InputStream? = nil
    var OStream: OutputStream? = nil
    var StreamOpenCount: Int = 0
    var RegisteredName: String? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // Override point for customization after application launch.
        
        Server = NetService(domain: "local.", type: kTDebugBonjourType, name: UIDevice.current.name, port: 0)
        Server?.includesPeerToPeer = true
        Server?.delegate = self
        Server?.publish(options: NetService.Options.listenForConnections)
        
        return true
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
            let Message = String(bytes: Buffer, encoding: String.Encoding.utf8)
            print("Received message: \(Message!)")
            
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
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication)
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        CloseStreams()
        if !ServerStarted
        {
            Server?.publish(options: NetService.Options.listenForConnections)
            ServerStarted = true
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication)
    {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        assert(!ServerStarted)
        Server?.publish(options: NetService.Options.listenForConnections)
        ServerStarted = true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

