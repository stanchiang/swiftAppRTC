//
//  SARTCVideoChatViewController.swift
//  swiftAppRTC
//
//  Created by Stanley Chiang on 6/29/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import AVFoundation

class SARTCVideoChatViewController: UIViewController, ARDAppClientDelegate, RTCEAGLVideoViewDelegate {

    var SERVER_HOST_URL = "https://apprtc.appspot.com"
    
//    var remoteView:RTCEAGLVideoView = RTCEAGLVideoView()
//    var localView:RTCEAGLVideoView = RTCEAGLVideoView()
    
    @IBOutlet weak var remoteView: RTCEAGLVideoView!
    @IBOutlet weak var localView: RTCEAGLVideoView!
    
//    var footerView:UIView = UIView()
//    var urlLabel:UILabel = UILabel()
//    var buttonContainerView:UIView = UIView()
//    var audioButton:UIButton = UIButton()
//    var videoButton:UIButton = UIButton()
//    var hangupButton:UIButton = UIButton()
    
    var remoteViewTopConstraint:NSLayoutConstraint = NSLayoutConstraint()
    var remoteViewRightConstraint:NSLayoutConstraint = NSLayoutConstraint()
    var remoteViewLeftConstraint:NSLayoutConstraint = NSLayoutConstraint()
    var remoteViewBottomConstraint:NSLayoutConstraint = NSLayoutConstraint()
    var localViewWidthConstraint:NSLayoutConstraint = NSLayoutConstraint()
    var localViewHeightConstraint:NSLayoutConstraint = NSLayoutConstraint()
    var localViewRightConstraint:NSLayoutConstraint = NSLayoutConstraint()
    var localViewBottomConstraint:NSLayoutConstraint = NSLayoutConstraint()
//    var footerViewBottomConstraint:NSLayoutConstraint = NSLayoutConstraint()
    var buttonContainerViewLeftConstraint:NSLayoutConstraint = NSLayoutConstraint()
    
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isZoom = false
        isAudioMute = false
        isVideoMute = false
        
//        audioButton.layer.cornerRadius = 20.0
//        videoButton.layer.cornerRadius = 20.0
//        hangupButton.layer.cornerRadius = 20.0
        
        //Add Tap to hide/show controls
        var tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SARTCVideoChatViewController.toggleButtonContainer))
        tapGestureRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGestureRecognizer)
        
        //Add Double Tap to zoom
        tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(SARTCVideoChatViewController.zoomRemote))
        tapGestureRecognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(tapGestureRecognizer)
        
        //RTCEAGLVideoViewDelegate provides notifications on video frame dimensions
        remoteView.delegate = self
        localView.delegate = self
        
        //Getting Orientation change
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SARTCVideoChatViewController.orientationChanged(_:)), name: "UIDeviceOrientationDidChangeNotification", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        //Display the Local View full screen while connecting to Room
        localViewBottomConstraint.constant = 0.0
        localViewRightConstraint.constant = 0.0
        localViewHeightConstraint.constant = 0.0
        localViewWidthConstraint.constant = self.view.frame.size.height
        localViewHeightConstraint.constant = self.view.frame.size.width
//        footerViewBottomConstraint.constant = 0.0
        
        //Connect to the room
        disconnect()
        
        client = ARDAppClient(delegate: self)
        client?.serverHostUrl = SERVER_HOST_URL
        client?.connectToRoomWithId(roomName, options: nil)
        
//        urlLabel.text = roomUrl
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "UIDeviceOrientationDidChangeNotification", object: nil)
        disconnect()
    }
    
    func applicationWillResignActive(application: UIApplication) {
        disconnect()
    }
    
    func orientationChanged(notification: NSNotification){
        videoView(localView, didChangeVideoSize: localVideoSize)
        videoView(remoteView, didChangeVideoSize: remoteVideoSize)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func audioButtonPressed(sender: UIButton) {
        let audioButton:UIButton = sender
        if isAudioMute {
            client?.unmuteAudioIn()
            audioButton.setImage(UIImage(named: "audioOn"), forState: UIControlState.Normal)
            isAudioMute = false
        } else {
            client?.muteAudioIn()
            audioButton.setImage(UIImage(named: "audioOff"), forState: UIControlState.Normal)
            isAudioMute = true
        }

    }
    
//    func audioButtonPressed(sender: UIButton) {
//        let audioButton:UIButton = sender
//        if isAudioMute {
//            client?.unmuteAudioIn()
//            audioButton.setImage(UIImage(named: "audioOn"), forState: UIControlState.Normal)
//            isAudioMute = false
//        } else {
//            client?.muteAudioIn()
//            audioButton.setImage(UIImage(named: "audioOff"), forState: UIControlState.Normal)
//            isAudioMute = true
//        }
//    }
    
    func videoButtonPressed(sender: UIButton) {
        let videoButton = sender
        if isVideoMute {
            client?.swapCameraToFront()
            videoButton.setImage(UIImage(named: "videoOn"), forState: UIControlState.Normal)
            isVideoMute = false
        } else {
            client?.swapCameraToBack()
            isVideoMute = true
        }
    }
    
    func hangupButtonPressed(sender: UIButton) {
        disconnect()
        navigationController?.popViewControllerAnimated(true)
    }
    
    func zoomRemote() {
//        fill in
        isZoom = !isZoom
        videoView(remoteView, didChangeVideoSize: remoteVideoSize)
    }
    
    func disconnect() {
//        if (client != nil) {
//            if (localVideoTrack != nil) { localVideoTrack?.removeRenderer(localView) }
//            if (remoteVideoTrack != nil) { remoteVideoTrack?.removeRenderer(remoteView) }
//            localVideoTrack = nil
////            [self.localView renderFrame:nil];
//            remoteVideoTrack = nil
////            [self.remoteView renderFrame:nil];
//            client?.disconnect() //doesn't that make this a recursive mem leak?
//        }
    }
    
    func remoteDisconnected() {
        if (remoteVideoTrack != nil) {
            remoteVideoTrack?.removeRenderer(remoteView)
        }
        remoteVideoTrack = nil
//        [self.remoteView renderFrame:nil];
        videoView(localView, didChangeVideoSize: localVideoSize)
    }
    
    func toggleButtonContainer(){
        UIView.animateWithDuration(0.3) { 
            if self.buttonContainerViewLeftConstraint.constant <= -40.0 {
                self.buttonContainerViewLeftConstraint.constant = 20.0
//                self.buttonContainerView.alpha = 1.0
            } else {
                self.buttonContainerViewLeftConstraint.constant = -40.0
//                self.buttonContainerView.alpha = 0.0
            }
            self.view.layoutIfNeeded()
        }
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
        
        UIView.animateWithDuration(0.4) { 
            let orientation: UIDeviceOrientation = UIDevice.currentDevice().orientation
            var videoRect:CGRect = CGRectMake(0, 0, self.view.frame.size.width/4.0, self.view.frame.size.height/4.0)
            if orientation == UIDeviceOrientation.LandscapeLeft || orientation == UIDeviceOrientation.LandscapeRight {
                videoRect = CGRectMake(0, 0, self.view.frame.size.width/4.0, self.view.frame.size.width/4.0)
            }
            print("self.localView.frame  \(self.localView.frame)")
            let videoFrame:CGRect = AVMakeRectWithAspectRatioInsideRect(self.localView.frame.size, videoRect)
            self.localViewWidthConstraint.constant = videoFrame.size.width
            self.localViewHeightConstraint.constant = videoFrame.size.height
            
            self.localViewBottomConstraint.constant = 28.0
            self.localViewRightConstraint.constant = 28.0
//            self.footerViewBottomConstraint.constant = -80.0
            self.view.layoutIfNeeded()
        }
    }
    func appClient(client: ARDAppClient!, didError error: NSError!) {
        let alertView:UIAlertView = UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "Ok")
        alertView.show()
        disconnect()
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
                let videoFrame:CGRect = AVMakeRectWithAspectRatioInsideRect(aspectRatio, videoRect)
                
                //Resize the localView accordingly
                self.localViewWidthConstraint.constant = videoFrame.size.width
                self.localViewHeightConstraint.constant = videoFrame.size.height
                
                if (self.remoteVideoTrack != nil) {
                    self.localViewBottomConstraint.constant = 28.0
                    self.localViewRightConstraint.constant = 28.0
                } else {
                    self.localViewBottomConstraint.constant = containerHeight / 2.0 - videoFrame.size.height / 2.0 //center
                    self.localViewRightConstraint.constant = containerWidth / 2.0 - videoFrame.size.width / 2.0 // center
                }
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
                
                self.remoteViewTopConstraint.constant = containerHeight/2.0 - videoFrame.size.height/2.0
                self.remoteViewBottomConstraint.constant = containerHeight/2.0 - videoFrame.size.height/2.0
                self.remoteViewLeftConstraint.constant = containerHeight/2.0 - videoFrame.size.height/2.0
                self.remoteViewRightConstraint.constant = containerHeight/2.0 - videoFrame.size.height/2.0
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    
}
