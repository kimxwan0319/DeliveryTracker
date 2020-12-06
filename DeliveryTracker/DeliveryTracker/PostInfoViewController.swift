//
//  PostInfoViewController.swift
//  DeliveryTracker
//
//  Created by 김수완 on 2020/12/06.
//

import UIKit
import Alamofire

class PostInfoViewController: UIViewController {
    
    public var post : Post = Post(Carrier: Carrier(name: "", id: ""), PostNum: "")
    var progresses = [progress]()
    
    @IBOutlet weak var stateProgressView: UIProgressView!
    @IBOutlet weak var stateLable: UILabel!
    @IBOutlet weak var carrierLable: UILabel!
    @IBOutlet weak var postNumberLable: UILabel!
    @IBOutlet weak var fromLable: UILabel!
    @IBOutlet weak var toLable: UILabel!
    
    @IBOutlet weak var progressTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPostData()
        setTableView()
        setNavigationBar()
    }

    func setNavigationBar(){
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    struct progress {
        let at : String
        let location : String
        let discription : String
    }
}

extension PostInfoViewController{
    func getPostData(){
        AF.request(BaseUrl+"/"+self.post.Carrier.id+"/tracks/"+self.post.PostNum+"?"+self.now(), method: .get).validate().responseJSON(completionHandler: { res in

            switch res.result {
            case .success(let value):
                if let data = value as? [String: Any]{
                    self.setProgressBar((data["state"] as! [String: String])["text"]!)
                    
                    self.stateLable.text = (data["state"] as! [String: String])["text"]!
                    self.carrierLable.text = self.post.Carrier.name
                    self.postNumberLable.text = self.post.PostNum
                    self.fromLable.text = (data["from"] as! [String: String])["name"]!
                    self.toLable.text = (data["to"] as! [String: String])["name"]!
                    
                    for progressIndex in data["progresses"] as! [[String: Any]]{
                        self.progresses.insert(progress(at: progressIndex["time"] as! String,
                                                        location: (progressIndex["location"] as! [String: String])["name"]!,
                                                        discription: progressIndex["description"] as! String), at: 0)
                        
                    }
                    self.progressTableView.reloadData()
                }
            case .failure(let err):
                print(err)
            }
        })
    }
    
    func setProgressBar(_ state : String){
        switch state {
        case "상품인수":
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.stateProgressView.setProgress(0.25, animated: true)
            }
        case "이동중":
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.stateProgressView.setProgress(0.5, animated: true)
            }
        case "배송출발":
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.stateProgressView.setProgress(0.75, animated: true)
            }
        case "배송완료":
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.stateProgressView.setProgress(1, animated: true)
            }
            
        default:
            return
        }
    }
    
    func now() -> String{
        let formatter_time = DateFormatter()
        formatter_time.dateFormat = "ss"
        let current_time_string = formatter_time.string(from: Date())
        return current_time_string
    }
}

extension PostInfoViewController: UITableViewDelegate, UITableViewDataSource{
    
    func setTableView(){
        progressTableView.separatorStyle = .none
        progressTableView.allowsSelection = false
        progressTableView.delegate = self
        progressTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return progresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "progressCell", for: indexPath) as! progressesCell
        
        if progresses.count == 1{
            cell.lineImageView.image = UIImage(named: "only")
        }
        else if indexPath.row == 0 {
            cell.lineImageView.image = UIImage(named: "first")
        }
        else if indexPath.row == progresses.count-1{
            cell.lineImageView.image = UIImage(named: "last")
        }
        else{
            cell.lineImageView.image = UIImage(named: "middle")
        }
        
        cell.dateLable.text = dateFormatDate(progresses[indexPath.row].at)
        cell.timeLable.text = dateFormatTime(progresses[indexPath.row].at)
        cell.locationLable.text = progresses[indexPath.row].location
        cell.discriptionLable.text = progresses[indexPath.row].discription
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func dateFormatDate(_ date: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier:"ko_KR")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
            
        guard let temp = formatter.date(from: date) else {return "?"}
        formatter.dateFormat = "yyyy-MM-dd"
        let current_time_string = formatter.string(from: temp)
            
        return current_time_string
    }
    
    func dateFormatTime(_ date: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier:"ko_KR")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
            
        guard let temp = formatter.date(from: date) else {return "?"}
        formatter.dateFormat = "HH:mm"
        let current_time_string = formatter.string(from: temp)
            
        return current_time_string
    }
    
}

class progressesCell: UITableViewCell {
    @IBOutlet weak var dateLable: UILabel!
    @IBOutlet weak var timeLable: UILabel!
    @IBOutlet weak var lineImageView: UIImageView!
    @IBOutlet weak var locationLable: UILabel!
    @IBOutlet weak var discriptionLable: UILabel!
}
