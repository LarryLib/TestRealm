//
//  ViewController.swift
//  TestRealm
//
//  Created by larry on 2018/10/29.
//  Copyright © 2018 twofly. All rights reserved.
//

import UIKit
import RealmSwift
import SnapKit

class UserModel: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var age: Int = 0
    @objc dynamic var address: String = ""
    @objc dynamic var sex: Int = 0  // 1男2女
    @objc dynamic var xxxx: Int = 0  // 1男2女
    @objc dynamic var tttt: Int = 0  // 1男2女
}

class ViewController: UIViewController {

    @IBOutlet weak var nameTextFiled: UITextField!
    @IBOutlet weak var ageTextFiled: UITextField!
    @IBOutlet weak var addressTextFiled: UITextField!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var ShowAllButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let topLevelObjects = Bundle.main.loadNibNamed("ContentView", owner: self) as! [NSObject]
        let subView = topLevelObjects[0] as! UIView
        view.insertSubview(subView, at: 0)
        subView.snp.makeConstraints {
            $0.top.left.bottom.right.equalTo(view)
        }
    
        upgradeRealm()
    }
    
    func upgradeRealm() {
        
        do {
            let fileUrlIs = try schemaVersionAtURL(Realm.Configuration().fileURL!)
            print("schema version \(fileUrlIs)")
        } catch  {
            print(error)
        }
        
        print("当前版本：\(Realm.Configuration.defaultConfiguration.schemaVersion)")
        let newSchemaVersion : UInt64 = 7
        
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: newSchemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < newSchemaVersion) {
                    print("数据库升级")
                    migration.enumerateObjects(ofType: UserModel.className()) { oldObject, newObject in
                        let sex: Int = 0
                        newObject!["sex"] = 1
                    }
                    print("完成")
                }else {
                    print("不需要升级")
                }
        })
        
        Realm.asyncOpen { (realm, error) in
            if let _ = realm { /* Realm 成功打开，迁移已在后台线程中完成 */
                print("\nRealm 数据库配置成功")
                print("\n后后后后")
                self.handleShowAllButton(UIButton())
            } else if let error = error { /* 处理打开 Realm 时所发生的错误 */
                print("Realm 数据库配置失败：\(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func handleAddButton(_ sender: Any) {
        nameTextFiled.resignFirstResponder()
        ageTextFiled.resignFirstResponder()
        addressTextFiled.resignFirstResponder()
        
        let realm = try! Realm()
        guard let name: String = nameTextFiled.text,
            let ageStr: String = ageTextFiled.text,
            let age: Int = Int(ageStr),
            let address: String = addressTextFiled.text else {
                return
        }
        let users = realm.objects(UserModel.self).filter("name = %@", name)
        let isExistInRalm = users.count > 0
        let user = isExistInRalm ? users[0] : UserModel()
        do {
            try realm.write {
                user.name = name
                user.age = age
                user.address = address
                if !isExistInRalm {
                    realm.add(user)
                }
            }
        } catch  {
            print(error)
        }
        
        nameTextFiled.text = ""
        ageTextFiled.text = ""
        addressTextFiled.text = ""
    }
    
    @IBAction func handleShowAllButton(_ sender: Any) {
        
        nameTextFiled.resignFirstResponder()
        ageTextFiled.resignFirstResponder()
        addressTextFiled.resignFirstResponder()
        
        let realm = try! Realm()
        let users = realm.objects(UserModel.self)
        for user in users {
            print(user)
        }
        
        nameTextFiled.text = ""
        ageTextFiled.text = ""
        addressTextFiled.text = ""
    }
}

extension ViewController: UITextFieldDelegate {
    
}

