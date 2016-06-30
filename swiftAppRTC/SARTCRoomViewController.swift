//
//  ViewController.swift
//  swiftAppRTC
//
//  Created by Stanley Chiang on 6/29/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit

class SARTCRoomViewController: UIViewController {

    let titleLabel = UILabel(frame: CGRectMake(20, 120, 200, 50))
    let roomNumberField = UITextField(frame: CGRectMake(20, 170, 200, 50))
    let joinButton = UIButton(frame: CGRectMake(20, 220, 200, 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.whiteColor()
        
        
        titleLabel.text = "Please enter a room name"
        self.view.addSubview(titleLabel)
        
        roomNumberField.layer.borderColor = UIColor.blackColor().CGColor
        roomNumberField.layer.borderWidth = 1
        self.view.addSubview(roomNumberField)
        
        joinButton.addTarget(self, action: #selector(SARTCRoomViewController.joinButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        joinButton.backgroundColor = UIColor.blueColor()
        joinButton.setTitle("join", forState: UIControlState.Normal)
        self.view.addSubview(joinButton)
        
    }
    
    func joinButtonTapped(sender:UIButton) {        
        let vc:SARTCVideoChatViewController = SARTCVideoChatViewController()
        vc.roomName = roomNumberField.text!
        vc.roomUrl = "https://apprtc.appspot.com/r/\(roomNumberField.text!)"
        navigationController?.pushViewController(vc, animated: true)
        self.roomNumberField.resignFirstResponder()
    }
    
}

