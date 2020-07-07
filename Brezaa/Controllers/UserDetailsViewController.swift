//
//  UserDetailsViewController.swift
//  Brezaa
//
//  Created by Liam Ratcliffe on 07/07/2020.
//  Copyright © 2020 Liam Ratcliffe. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage
import Alamofire

class UserDetailsViewController: UIViewController {
    
    var userDetails = JSON()
    var postsJSON = JSON()
    var commentsJSON = JSON()
    var imageURL = NSURL()
    var userID = String()
    var postsTitleArray = [String]()
    var numberOfCommentsForEachPost = Array(repeating: 0, count: 100)
    var thisUsersPostIds = [Int]()

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userStreetLabel: UILabel!
    @IBOutlet weak var userSuiteLabel: UILabel!
    @IBOutlet weak var userCityLabel: UILabel!
    @IBOutlet weak var userZipLabel: UILabel!
    @IBOutlet weak var userPhoneNumberLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - UI setup
        
        tableView.dataSource = self

        self.title = "\(userDetails["username"])"
        userNameLabel.text = "\(userDetails["name"])"
        userEmailLabel.text = "\(userDetails["email"])"
        userStreetLabel.text = "\(userDetails["address"]["street"])"
        userSuiteLabel.text = "\(userDetails["address"]["suite"])"
        userCityLabel.text = "\(userDetails["address"]["city"])"
        userZipLabel.text = "\(userDetails["address"]["zipcode"])"
        userPhoneNumberLabel.text = "\(userDetails["phone"])"
        
        let userEmail = "\(userDetails["email"])"
        let imageURL = NSURL(string: "https://api.adorable.io/avatars/150/\(userEmail).png")
        if let url = imageURL {
            userImage.sd_setImage(with: url as URL)
        }
        
        userID = "\(userDetails["id"])"
        
        //MARK: - Load Posts
        
        let urlPosts = "https://jsonplaceholder.typicode.com/posts"
        Alamofire.request(urlPosts, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                if let postsResponse = response.result.value {
                    self.postsJSON = JSON(postsResponse)
                    
                    for post in self.postsJSON {
                        if post.1["userId"].stringValue == self.userID {
                            self.postsTitleArray.append(post.1["title"].stringValue)
                            self.thisUsersPostIds.append(Int(post.0)!)
                        }
                    }
                    self.tableView.reloadData()
                }
            } else {
                print("Alamofire error: \(String(describing: response.result.error))")
            }
        }
        
        //MARK: - Load Comments
        
        let urlComments = "https://jsonplaceholder.typicode.com/comments"
        Alamofire.request(urlComments, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                if let commentsResponse = response.result.value {
                    self.commentsJSON = JSON(commentsResponse)
                    
                    for comment in self.commentsJSON {
                        let relatedPost = comment.1["postId"].intValue
                        self.numberOfCommentsForEachPost[relatedPost-1] += 1
                    }
                    self.tableView.reloadData()
                }
            } else {
                print("Alamofire error: \(String(describing: response.result.error))")
            }
        }
    }
}

//MARK: - UITableViewDataSource Methods

extension UserDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postsTitleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusablePostsCell", for: indexPath)
        cell.textLabel?.text = postsTitleArray[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel!.text = String(numberOfCommentsForEachPost[thisUsersPostIds[indexPath.row]])
        return cell
    }
}
