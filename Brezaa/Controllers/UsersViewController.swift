//
//  ViewController.swift
//  Brezaa
//
//  Created by Liam Ratcliffe on 06/07/2020.
//  Copyright © 2020 Liam Ratcliffe. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class UsersViewController: UIViewController {
    
    var userJSON = JSON()
    var segueIndexPath = Int()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //MARK: - UI Setup
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.systemGray6
        tableView.separatorColor = UIColor.clear
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "reusableUserCell")
        
        //MARK: - Load Users
        
        let url = "https://jsonplaceholder.typicode.com/users"
        
        Alamofire.request(url, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                if let userResponse = response.result.value {
                    self.userJSON = JSON(userResponse)
                    self.tableView.reloadData()
                }
            } else {
                print("Alamofire error: \(String(describing: response.result.error))")
            }
        }
    }
}

//MARK: - UITableViewDataSource Methods

extension UsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userJSON.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableUserCell", for: indexPath) as! UserCell
        cell.usernameLabel?.text = "\(self.userJSON[indexPath.row]["username"])"
        
        let userEmail = "\(self.userJSON[indexPath.row]["email"])"
        let imageURL = NSURL(string: "https://api.adorable.io/avatars/50/\(userEmail).png")
        if let url = imageURL {
            cell.userIconImageView.sd_setImage(with: url as URL)
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate Methods

extension UsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        segueIndexPath = indexPath.row
        performSegue(withIdentifier: "toUserDetails", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! UserDetailsViewController
        destinationVC.userDetails = userJSON[segueIndexPath]
        
        let userEmail = "\(self.userJSON[segueIndexPath]["email"])"
        let imageURL = NSURL(string: "https://api.adorable.io/avatars/50/\(userEmail).png")
        if let url = imageURL {
            destinationVC.imageURL = url
        }
    }
}
