//
//  MultiPeer.swift
//  TDebug
//
//  Created by Stuart Rankin on 3/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import MultipeerConnectivity

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
    
    func Send(Message: String)
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
        Delegate?.ConnectedDeviceChanged(Manager: self, ConnectedDevices: Session.connectedPeers.map{$0.displayName})
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID)
    {
        print("Received data from \(peerID)")
        let Message = String(data: data, encoding: .utf8)
        Delegate?.ReceivedData(Manager: self, RawData: Message!)
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
}
