//
//  PostInfoViewController.swift
//  DeliveryTracker
//
//  Created by 김수완 on 2020/12/06.
//

import UIKit

class PostInfoViewController: UIViewController {

    @IBOutlet weak var stateLable: UILabel!
    @IBOutlet weak var carrierLable: UILabel!
    @IBOutlet weak var postNumberLable: UILabel!
    @IBOutlet weak var fromLable: UILabel!
    @IBOutlet weak var toLable: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension PostInfoViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! progressesCell
        
        return cell
    }
    
    
}

class progressesCell: UITableViewCell {
    @IBOutlet weak var dateLable: UILabel!
    @IBOutlet weak var timeLable: UILabel!
    @IBOutlet weak var lineImageView: UIImageView!
    @IBOutlet weak var locationLable: UILabel!
    @IBOutlet weak var discriptionLable: UILabel!
}
