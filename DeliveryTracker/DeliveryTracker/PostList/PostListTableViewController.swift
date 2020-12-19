//
//  PostListTableViewController.swift
//  DeliveryTracker
//
//  Created by 김수완 on 2020/12/04.
//

import UIKit
import Alamofire
import RxSwift

let BaseUrl : String = "https://apis.tracker.delivery/carriers"

class PostListTableViewController: UITableViewController, UITextViewDelegate {
    
    var Carriers = [Carrier]()
    var Posts = [PostInfo]()
    let selectedItem = BehaviorSubject(value: 0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUsersPosts()
        getCarrirsData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PostListCell
        
        cell.stateLable.text = Posts[indexPath.row].State
        cell.carrierLable.text = Posts[indexPath.row].Carrier.Carrier.name + " " + Posts[indexPath.row].Carrier.PostNum
        cell.fromLable.text = Posts[indexPath.row].From
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { (action, view, success ) in
            if var posts = UserDefaults.standard.array(forKey: "Posts") as? [[String]]{
                print(posts)
                posts.remove(at: indexPath.row)
                print(posts)
                UserDefaults.standard.set(posts, forKey: "Posts")
                self.Posts.remove(at: indexPath.row)
                self.tableView.reloadData()
            }
        }
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goPostInfoVC", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goPostInfoVC" {
            if let destinationVC = segue.destination as? PostInfoViewController,
                let indexPathRow = sender as? Int{
                destinationVC.post = Post(Carrier: Carrier(name: Posts[indexPathRow].Carrier.Carrier.name,
                                                           id: Posts[indexPathRow].Carrier.Carrier.id),
                                                           PostNum: Posts[indexPathRow].Carrier.PostNum)
            }
        }
    }

}

extension PostListTableViewController{
    func getCarrirsData(){
        AF.request(BaseUrl+"?"+now(), method: .get).validate().responseJSON(completionHandler: { res in
                                   
            switch res.result {
            case .success(let value):
                if let data = value as? [[String:Any]]{
                    for dataIndex in data{
                        self.Carriers.append(Carrier(name: dataIndex["name"] as! String,
                                                     id: dataIndex["id"] as! String))
                    }
                }
                            
            case .failure(let err):
                print("ERROR : \(err)")
            }
        })
    }
    
    func getUsersPosts(){
        if let posts = UserDefaults.standard.array(forKey: "Posts") as? [[String]] {
            Posts.removeAll()
            for post in posts {
                AF.request(BaseUrl+"/"+post[0]+"/tracks/"+post[1]+"?"+self.now(), method: .get).validate().responseJSON(completionHandler: { res in
                    switch res.result {
                    case .success(let value):
                        if let data = value as? [String : Any]{
                            self.Posts.append(PostInfo(State: (data["state"] as! [String: String])["text"]!,
                                                  Carrier: Post(Carrier: Carrier(name: (data["carrier"] as! [String: String])["name"]!, id: post[0]), PostNum: post[1]),
                                                  From: (data["from"] as! [String: String])["name"]!))
                            self.tableView.reloadData()
                        }
                        
                    case .failure(let err):
                        print(err)
                    }
                })
            }
        }
    }
    
    func now() -> String{
        let formatter_time = DateFormatter()
        formatter_time.dateFormat = "ss"
        let current_time_string = formatter_time.string(from: Date())
        return current_time_string
    }
    
    struct PostInfo {
        let State : String
        let Carrier : Post
        let From : String
    }
}

extension PostListTableViewController : UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBAction func plusBtn(_ sender: Any) {
        
        var selectIndex : Int = 0
        
        let alert = UIAlertController(title: "등록", message: "운송장 정보", preferredStyle: .alert)
        alert.addTextField{ (CompanynameTextField) in
            
            CompanynameTextField.placeholder = "택배 회사"
            CompanynameTextField.tintColor = .clear
            
            let pickerView = UIPickerView()
            pickerView.delegate = self
            CompanynameTextField.inputView = pickerView
            
            let toolBar = UIToolbar()
            toolBar.sizeToFit()
            CompanynameTextField.inputAccessoryView = toolBar
            
            self.selectedItem.subscribe(onNext: { Index in
                CompanynameTextField.text = self.Carriers[Index].name
                selectIndex = Index
            })

            
        }
        alert.addTextField{ (PostNumTextField) in
            
            PostNumTextField.placeholder = "운송장 번호"
            PostNumTextField.keyboardType = .numberPad
        }
        
        let ok = UIAlertAction(title: "등록", style: .default) { (ok) in
            AF.request(BaseUrl+"/"+self.Carriers[selectIndex].id+"/tracks/"+alert.textFields![1].text!+"?"+self.now(), method: .get).validate().responseJSON(completionHandler: { res in

                switch res.result {
                case .success(_):
                    if var posts = UserDefaults.standard.array(forKey: "Posts") as? [[String]]{
                        posts.append([self.Carriers[selectIndex].id, alert.textFields![1].text!])
                        UserDefaults.standard.set(posts, forKey: "Posts")
                    }else {
                        UserDefaults.standard.set([[self.Carriers[selectIndex].id, alert.textFields![1].text!]] ,forKey: "Posts")
                    }
                    self.alert("등록 되었습니다.")
                    self.getUsersPosts()
                    
                case .failure(_ ):
                    self.alert("없는 운송장 정보입니다.")
                }
            })
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Carriers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Carriers[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        selectedItem.onNext(row)
    }
    
    func alert(_ phrases : String) {
        let alert = UIAlertController(title: phrases, message: nil, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okButton)
        self.present(alert,animated: true, completion: nil)
    }
    
}
