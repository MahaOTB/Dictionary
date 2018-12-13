//
//  SearchViewController.swift
//  Dictionary
//
//  Created by Maha on 06/12/2018.
//  Copyright © 2018 Maha_AlOtaibi. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tfWord: UITextField!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var btnFavorites: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var lexicals = [Lexical]()
    var cellHeight: CGFloat?
    lazy var viewContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfWord.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let text = tfWord.text, !text.isEmpty {
            _ = isAddedToFavorite()
        }
    }
    
    // MARK: Actions
    
    @IBAction func searchBtnTapped(_ sender: Any) {
        tfWord.resignFirstResponder()
        
        if isAddedToFavorite() {
            btnFavorites.tintColor = UIColor.yellow
            return
        }
        
        btnFavorites.tintColor = UIColor.lightGray
        searchWordInOxfordDictionary()
    }
    
    @IBAction func favoriteBtnTapped(_ sender: Any) {
        addRemoveFavorite()
    }
    
    // MARK: Functions
    
    func isAddedToFavorite() -> Bool {
        let fetchRequest: NSFetchRequest<WordEntity> = WordEntity.fetchRequest()
        let predicate = NSPredicate(format: "\(Id.WordText) like[cd] %@", tfWord.text!)
        fetchRequest.predicate = predicate
        
        do {
            
            let wordEntities = try viewContext.fetch(fetchRequest)
            if wordEntities.count > 0 {
                convertResultToArray(wordEntities)
                tableView.reloadData()
                return true
            }
            btnFavorites.tintColor = UIColor.lightGray
        }catch {
            present(Alert.createUIAlert(title: Alert.ErrorTitle, message: error.localizedDescription), animated: true)
        }
        return false
    }
    
    fileprivate func searchWordInOxfordDictionary() {
        guard let text = tfWord.text, !text.isEmpty else {
            updateTableView(with: nil)
            present(Alert.createUIAlert(message: Alert.EmptyText), animated: true)
            return
        }
        
        isStartSearching(true)
        
        Word.getWordDefinitions(word: text) { (wordLexical, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    self.present(Alert.createUIAlert(title: Alert.ErrorTitle, message: error!.localizedDescription), animated: true)
                    self.isStartSearching(false)
                    self.updateTableView(with: nil) // Remove previous search result
                }
                return
            }
            
            guard let wordLexical = wordLexical else {return}
            
            DispatchQueue.main.async {
                self.isStartSearching(false)
                self.updateTableView(with: wordLexical.lexicals)
            }
        }
    }
    
    fileprivate func convertResultToArray(_ result: [WordEntity]) {
        // encapsulate result in [Lexical]
        var lexicalsArray = [Lexical]()
        let wordEntity = result[0]
        
        let lexicalEntities = wordEntity.lexicals?.array as! [LexicalEntity]
        for lexicalEntity in lexicalEntities {
            let definitionEntities = lexicalEntity.definitions?.array as! [DefinitionEntity]
            
            var definitionArray = [String]()
            for definitionEntity in definitionEntities {
                if let definition = definitionEntity.definition {
                    definitionArray.append(definition)
                }
            }
            
            guard let category = lexicalEntity.category else {continue}
            let lexicalObject = Lexical(category: category, definitions: definitionArray)
            lexicalsArray.append(lexicalObject)
        }
        
        lexicals.removeAll()
        updateTableView(with: lexicalsArray)
    }
    
    func updateTableView(with lexicalResult: [Lexical]?) {
        lexicalResult != nil ? lexicals.append(contentsOf: lexicalResult!) : lexicals.removeAll()
        tableView.reloadData()
    }
    
    func isStartSearching(_ isTrue: Bool) {
        isTrue == true ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        lexicals.removeAll()
        btnSearch.isEnabled = !isTrue
        tableView.isHidden = isTrue
    }
    
    func isEmptyTableView(_ isTrue: Bool) {
        btnFavorites.isEnabled = !isTrue
        tableView.isHidden = isTrue
    }
    
    func addRemoveFavorite() {
        if btnFavorites.tintColor == UIColor.yellow {
            deleteFromFavorites()
        } else {
            saveToFavorites()
        }
    }
    
    func saveToFavorites() {
        
        let word = WordEntity(context: viewContext)
        word.text = tfWord.text?.capitalizingFirstLetter()
        
        var lexicalArray = [LexicalEntity]()
        var definitionsArray = [DefinitionEntity]()
        
        for lexical in lexicals {
            definitionsArray = []
            
            let wordLexical = LexicalEntity(context: viewContext)
            wordLexical.category = lexical.category
            wordLexical.word = word
            
            lexicalArray.append(wordLexical)
            
            for definition in lexical.definitions {
                let lexicalDefinition = DefinitionEntity(context: viewContext)
                lexicalDefinition.definition = definition
                lexicalDefinition.lexical = wordLexical
                
                definitionsArray.append(lexicalDefinition)
            }
            
            wordLexical.definitions = NSOrderedSet(array: definitionsArray)
            
        }
        word.lexicals = NSOrderedSet(array: lexicalArray)
        
        do {
            try viewContext.save()
            btnFavorites.tintColor = UIColor.yellow
        }catch {
            present(Alert.createUIAlert(title: Alert.ErrorTitle, message: error.localizedDescription), animated: true)
        }
        
    }
    
    func deleteFromFavorites() {
        let fetchRequest: NSFetchRequest<WordEntity> = WordEntity.fetchRequest()
        let predicate = NSPredicate(format: "\(Id.WordText) like[cd] %@", tfWord.text!)
        fetchRequest.predicate = predicate
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            if let deletedWord = result.first {
                viewContext.delete(deletedWord)
                try viewContext.save()
                btnFavorites.tintColor = UIColor.lightGray
            }
        } catch {
            present(Alert.createUIAlert(title: Alert.ErrorTitle, message: error.localizedDescription), animated: true)
        }
    }
    
    fileprivate func heightOfCellEqual(textview: UITextView) {
        if let lineHeight = textview.font?.lineHeight {
            let paddingBothSide = lineHeight * 1.5
            cellHeight = CGFloat( (CGFloat(textview.numberOfLines) *  lineHeight) + paddingBothSide)
            
            
        }
    }
    
}

// MARK:  UITableViewDataSource Delegate _______________________________________________

extension SearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        lexicals.count == 0 ? isEmptyTableView(true) : isEmptyTableView(false)
        return lexicals.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lexicals[section].definitions.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return lexicals[section].category
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Id.DefinitionsCellReuseidentifier) as! DefinitionsTableViewCell
        
        cell.definitionNoLabel.text = "Definition \(indexPath.row + 1)"
        
        let definitionsText = lexicals[indexPath.section].definitions[indexPath.row]
        cell.definitionTextView.text = definitionsText.capitalizingFirstLetter()
        
        heightOfCellEqual(textview: cell.definitionTextView)
        
        return cell
    }
    
}

// MARK:  UITableViewDelegate Delegate _______________________________________________

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard cellHeight != nil else {return 100}
        return cellHeight!
    }
}

// MARK:  UITextFieldDelegate Delegate _______________________________________________

extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if isAddedToFavorite() {
            btnFavorites.tintColor = UIColor.yellow
            return true
        }
        
        btnFavorites.tintColor = UIColor.lightGray
        searchWordInOxfordDictionary()
        return true
    }
    
}
