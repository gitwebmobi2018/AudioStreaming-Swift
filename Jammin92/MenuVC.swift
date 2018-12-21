//
//  MenuVC.swift
//  TT
//
//  Created by gitwebmobi on 4/2/17.
//  Copyright © 2017 gitwebmobi All rights reserved.
//

import UIKit
import MessageUI

struct Menu {
    var title: String
    var image: String
}

class MenuVC: UIViewController, UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var menuTable: UITableView!
    @IBOutlet weak var versionLabel: UILabel!

    
    var menus:[Menu] = []

    var feedback = Menu(title: "Feedback", image: "sca")
   
    func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        else{
            return ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTable.tableFooterView = UIView(frame: .zero)
        
        menus = [feedback]

    self.menuTable.register(UINib(nibName: "MenuTableCell", bundle: Bundle.main), forCellReuseIdentifier: "MenuTableCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        versionLabel.text = "Version \(getAppVersion())"

       }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"MenuTableCell") as! MenuTableCell
        cell.selectionStyle = .none;
        let menu = menus[indexPath.row]
        cell.fillMenuInfo(menu: menu)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let picker:MFMailComposeViewController = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setSubject("")
        picker.setToRecipients(["feedback_iphone@jammin92.com"])
        picker.setMessageBody(NSLocalizedString("Comments", comment: ""), isHTML: true)
        if MFMailComposeViewController.canSendMail(){
            parent?.present(picker, animated: true, completion: nil)
            
        }
        /*
        rateApp(appId: "id959379869") { success in
            print("RateApp \(success)")
        }
        */
        self.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)

    }
  
    /*
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
 */
}



extension MenuVC:MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        
        parent?.dismiss(animated: true, completion: nil)
    }
}
