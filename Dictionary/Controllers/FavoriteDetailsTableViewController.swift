//
//  FavoriteDetailsTableViewController.swift
//  Dictionary
//
//  Created by Maha on 08/12/2018.
//  Copyright © 2018 Maha_AlOtaibi. All rights reserved.
//

import UIKit
import CoreData

class FavoriteDetailsTableViewController: UITableViewController {

    var wordText: String?
    var lexicalsEntity = [LexicalEntity]()
    var cellHeight: CGFloat?
    var viewContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    override func viewDidLoad() {
        guard let wordText = wordText else {return}
        // Get word entity
        let fetchRequest: NSFetchRequest<WordEntity> = WordEntity.fetchRequest()
        let predicate = NSPredicate(format: "\(Id.WordText) like[cd] %@", wordText)
        fetchRequest.predicate = predicate
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            getLexicalEntity(result)
        } catch {
            present(Alert.createUIAlert(title: Alert.ErrorTitle, message: error.localizedDescription), animated: true)
        }
    }
    
    func getLexicalEntity(_ wordEntity: [WordEntity]) {
        guard let wordEntityFirst = wordEntity.first else {return}
        
        let fetchRequest: NSFetchRequest<LexicalEntity> = LexicalEntity.fetchRequest()
        let predicate = NSPredicate(format: "word == %@", wordEntityFirst)
        fetchRequest.predicate = predicate
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            lexicalsEntity.append(contentsOf: result)
            tableView.reloadData()
        } catch {
            present(Alert.createUIAlert(title: Alert.ErrorTitle, message: error.localizedDescription), animated: true)
        }

    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return lexicalsEntity.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return lexicalsEntity[section].category
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lexicalsEntity[section].definitions?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Id.FavoritesDetailsCellReuseidentifier) as! DefinitionsTableViewCell

        let definitionEntity = lexicalsEntity[indexPath.section].definitions?.array as! [DefinitionEntity]
        guard let definitionsText = definitionEntity[indexPath.row].definition else {
            return cell
        }
        
        cell.definitionNoLabel.text = "Definition \(indexPath.row + 1)"
        cell.definitionTextView.text = definitionsText.capitalizingFirstLetter()

        heightOfCellEqual(textview: cell.definitionTextView)
        
        return cell
    }
    
    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard cellHeight != nil else {return 100}
        return cellHeight!
    }
    
    // MARK: Functions
    
    fileprivate func heightOfCellEqual(textview: UITextView) {
        if let lineHeight = textview.font?.lineHeight {
            let paddingBothBothSide = lineHeight * 1.5
            cellHeight = CGFloat( (CGFloat(textview.numberOfLines) *  lineHeight) + paddingBothBothSide)
        }
    }
    
}
