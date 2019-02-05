//
//  NewsDetailController.swift
//  csnews
//
//  Created by Nikhil Gohil on 06/07/17.
//  Copyright © 2017 Nikhil Gohil. All rights reserved.
//

import Foundation
import Contentstack

class NewsDetailController: UIViewController, UIWebViewDelegate {
    var newsArticle:Entry!
    
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var detailWebView: UIWebView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var webviewHeight: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Stack News", comment: "VC title")
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bannerImageView.superview!.bounds
        gradient.colors = [UIColor(hexString:"#C64B4E")!.cgColor, UIColor(hexString:"#C64B4E")!.cgColor]
        self.bannerImageView.superview!.layer.insertSublayer(gradient, at: 0)
        
        let gradientForImage: CAGradientLayer = CAGradientLayer()
        gradientForImage.frame = CGRect(x: 0, y: self.bannerImageView.bounds.height-130, width: self.bannerImageView.bounds.width, height: 130)
        gradientForImage.colors = [UIColor.clear.cgColor, UIColor(white: 0, alpha: 0.8).cgColor]
        self.bannerImageView.layer.insertSublayer(gradientForImage, at: 0)
        
        if (newsArticle != nil){
            
            if let bannerDict:[NSString: AnyObject] = (newsArticle["featured_image" as NSCopying] as? [NSString: AnyObject]) {
                if let imageURLString: String = bannerDict["url"] as? String {
                    self.bannerImageView.contentMode = UIView.ContentMode.scaleAspectFill
                    self.bannerImageView.clipsToBounds = true
                    let param: [AnyHashable: Any] = [
                        AnyHashable("width"): self.view.frame.size.width,
                        AnyHashable("height"): self.bannerImageView.frame.size.height,
                        AnyHashable("fit"): "crop"
                    ]
                    let url = URL(string: AppDelegate.sharedSite().imageTransform(withUrl: imageURLString, andParams: param))!
//                    let url = URL(string: imageURLString)!
                    self.bannerImageView.kf.setImage(with: url,
                                                     placeholder: nil,
                                                     options: [.transition(.fade(1))],
                                                     progressBlock: nil,
                                                     completionHandler: nil)
                }else{
                    self.bannerImageView.image = UIImage(named: "thumbImage");
                }
            }else {
                
                self.bannerImageView.image = nil;
            }
            
            self.titleLabel.text = newsArticle.title
            
            self.detailWebView.delegate = self
            self.detailWebView.scrollView.isScrollEnabled = false;
            
            if let body = newsArticle["body" as NSCopying] as? String {
                self.detailWebView.loadHTMLString(body, baseURL: nil)
            }
        }
        
        let categories:NSArray = newsArticle["category" as NSCopying] as! NSArray
        var category:String = ""
        categories.enumerateObjects({ (obj, index, stop) -> Void in
            let categoryDict:[NSString:AnyObject] = obj as! [NSString:AnyObject]
            category = categoryDict["title"] as! String
        })
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateStyle = DateFormatter.Style.medium
        let dtString = dateFormatter.string(from: newsArticle.updatedAt) as String
        
        self.categoryLabel.text = category + " | " + dtString
        
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webviewHeight.constant = webView.scrollView.contentSize.height
        self.view.layoutIfNeeded()
        
        let scrollView:UIScrollView = self.detailWebView.superview as! UIScrollView
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: webviewHeight.constant + 200)
    }
}
