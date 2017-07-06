//
//  TopNews.swift
//  csnews
//
//  Created by Nikhil Gohil on 06/07/17.
//  Copyright © 2017 Nikhil Gohil. All rights reserved.
//

import Foundation
import Kingfisher
import Contentstack

class TopNewsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    fileprivate var bannerNewsList = [Entry]();
    fileprivate var topNewsArticles = [Entry]();
    fileprivate var newsArticles = [Entry]();
    
    fileprivate var topNewsQuery:Query! = nil
    fileprivate var allNewsByCategoryQuery:Query! = nil
    
    @IBOutlet weak var bannerTitleLabel: UILabel!
    @IBOutlet weak var bannerCategoryLabel: UILabel!
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let refreshControl = UIRefreshControl()
    
    fileprivate var highlitedIndex:Int = 0
    fileprivate var currentIndex:Int = 0
    fileprivate var selectedCategory:String = ""
    fileprivate var selectedCategoryUId:String = ""
    fileprivate var isTopNews:Bool = true
    fileprivate var bannerTimer:Timer! = nil
    
    fileprivate var defaultSiteLanguage:LanguageType = LanguageType.english
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Stack News", comment: "VC title")
        
        bannerImage.superview?.isHidden = true;
        
        self.tableView.estimatedRowHeight = 110
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        showTopMenu()
        
        self.refreshControl.addTarget(self, action: #selector(TopNewsController.refresh(_:)), for: .valueChanged)
        self.refreshControl.tintColor = UIColor(hexString: "#E44B4E")
        self.tableView.addSubview(self.refreshControl)
        
        // Do any additional setup after loading the view, typically from a nib.
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = bannerImage.superview!.bounds
        gradient.colors = [UIColor(hexString:"#C64B4E")!.cgColor, UIColor(hexString:"#C64B4E")!.cgColor]
        bannerImage.superview!.layer.insertSublayer(gradient, at: 0)
        
        let gradientForImage: CAGradientLayer = CAGradientLayer()
        gradientForImage.frame = CGRect(x: 0, y: self.bannerImage.bounds.height-130, width: bannerImage.bounds.width, height: 130)
        gradientForImage.colors = [UIColor.clear.cgColor, UIColor(white: 0, alpha: 0.8).cgColor]
        bannerImage.layer.insertSublayer(gradientForImage, at: 0)
        
        self.slidingPanelController.leftPanelController.viewDidLoad()
        
        self.refresh(nil)
        
    }
    
    func refresh(_ refreshControl:UIRefreshControl!) {
        
        if(refreshControl == nil){
            self.enableNavigationButtons(false)
            
            self.showLoadingInView(self.view)
            let netCallsGroup:DispatchGroup = DispatchGroup()
            self.isTopNews = true;
            self.fetchNews(netCallsGroup, categoryEntry:nil, isTopNews:self.isTopNews)
            
            netCallsGroup.notify(queue: DispatchQueue.main) { () -> Void in
                self.filterBannerNews(false)
                self.tableView.reloadData()
                self.hideLoadingInView(self.view)
                
                self.enableNavigationButtons(true)
            }
            
        }else {
            self.fetchNews(nil, categoryEntry:nil, isTopNews:self.isTopNews)
        }
    }
    
    func enableNavigationButtons(_ enable:Bool){
        self.navigationItem.leftBarButtonItem?.isEnabled = enable
        self.navigationItem.rightBarButtonItem?.isEnabled = enable
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:NewsCell = tableView.dequeueReusableCell(withIdentifier: "topNewsCell", for: indexPath) as! NewsCell
        return cell;
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let entry:Entry! = self.newsArticles[indexPath.row]
        let newsCell:NewsCell = cell as! NewsCell
        newsCell.loadContent(entry)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(self.isTopNews){
            if(self.defaultSiteLanguage == LanguageType.english){
                return NSLocalizedString("TOP NEWS", comment: "Section title in homescreen")
            }else {
                return "मुख्य समाचार"
            }
        }else {
            return selectedCategory
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(self.newsArticles.count > 0){
            return 25
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.font = UIFont.systemFont(ofSize: 12)
    }
    
    func fetchTopNews(){
        self.isTopNews = true;
        self.fetchNews(nil, categoryEntry:nil, isTopNews:true)
    }
    func fetchNewsOnCategory(_ categoryEntry:Entry){
        self.isTopNews = false;
        self.fetchNews(nil, categoryEntry:categoryEntry)
    }
    
    func fetchNews(_ group:DispatchGroup!, categoryEntry:Entry! = nil, isTopNews:Bool = false){
        if(group != nil){
            group.enter()
        }else {
            if(!self.refreshControl.isRefreshing){
                self.showLoadingInView(self.view)
            }
            
        }
        if(categoryEntry != nil){
            let categoryTitle:String = categoryEntry.title
            let categoryUid:String = categoryEntry.uid
            self.selectedCategory = categoryTitle
            self.selectedCategoryUId = categoryUid
        }
        
        if(allNewsByCategoryQuery != nil){
            allNewsByCategoryQuery.cancelRequests()
        }
        allNewsByCategoryQuery = AppDelegate.sharedSite().contentType(withName: "news").query()
        
        allNewsByCategoryQuery.language(Language.ENGLISH_UNITED_STATES)
        
        if(self.defaultSiteLanguage == LanguageType.hindi){
            allNewsByCategoryQuery.language(Language.HINDI_INDIA)
        }
        
        if(isTopNews){
            allNewsByCategoryQuery.whereKey("top_news", equalTo: NSNumber(value: true as Bool))
        }else {
            allNewsByCategoryQuery.whereKey("category", equalTo: [self.selectedCategoryUId])
        }
        
        allNewsByCategoryQuery.includeReferenceField(withKey: ["category"])
        allNewsByCategoryQuery.order(byAscending: "updated_at")
        
        
        allNewsByCategoryQuery.find { (responseType, result, error) -> Void in
            
            if(error != nil){
                let alertController:UIAlertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: "Opps! Some error occured while fetching data.", preferredStyle: UIAlertControllerStyle.alert)
                
                let cancelAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: .cancel) { (action) in
                    self.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true) {
                }
            }else {
                
                self.newsArticles.removeAll(keepingCapacity: false)
                
                for entry:Entry in (result!.getResult() as! [(Entry)]){
                    self.newsArticles.append(entry)
                    
                    var category:String = ""
                    let categories:NSArray = entry["category" as NSCopying] as! NSArray
                    categories.enumerateObjects({ (obj, index, stop) -> Void in
                        let categoryDict:[NSString:AnyObject] = obj as! [NSString:AnyObject]
                        category = categoryDict["title"] as! String
                    })
                    self.selectedCategory = category
                    
                }
            }
            
            if(isTopNews){
                self.topNewsArticles.removeAll(keepingCapacity: false)
                self.topNewsArticles.append(contentsOf: self.newsArticles)
            }
            
            if(group != nil){
                group.leave()
            }else {
                self.filterBannerNews(!isTopNews)
                self.tableView.reloadData()
                
                if(self.refreshControl.isRefreshing){
                    self.refreshControl.endRefreshing()
                }else {
                    self.hideLoadingInView(self.view)
                }
            }
            
        }
        
    }
    
    func filterBannerNews(_ onCategory:Bool){
        self.stopRotatingBanner()
        self.bannerNewsList.removeAll(keepingCapacity: false)
        if(onCategory){
            self.bannerNewsList = self.topNewsArticles.filter { (e) -> Bool in
                var retVal:Bool = false
                let categories:NSArray = e["category" as NSCopying] as! NSArray
                categories.enumerateObjects({ (obj, index, stop) -> Void in
                    var categoryUID:String = ""
                    let category:Entry = AppDelegate.sharedSite().contentType(withName: "category").entry(withUID: categoryUID)
                    category.configure(with: obj as! [AnyHashable: Any])
                    categoryUID = category.uid
                    if(categoryUID == self.selectedCategoryUId){
                        retVal = true
                    }
                })
                return retVal
            }
        }else {
            self.bannerNewsList = self.topNewsArticles
        }
        
        self.highlitedIndex = 0
        self.startRotatingBanner()
    }
    
    func startRotatingBanner(){
        stopRotatingBanner()
        self.bannerTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(TopNewsController.rotateBanner), userInfo: nil, repeats: true)
        rotateBanner()
    }
    
    func stopRotatingBanner(){
        if(self.bannerTimer != nil){
            self.bannerTimer.invalidate()
            self.bannerTimer = nil;
        }
    }
    
    func rotateBanner(){
        if(self.bannerNewsList.count==0){
            self.bannerImage.image = nil
            self.bannerTitleLabel.text = ""
            self.bannerCategoryLabel.text = ""
            return
        }
        
        if(self.highlitedIndex < self.bannerNewsList.count){
            bannerImage.superview?.isHidden = false;
            
            self.currentIndex = self.highlitedIndex
            let entry:Entry = self.bannerNewsList[self.highlitedIndex]
            
            if let bannerDict:[NSString: AnyObject] = (entry["featured_image" as NSCopying] as? [NSString: AnyObject]) {
                if let imageURLString: String = bannerDict["url"] as? String {
                    self.bannerImage.contentMode = UIViewContentMode.scaleAspectFill
                    self.bannerImage.clipsToBounds = true
                    let url = URL(string: imageURLString)!
                    self.bannerImage.kf.setImage(with: url,
                                                 placeholder: nil,
                                                 options: [.transition(.fade(1))],
                                                 progressBlock: nil,
                                                 completionHandler: nil)
                }else{
                    self.bannerImage.image = UIImage(named: "thumbImage");
                }
            }else {
                self.bannerImage.image = nil;
            }
            
            self.bannerTitleLabel.text = entry.title
            
            let categories:NSArray = entry["category" as NSCopying] as! NSArray
            var category:String = ""
            categories.enumerateObjects({ (obj, index, stop) -> Void in
                let categoryDict:[NSString:AnyObject] = obj as! [NSString:AnyObject]
                category = categoryDict["title"] as! String
            })
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone.autoupdatingCurrent
            dateFormatter.dateStyle = DateFormatter.Style.medium
            let dtString = dateFormatter.string(from: entry.updatedAt) as String
            
            self.bannerCategoryLabel.text = category + " | " + dtString
            self.highlitedIndex+=1
            if(self.highlitedIndex>=self.bannerNewsList.count){
                self.highlitedIndex = 0
            }
        }
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if(identifier == "bannerDetail"){
            if(self.bannerNewsList.count > self.currentIndex){
                return true
            }
            return false
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "bannerDetail"){
            if(self.bannerNewsList.count > self.currentIndex){
                let entry:Entry = self.bannerNewsList[self.currentIndex]
                let detailVC:NewsDetailController = segue.destination as! NewsDetailController
                detailVC.newsArticle = entry
            }
        }else {
            var entry:Entry! = nil
            entry = self.newsArticles[self.tableView.indexPathForSelectedRow!.row]
            let detailVC:NewsDetailController = segue.destination as! NewsDetailController
            detailVC.newsArticle = entry
            
            self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: false)
        }
        
    }
    
    func fetchAndChangeNewsLanguage(){
        
        if(self.slidingPanelController.leftPanelController != nil && self.slidingPanelController.leftPanelController.isKind(of: CategoryController.classForCoder())){
            let leftVC:CategoryController =  self.slidingPanelController.leftPanelController as! CategoryController
            leftVC.fetchAllCategories(defaultSiteLanguage == LanguageType.english ? true : false)
        }
        
        self.enableNavigationButtons(false)
        
        self.stopRotatingBanner()
        self.showLoadingInView(self.view)
        let netCallsGroup:DispatchGroup = DispatchGroup()
        
        self.fetchNews(netCallsGroup, categoryEntry: nil, isTopNews: true)
        
        netCallsGroup.notify(queue: DispatchQueue.main) { () -> Void in
            let netCallsGroup2:DispatchGroup = DispatchGroup()
            
            if(!self.isTopNews){
                self.fetchNews(netCallsGroup2, categoryEntry: nil)
            }
            netCallsGroup2.notify(queue: DispatchQueue.main) { () -> Void in
                self.filterBannerNews(!self.isTopNews)
                self.tableView.reloadData()
                self.hideLoadingInView(self.view)
                
                self.enableNavigationButtons(true)
            }
        }
        
    }
    
    @IBAction func changeLanguage(){
        let alertController:UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let englishAction = UIAlertAction(title: NSLocalizedString("English (Default)", comment: "English (Default)") + (self.defaultSiteLanguage == LanguageType.english ? " \u{2713}" : ""), style: .default) { (action) in
            
            self.defaultSiteLanguage = LanguageType.english
            self.fetchAndChangeNewsLanguage()
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(englishAction)
        
        let hindiAction = UIAlertAction(title: NSLocalizedString("हिंदी", comment: "Hindi") + (self.defaultSiteLanguage == LanguageType.hindi ? " \u{2713}" : ""), style: .default) { (action) in
            self.defaultSiteLanguage = LanguageType.hindi
            self.fetchAndChangeNewsLanguage()
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(hindiAction)
        
        
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
}
