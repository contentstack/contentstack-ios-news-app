//
//  Extensions.swift
//  csnews
//
//  Created by Nikhil Gohil on 11/09/15.
//  Copyright (c) 2015 Nikhil Gohil. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

extension UIViewController{
    
    func showTopMenu(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(UIViewController.menuClicked))
    }
    
    @objc func menuClicked() {
        toggleLeftMenu()
    }
    
    fileprivate func toggleLeftMenu(){
        if(self.slidingPanelController.sideDisplayed != .left){
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
            self.slidingPanelController!.openLeftPanel()
        }else {
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
            self.slidingPanelController!.closePanel()
        }
    }
    
    func showLoadingInView(_ view:UIView!){
        if(view == nil){
            return
        }
        
        let dimBackGroundView:UIView  = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        
        dimBackGroundView.backgroundColor = UIColor(white: 1, alpha: 1);
        let activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: dimBackGroundView.center.x-25, y: dimBackGroundView.center.y-25, width: 50, height: 50),
                                                            type: NVActivityIndicatorType.lineScale, color: UIColor(hexString: "#E44B4E")!)
        dimBackGroundView.addSubview(activityIndicatorView)
        dimBackGroundView.tag = 99;
        view.addSubview(dimBackGroundView)
        
        activityIndicatorView.startAnimating()
    }
    
    func hideLoadingInView(_ view:UIView!){
        if(view == nil){
            return
        }
        
        let dimBackGroundView:UIView? = view.viewWithTag(99)
        let activityIndicatorView:NVActivityIndicatorView = dimBackGroundView?.subviews[0] as! NVActivityIndicatorView
        activityIndicatorView.stopAnimating()
        dimBackGroundView!.removeFromSuperview()
    }
}
