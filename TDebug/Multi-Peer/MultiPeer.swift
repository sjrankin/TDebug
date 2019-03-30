//
//  MultiPeer.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import MultipeerConnectivity

/// Class that manages multi-peer communications.
/// [Multipeer-Connectivity](https://www.ralfebert.de/ios/tutorials/multipeer-connectivity/)
class MultiPeerManager: NSObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate
{
    private let TDebugServiceType = "debug-sink"
    private let PeerID = MCPeerID(displayName: UIDevice.current.name)
    private let ServiceAdvertiser: MCNearbyServiceAdvertiser!
    private let ServiceBrower: MCNearbyServiceBrowser!
    var Delegate: MultiPeerDelegate? = nil
    
    lazy var Session: MCSession =
        {
            let Session = MCSession(peer: self.PeerID, securityIdentity: nil, encryptionPreference: .required)
            Session.delegate = self
            return Session
    }()
    
    override init()
    {
        ServiceAdvertiser = MCNearbyServiceAdvertiser(peer: PeerID, discoveryInfo: nil, serviceType: TDebugServiceType)
        ServiceBrower = MCNearbyServiceBrowser(peer: PeerID, serviceType: TDebugServiceType)
        super.init()
        ServiceAdvertiser.delegate = self
        ServiceAdvertiser.startAdvertisingPeer()
        ServiceBrower.delegate = self
        ServiceBrower.startBrowsingForPeers()
        print("Started multi-peer advertising (ID: \(PeerID))")
    }
    
    deinit
    {
        ServiceAdvertiser.stopAdvertisingPeer()
        ServiceBrower.stopBrowsingForPeers()
    }
    
    private var _IsDebugHost: Bool = false
    public var IsDebugHost: Bool
    {
        get
        {
            return _IsDebugHost
        }
        set
        {
            _IsDebugHost = newValue
        }
    }
    
    func Broadcast(Message: String)
    {
        if Session.connectedPeers.count > 0
        {
            do
            {
                let EncodedMessage = MessageHelper.MakeMessage(Message, GetDeviceName())
                try Session.send(EncodedMessage.data(using: String.Encoding.utf8)!, toPeers: Session.connectedPeers, with: .reliable)
            }
            catch
            {
                print("Error broadcasting message: \(error.localizedDescription)")
            }
        }
    }
    
    func SendPreformatted(Message: String)
    {
        if Session.connectedPeers.count > 0
        {
            do
            {
                try Session.send(Message.data(using: String.Encoding.utf8)!, toPeers: Session.connectedPeers, with: .reliable)
            }
            catch
            {
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
    
    func Broadcast(Message: String, To: MCPeerID)
    {
        do
        {
            let EncodedMessage = MessageHelper.MakeMessage(Message, GetDeviceName())
            try Session.send(EncodedMessage.data(using: String.Encoding.utf8)!, toPeers: [To], with: .reliable)
        }
        catch
        {
            print("Error broadcasting message to \(To.displayName): \(error.localizedDescription)")
        }
    }
    
    func SendPreformatted(Message: String, To: MCPeerID)
    {
        do
        {
            try Session.send(Message.data(using: String.Encoding.utf8)!, toPeers: [To], with: .reliable)
        }
        catch
        {
            print("Error sending message to \(To.displayName): \(error.localizedDescription)")
        }
    }
    
    func GetPeerList() -> [MCPeerID]
    {
        return Session.connectedPeers
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error)
    {
        print("Error starting advertising service: \(error.localizedDescription)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void)
    {
        print("Received invitation from \(peerID)")
        invitationHandler(true, Session)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error)
    {
        print("Error starting service browser: \(error.localizedDescription)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?)
    {
        print("Found peer \(peerID) - inviting to session.")
        browser.invitePeer(peerID, to: Session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID)
    {
        print("Lost peer \(peerID)")
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState)
    {
        print("Peer \(peerID) changed state: \(state.rawValue)")
        Delegate?.ConnectedDeviceChanged(Manager: self, ConnectedDevices: Session.connectedPeers,
                                         Changed: peerID, NewState: state)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID)
    {
        let Message = String(data: data, encoding: .utf8)
        Delegate?.ReceivedData(Manager: self, Peer: peerID, RawData: Message!)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID)
    {
        print("Received stream data from \(peerID)")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress)
    {
        print("Started receiving resource from \(peerID)")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?)
    {
        print("Finished receiving resource from \(peerID)")
    }
    
    func GetDeviceName() -> String
    {
        if let TheName = TheDeviceName
        {
            return TheName
        }
        var SysInfo = utsname()
        uname(&SysInfo)
        let Name = withUnsafePointer(to: &SysInfo.nodename.0)
        {
            ptr in
            return String(cString: ptr)
        }
        let Parts = Name.split(separator: ".")
        TheDeviceName = String(Parts[0])
        return TheDeviceName!
    }
    
    var TheDeviceName: String? = nil
}
