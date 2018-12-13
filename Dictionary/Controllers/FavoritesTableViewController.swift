//
//  FavoritesTableViewController.swift
//  Dictionary
//
//  Created by Maha on 08/12/2018.
//  Copyright © 2018 Maha_AlOtaibi. All rights reserved.
//

import UIKit
import CoreData

class FavoritesTableViewController: UITableViewController {
    
    var wordEntity = [WordEntity]()
    var groupedDictionary: [String:[String]]?
    var keys: [String]?
    var wordText: String?
    var viewContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getFavorites()
        var wordString = [String]()
        for word in wordEntity {
            guard let text = word.text else {continue}
            wordString.append(text)
        }
        
        // group the array
        groupedDictionary = Dictionary(grouping: wordString, by: {String($0.prefix(1))})
        
        // get the keys and sort them
        guard let groupedDictionary = groupedDictionary else {return}
        keys = groupedDictionary.keys.sorted()
        
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let keys = keys, keys.count > 0 {
            tableView.restore()
            return keys.count
        }
        
        tableView.setEmptyMessage("Seems you didn't like any word's definitions")
        return keys?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let keys = keys {
            return groupedDictionary?[keys[section]]?.count ?? 0
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let keys = keys {
            return keys[section]
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Id.FavoritesCellReuseidentifier) as! FavoritesTableViewCell
        
        if let keys = keys {
            let stringArray = groupedDictionary?[keys[indexPath.section]]
            cell.favoriteWordLabel.text = stringArray?[indexPath.row]
            cell.startButton.tintColor = UIColor.yellow
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FavoritesTableViewCell
        wordText = cell.favoriteWordLabel.text
        performSegue(withIdentifier: Id.SegueToFavoriteDetails, sender: self)
    }
    
    // MARK: Actions
    
    @IBAction func starBtnTapped(_ sender: UIButton) {
        addRemoveFavorite(sender)
    }
    
    // MARK: Functions
    
    fileprivate func getFavorites() {
        let fetchRequest: NSFetchRequest<WordEntity> = WordEntity.fetchRequest()
        do {
            wordEntity = try viewContext.fetch(fetchRequest)
            tableView.reloadData()
        }catch {
            present(Alert.createUIAlert(title: Alert.ErrorTitle, message: error.localizedDescription), animated: true)
        }
    }
    
    func getCellForView(view:UIView) -> UITableViewCell? {
        var superView = view.superview
        while superView != nil {
            if superView is UITableViewCell {
                return superView as? UITableViewCell
            } else {
                superView = superView?.superview
            }
        }
        return nil
    }
    
    func addRemoveFavorite(_ button: UIButton) {
        let cell = getCellForView(view: button)
        guard let unwrapCell = cell else {return}
        
        if button.tintColor == UIColor.yellow {
            deleteFromFavoritesList(unwrapCell, button: button)
        }
    }
    
    func deleteFromFavoritesList(_ cell: UITableViewCell, button: UIButton) {
        let favoritesCell = cell as! FavoritesTableViewCell
        let indexPath = tableView.indexPath(for: cell)
        
        let fetchRequest: NSFetchRequest<WordEntity> = WordEntity.fetchRequest()
        let predicate = NSPredicate(format: "\(Id.WordText) like[cd] %@", favoritesCell.favoriteWordLabel.text ?? "")
        fetchRequest.predicate = predicate
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            if let deletedWord = result.first {
                viewContext.delete(deletedWord)
                try viewContext.save()
                if var unwrapKeys = keys {
                    if let section = indexPath?.section, let row = indexPath?.row{
                        
                        //if the section has only one row -> delete section
                        // else -> delete only the row
                        if let sectionRows = groupedDictionary?[unwrapKeys[section]], sectionRows.count > 1 {
                            groupedDictionary?[unwrapKeys[section]]?.remove(at: row)
                        }else {
                            keys!.remove(at:section)
                        }
                    }
                }
                tableView.reloadData()
            }
        } catch {
            present(Alert.createUIAlert(title: Alert.ErrorTitle, message: error.localizedDescription), animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Id.SegueToFavoriteDetails {
            let vc = segue.destination as! FavoriteDetailsTableViewController
            guard let wordText = wordText else {return}
            
            vc.wordText =  wordText
        }
    }
    
}
