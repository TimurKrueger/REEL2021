//
//  Memories.swift
//  REEL2021
//
//  Created by Louis Hakim on 12.08.21.
//

import Foundation
import UIKit
import Firebase

class Memories: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var table: UITableView!
    
    var posts = [UIImage]()
    var numberOfPosts: Int = 0
    var pic: UIImage!
    
    
    
override func viewDidLoad() {
    
    super.viewDidLoad()
    
    table.register(PostTableViewCell.nib(), forCellReuseIdentifier: PostTableViewCell.identifier)
    table.delegate = self
    table.dataSource = self
    
    
   
}

                
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as! PostTableViewCell
        //cell.configure(with: posts[indexPath.row])
       
            return cell
}
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120 + 140 + view.frame.size.width
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}


//define the struct for the post
struct MemoryPost {
    
    let numberOfCheers: Int
    let username: String
    let userImageName: String
    let postImageName: String
    
}
