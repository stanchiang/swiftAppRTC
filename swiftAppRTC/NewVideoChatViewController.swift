//
//  NewVideoChatViewController.swift
//  swiftAppRTC
//
//  Created by Stanley Chiang on 7/17/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import AVFoundation

class NewVideoChatViewController: UIViewController, ARDAppClientDelegate, RTCEAGLVideoViewDelegate {

    var SERVER_HOST_URL = "https://apprtc.appspot.com"

    var roomName:String!
    var roomUrl:String!
    var client:ARDAppClient?
    var localVideoTrack:RTCVideoTrack?
    var remoteVideoTrack:RTCVideoTrack?
    var localVideoSize:CGSize = CGSize()
    var remoteVideoSize:CGSize = CGSize()
    var isZoom:Bool = false
    
    var isAudioMute:Bool = false
    var isVideoMute:Bool = false
    
    var remoteView: RTCEAGLVideoView = RTCEAGLVideoView()
    var localView: RTCEAGLVideoView = RTCEAGLVideoView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        remoteView.translatesAutoresizingMaskIntoConstraints = false
        remoteView.delegate = self
        self.view.addSubview(remoteView)
        
        localView.translatesAutoresizingMaskIntoConstraints = false
        localView.delegate = self
        self.view.addSubview(localView)
        
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        remoteView.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor).active = true
        remoteView.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor).active = true
        remoteView.leadingAnchor.constraintEqualToAnchor(self.view.leadingAnchor).active = true
        remoteView.trailingAnchor.constraintEqualToAnchor(self.view.trailingAnchor).active = true
        
        localView.bottomAnchor.constraintEqualToAnchor(remoteView.bottomAnchor).active = true
        localView.trailingAnchor.constraintEqualToAnchor(remoteView.trailingAnchor).active = true
        localView.widthAnchor.constraintEqualToConstant(100).active = true
        localView.heightAnchor.constraintEqualToConstant(130).active = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        client = ARDAppClient(delegate: self)
        client?.serverHostUrl = SERVER_HOST_URL
        client?.connectToRoomWithId(roomName, options: nil)
    }
    
//ARDAppClientDelegate    
    func appClient(client: ARDAppClient!, didChangeState state: ARDAppClientState) {
        //        switch (state) {
        //            case kARDAppClientStateConnected:
        //                NSLog(@"Client connected.");
        //                break;
        //            case kARDAppClientStateConnecting:
        //                NSLog(@"Client connecting.");
        //                break;
        //            case kARDAppClientStateDisconnected:
        //                NSLog(@"Client disconnected.");
        //                [self remoteDisconnected];
        //                break;
        //        }
    }
    
    func appClient(client: ARDAppClient!, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack!) {
        if (self.localVideoTrack != nil) {
            self.localVideoTrack!.removeRenderer(localView)
            self.localVideoTrack = nil
            //            [self.localView renderFrame:nil];
        }
        self.localVideoTrack = localVideoTrack
        self.localVideoTrack?.addRenderer(localView)
    }

    func appClient(client: ARDAppClient!, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack!) {
        self.remoteVideoTrack = remoteVideoTrack
        self.remoteVideoTrack?.addRenderer(remoteView)
        
//        UIView.animateWithDuration(0.4) {
//            let orientation: UIDeviceOrientation = UIDevice.currentDevice().orientation
//            var videoRect:CGRect = CGRectMake(0, 0, self.view.frame.size.width/4.0, self.view.frame.size.height/4.0)
//            if orientation == UIDeviceOrientation.LandscapeLeft || orientation == UIDeviceOrientation.LandscapeRight {
//                videoRect = CGRectMake(0, 0, self.view.frame.size.width/4.0, self.view.frame.size.width/4.0)
//            }
//            print("self.localView.frame  \(self.localView.frame)")
//            let videoFrame:CGRect = AVMakeRectWithAspectRatioInsideRect(self.localView.frame.size, videoRect)
//            self.localViewWidthConstraint.constant = videoFrame.size.width
//            self.localViewHeightConstraint.constant = videoFrame.size.height
//            
//            self.localViewBottomConstraint.constant = 28.0
//            self.localViewRightConstraint.constant = 28.0
//            //            self.footerViewBottomConstraint.constant = -80.0
//            self.view.layoutIfNeeded()
//        }
    }
    
    func appClient(client: ARDAppClient!, didError error: NSError!) {
        let alertView:UIAlertView = UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "Ok")
        alertView.show()
    }
    
    //    RTCEAGLVideoViewDelegate
    func videoView(videoView: RTCEAGLVideoView!, didChangeVideoSize size: CGSize) {
        let orientation: UIDeviceOrientation = UIDevice.currentDevice().orientation
        UIView.animateWithDuration(0.4) {
            let containerWidth:CGFloat = self.view.frame.size.width
            let containerHeight:CGFloat = self.view.frame.size.height
            let defaultAspectRatio = CGSizeMake(4, 3)
            if videoView == self.localView {
                //Resize the Local View depending if it is full screen or thumbnail
                self.localVideoSize = size
                let aspectRatio:CGSize = CGSizeEqualToSize(size, CGSizeZero) ? defaultAspectRatio : size
                var videoRect:CGRect = self.view.bounds
                if (self.remoteVideoTrack != nil) {
                    videoRect = CGRectMake(0, 0, self.view.frame.size.width / 4.0, self.view.frame.size.height / 4.0)
                    if orientation == UIDeviceOrientation.LandscapeLeft || orientation == UIDeviceOrientation.LandscapeRight {
                        videoRect = CGRectMake(0, 0, self.view.frame.size.height / 4.0, self.view.frame.size.width / 4.0)
                    }
                }
//                let videoFrame:CGRect = AVMakeRectWithAspectRatioInsideRect(aspectRatio, videoRect)
//                
//                //Resize the localView accordingly
//                self.localViewWidthConstraint.constant = videoFrame.size.width
//                self.localViewHeightConstraint.constant = videoFrame.size.height
//                
//                if (self.remoteVideoTrack != nil) {
//                    self.localViewBottomConstraint.constant = 28.0
//                    self.localViewRightConstraint.constant = 28.0
//                } else {
//                    self.localViewBottomConstraint.constant = containerHeight / 2.0 - videoFrame.size.height / 2.0 //center
//                    self.localViewRightConstraint.constant = containerWidth / 2.0 - videoFrame.size.width / 2.0 // center
//                }
            } else if videoView == self.remoteView {
                //Resize Remote View
                self.remoteVideoSize = size
                let aspectRatio:CGSize = CGSizeEqualToSize(size, CGSizeZero) ? defaultAspectRatio : size
                let videoRect:CGRect = self.view.bounds
                var videoFrame:CGRect = AVMakeRectWithAspectRatioInsideRect(aspectRatio, videoRect)
                if self.isZoom == true {
                    //Set Aspect Fill
                    let scale:CGFloat
                    if containerWidth/videoFrame.size.width >= containerHeight/videoFrame.size.height {
                        scale = containerWidth/videoFrame.size.width
                    } else {
                        scale = containerHeight/videoFrame.size.height
                    }
                    videoFrame.size.width *= scale
                    videoFrame.size.height *= scale
                }
                
//                self.remoteViewTopConstraint.constant = containerHeight/2.0 - videoFrame.size.height/2.0
//                self.remoteViewBottomConstraint.constant = containerHeight/2.0 - videoFrame.size.height/2.0
//                self.remoteViewLeftConstraint.constant = containerHeight/2.0 - videoFrame.size.height/2.0
//                self.remoteViewRightConstraint.constant = containerHeight/2.0 - videoFrame.size.height/2.0
            }
            
            self.view.layoutIfNeeded()
        }
    }
}
