//
//  PostListTableViewController.swift
//  DeliveryTracker
//
//  Created by 김수완 on 2020/12/04.
//

import UIKit
import Alamofire

let BaseUrl : String = "https://apis.tracker.delivery/carriers"

class PostListTableViewController: UITableViewController, UITextViewDelegate {

    var Carriers = [Carrier]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCarrirsData()
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
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
    
    func now() -> String{
        let formatter_time = DateFormatter()
        formatter_time.dateFormat = "ss"
        let current_time_string = formatter_time.string(from: Date())
        return current_time_string
    }
    
    struct Carrier {
        let name : String
        let id : String
    }

}

extension PostListTableViewController : UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBAction func plusBtn(_ sender: Any) {
        let alert = UIAlertController(title: "등록", message: "운송장 정보", preferredStyle: .alert)
        alert.addTextField{ (TextField) in
            
            TextField.placeholder = "택배 회사"
            
            let pickerView = UIPickerView()
            pickerView.delegate = self
            TextField.inputView = pickerView
            
            let toolBar = UIToolbar()
            toolBar.sizeToFit()
            let button = UIBarButtonItem(title: "선택", style: .plain, target: self, action: nil)
            toolBar.setItems([button], animated: true)
            toolBar.isUserInteractionEnabled = true
            TextField.inputAccessoryView = toolBar
            
        }
        alert.addTextField{ (TextField) in
            
            TextField.placeholder = "운송장 번호"
            TextField.keyboardType = .numberPad
        }
        
        let ok = UIAlertAction(title: "OK", style: .default) { (ok) in
            
        }
        let cancel = UIAlertAction(title: "cancel", style: .cancel)
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
    
}

class PostListCell: UITableViewCell {
    @IBOutlet weak var stateLable: UILabel!
    @IBOutlet weak var carrierLable: UILabel!
    @IBOutlet weak var fromLable: UILabel!
}
