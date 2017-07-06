//
//  CategoryController.swift
//  csnews
//
//  Created by Nikhil Gohil on 06/07/17.
//  Copyright © 2017 Nikhil Gohil. All rights reserved.
//

import Foundation
import Contentstack

class CategoryController: UITableViewController {
    
    fileprivate var categoryList = [Entry]();
    fileprivate var categoryQuery:Query! = nil
    fileprivate var selectedRowIndex = 0
    fileprivate var isEnglish = true
    
    @IBOutlet weak var categoriesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.clearsSelectionOnViewWillAppear = false
        
        if(self.categoryList.count == 0){
            fetchAllCategories(true)
        }else {
            self.tableView.selectRow(at: IndexPath(row: selectedRowIndex, section: 0), animated: false, scrollPosition: UITableViewScrollPosition.top)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.categoryList.count>0 ? self.categoryList.count+1 : self.categoryList.count)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == 0){
            if(self.isEnglish){
                cell.textLabel?.text = NSLocalizedString("Top News", comment: "topnews in category")
            }else {
                cell.textLabel?.text = "मुख्य समाचार"
            }
        }else {
            let entry:Entry = self.categoryList[indexPath.row-1]
            cell.textLabel?.text = entry.title
        }
        
        cell.textLabel?.highlightedTextColor = UIColor.white
        
        cell.selectedBackgroundView = UIView(frame: cell.bounds)
        cell.selectedBackgroundView?.backgroundColor = UIColor.darkGray
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedRowIndex = indexPath.row
        let centerVC:UINavigationController =  self.slidingPanelController.centerViewController as! UINavigationController
        
        if(centerVC.topViewController!.isKind(of: TopNewsController.classForCoder())){
            let topNewsVC:TopNewsController =  centerVC.topViewController as! TopNewsController
            
            if (indexPath.row == 0){
                //show top news
                topNewsVC.fetchTopNews()
            }else {
                let entry:Entry = self.categoryList[indexPath.row-1]
                topNewsVC.fetchNewsOnCategory(entry)
            }
        }
        menuClicked()
    }
    
    func fetchAllCategories(_ isEnglish:Bool){
        
        self.isEnglish = isEnglish
        if(categoryQuery != nil){
            categoryQuery.cancelRequests()
        }
        categoryQuery = AppDelegate.sharedSite().contentType(withName: "category").query()
        
        categoryQuery.language(Language.ENGLISH_UNITED_STATES)
        
        if(!isEnglish){
            categoryQuery.language(Language.HINDI_INDIA)
        }
        
        categoryQuery.find { (responseType, result, error) -> Void in
            if(error != nil){
                print(error)
            }else {
                let entries:[(Entry)]! = result!.getResult() as! [(Entry)]
                if(entries != nil && entries.count > 0){
                    self.categoryList.removeAll(keepingCapacity: false)
                    for entry:Entry in (result!.getResult() as! [(Entry)]){
                        self.categoryList.append(entry)
                    }
                    self.tableView.reloadData()
                    
                    self.tableView.selectRow(at: IndexPath(row: self.selectedRowIndex, section: 0), animated: false, scrollPosition: UITableViewScrollPosition.top)
                }
                
                if(self.isEnglish){
                    self.categoriesLabel.text = "Categories"
                }else {
                    self.categoriesLabel.text = "श्रेणियाँ"
                }
            }
        }
    }
    
}
