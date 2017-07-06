//
//  NewsCell.swift
//  csnews
//
//  Created by Nikhil Gohil on 24/09/15.
//  Copyright (c) 2015 Nikhil Gohil. All rights reserved.
//

import Foundation
import Kingfisher
import Contentstack

class NewsCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bannerImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func loadContent(_ entry:Entry){
        self.titleLabel.text = entry.title
        
        var category:String = ""
        
        let categories:NSArray = entry["category" as NSCopying] as! NSArray
        
        categories.enumerateObjects({ (obj, index, stop) -> Void in
            let categoryDict:[NSString:AnyObject] = obj as! [NSString:AnyObject]
            category = categoryDict["title"] as! String
        })
        
        self.categoryLabel.text = category
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateStyle = DateFormatter.Style.medium
        let dtString = dateFormatter.string(from: entry.updatedAt) as String
        
        self.dateLabel.text = dtString
        self.bannerImageView.backgroundColor = UIColor.darkGray
        
        if let bannerDict:[NSString: AnyObject] = (entry["thumbnail" as NSCopying] as? [NSString: AnyObject]) {
            if let imageURLString: String = bannerDict["url"] as? String {
                self.bannerImageView.contentMode = UIViewContentMode.scaleAspectFill
                self.bannerImageView.clipsToBounds = true
                
                let url = URL(string: imageURLString)!
                self.bannerImageView.kf.setImage(with: url,
                                                 placeholder: nil,
                                                 options: [.transition(.fade(1))],
                                                 progressBlock: nil,
                                                 completionHandler: nil)
            }else{
                self.bannerImageView.image = UIImage(named: "thumbImage");
            }
        }else {
            self.bannerImageView.image = UIImage(named: "thumbImage");
        }
        
    }
}
