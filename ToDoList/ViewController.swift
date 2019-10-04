//
//  ViewController.swift
//  ToDoList
//
//  Created by nhajime on 2019/10/03.
//  Copyright © 2019 nhajime. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //todoを格納する配列
    var todoList = [MyTodo]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //保存済みのTODOを読み込む
        let userDefaults = UserDefaults.standard
        if let storedTodoList = userDefaults.object(forKey: "todoList") as? Data {
            do{
                if let unarchiveTodoList = try NSKeyedUnarchiver.unarchivedObject(
                    ofClasses: [NSArray.self, MyTodo.self],
                    from: storedTodoList) as? [MyTodo]{
                    todoList.append(contentsOf: unarchiveTodoList)
                }
            } catch {
                //エラー処理
            }
        }
    }
    
    
    //+ボタンを押したら
    @IBAction func tapAddButton(_ sender: Any) {

        //ダイアログを作る
        let alertController = UIAlertController(title: "ToDoを追加する", message: "ToDoを入力してください", preferredStyle: UIAlertController.Style.alert)
        
        //ダイアログにテキストフィールドを追加する
        alertController.addTextField(configurationHandler: nil)
        //ダイアログにO.K.ボタンを追加する
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {(action: UIAlertAction) in
            
            if let textField = alertController.textFields?.first {
                //TODOの配列の先頭に値を格納する
                let myTodo = MyTodo()
                myTodo.todoTitle = textField.text
                self.todoList.insert(myTodo, at: 0)
                // テーブルに行が追加されたことをテーブルに通知
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)],with: UITableView.RowAnimation.right)
                
                
                //TODOを保存する
                //UserDefaultsをインスタンス化
                let userDefaults = UserDefaults.standard
                //Data型にシリアライズする
                do{
                    let data = try NSKeyedArchiver.archivedData(withRootObject: self.todoList, requiringSecureCoding: true)
                    userDefaults.set(data, forKey: "todoList")
                    userDefaults.synchronize()
                } catch {
                    //エラー処理
                }
            }
        }
        
        //okボタンがp押されたら
        alertController.addAction(okAction)
        //キャンセルボタンが押されたら
        let cancelButton = UIAlertAction(title: "CANCEL", style: UIAlertAction.Style.cancel, handler: nil)
        //キャンセルボタンを追加
        alertController.addAction(cancelButton)
        //ダイアログを追加
        present(alertController, animated: true, completion: nil)
    }
    
    //テーブルの行数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.count
    }
    //テーブルの行毎のセルを返す
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //再利用可能なセルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        //行番号と合致するTODOのデータを取得する
        let myTodo = todoList[indexPath.row]
        //セルのラベルにTODOのタイトルを代入する
        cell.textLabel?.text = myTodo.todoTitle
        //セルのチェックマークの状態を代入する
        if myTodo.todoDone {
            //チェックあり
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }else{
            //チェックなし
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        return cell
    }
    
    //セルをタップしたときの処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let myTodo = todoList[indexPath.row]
        if myTodo.todoDone {
            //完了済みは未完了にする
            myTodo.todoDone = false
        } else {
            //未完了は完了済みにする
            myTodo.todoDone = true
        }
        
        //セルの状態を変更する
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        //Data型にシリアライズして保存
        do {
            let data: Data = try NSKeyedArchiver.archivedData(withRootObject: todoList, requiringSecureCoding: true)
            //UserDefaultsに保存する
            let userDefaults = UserDefaults.standard
            userDefaults.set(data, forKey: "todoList")
            userDefaults.synchronize()
        } catch {
            //エラー処理
        }
    }
    
    //セルを削除したときの処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            //TODOのリストから削除する
            todoList.remove(at: indexPath.row)
            //セルを削除する
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            //Data型にシリアライズしてUserDefaultsに保存
            do {
                //シリアライズする
                let data: Data = try NSKeyedArchiver.archivedData(withRootObject: todoList, requiringSecureCoding: true)
                //UserDefaultsに格納する
                let userDefaults = UserDefaults.standard
                userDefaults.set(data, forKey: "todoList")
                userDefaults.synchronize()
            } catch {
            //エラー処理
            }
        }
    }
    
}
    
    
//独自クラスをシリアライズする
//NSOblectを継承、NSSecureCodingプロトコルに準拠
class MyTodo: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool {
        return true
    }
    var todoTitle: String?
    var todoDone: Bool = false
    
    override init(){
    }
    //デシリアライズ処理
    required init?(coder aDcoder: NSCoder) {
        todoTitle = aDcoder.decodeObject(forKey: "todoTitle") as? String
        todoDone = aDcoder.decodeBool(forKey: "todoDone")
    }
    //シリアライズ処理
    func encode(with aCoder: NSCoder) {
        aCoder.encode(todoTitle, forKey: "todoTitle")
        aCoder.encode(todoDone, forKey: "todoDone")
    }
}

