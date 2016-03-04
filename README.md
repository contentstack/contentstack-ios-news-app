## Introduction
Sample News app written in Swift showing use of Contentstack SDK.

<img src='https://api.contentstack.io/v2/assets/56d92c3811420d24232dc99b/download?uid=blt1abeb9dc7292dfd3&AUTHTOKEN=blt0d34ed82cc45c4d16a0e25d0' width='650' height='550'/>
 
## Create Content Type - Category and News
In this news application, we will create 2 Content Types viz., Category and News. Download the JSON format of Category and News content type and import it in Contentstack.

[Category JSON](https://api.contentstack.io/v2/assets/56d5971b3ca9925f3308f3df/download?uid=blte6c36c6b5649f69a&AUTHTOKEN=blt0d34ed82cc45c4d16a0e25d0)

[News JSON](https://api.contentstack.io/v2/assets/56d59728d2eb69223c27935f/download?uid=blte2e550aa822a2554&AUTHTOKEN=blt0d34ed82cc45c4d16a0e25d0).

To learn more about how to import content type, check out the [guide](http://contentstackdocs.built.io/developer/guides/content-types#import-a-content-type).

Create **Category** Content Type

<img src='https://api.contentstack.io/v2/assets/56b85f310ea5e91f35d9ffbb/download?uid=blt0ef50bfc28445d08&AUTHTOKEN=bltbfb694c915ad7c3b24584a7b' width='600' height='400'/>

Create **News** Content Type

<img src='https://api.contentstack.io/v1/uploads/56b85f390ea5e91f35d9ffc6/download?uid=blt04d8d8e7c7c632c5&AUTHTOKEN=bltefb4f32b56206d8e5bc6cb9e' width='600' height='550'/>

## Clone repository

Open Terminal (for Mac and Linux users) or the command prompt (for Windows users) and paste the below command to clone the project.

    $ git clone https://github.com/raweng/NewsApp-iOS.git

## Configure project
Grab API Key and Access Token from Contentstack admin interface, Settings > General and Update the config parameters in SDK initialisation step:

    let stack:Stack = Contentstack.stackWithAPIKey("API_KEY", accessToken: "ACCESS_TOKEN", environmentName: "ENVIRONMENT_NAME")

## Usage

#### Query News Items 
Home page shows list of top news that we have created in Contentstack. Let’s see how to query Contentstack. 

    var topNewsArticles = [Entry]();
    var allNewsByCategoryQuery:Query = stack.contentTypeWithName("news").query()
    
    //filter topnews
    allNewsByCategoryQuery.whereKey("topnews", equalTo: NSNumber(bool: true))
    
    allNewsByCategoryQuery.includeReferenceFieldWithKey(["category"])
    allNewsByCategoryQuery.orderByAscending("updated_at")
    
    allNewsByCategoryQuery.find { (responseType, result, error) -> Void in
        
        if(error != nil){
            let alertController:UIAlertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: "Opps! Some error occured while fetching data.", preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: .Cancel) { (action) in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true) {
                // ...
            }
        }else {
            
            for entry:Entry in (result.getResult() as! [(Entry)]){
                self.topNewsArticles.append(entry)
            }
        }
    }
For more details about Query, refer [Contentstack Query Guide][0] 

#### Filter By Category
    // self.selectedCategoryUId is a variable containing selected category uid
    allNewsByCategoryQuery.whereKey("category", equalTo: [self.selectedCategoryUId])

#### Filter By Language 
    //For English language
    allNewsByCategoryQuery.language(Language.ENGLISH_UNITED_STATES)
    
    //For Hindi language
    //allNewsByCategoryQuery.language(Language.HINDI_INDIA)
    
[0]: <http://csdocs.builtapp.io/developer/ios/query-guide>
