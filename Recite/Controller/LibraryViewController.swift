//
//  LibraryViewController.swift
//  MemoryMaster
//
//  Created by apple on 1/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import CoreData

private let cellReuseIdentifier = "LibraryTableViewCell"

class LibraryViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var allNoteButton: UIButton!
    @IBOutlet weak var qaNoteButton: UIButton!
    @IBOutlet weak var singleNoteButton: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .none
        }
    }
    let topView = UIView()
    let nothingFoundLabel = UILabel()
    
    // public api
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    var fetchedResultsController: NSFetchedResultsController<BasicNoteInfo>?
    
    var searchController: UISearchController!
    
    var lastType = ""
    var selectedCellIndex: IndexPath?
    var showFlag: NoteType = .all
    
    fileprivate let playSound = SystemAudioPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(returnKeyBoard))
        swipeRecognizer.direction = .down
        swipeRecognizer.numberOfTouchesRequired = 1
        tableView.addGestureRecognizer(swipeRecognizer)
        swipeRecognizer.delegate = self
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        // eliminate black line above searchBar
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.backgroundImage = UIImage()
        
        // set searchBar textField to round corner
        let searchField = searchController.searchBar.value(forKey: "searchField") as? UITextField
        searchField?.layer.cornerRadius = 14
        searchField?.layer.masksToBounds = true
        
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.barTintColor = CustomColor.deepBlue
        self.definesPresentationContext = false
        
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        updateUI(noteType: showFlag, searchKeyWord: nil)
        searchController.searchBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.text = nil
        searchController.searchBar.resignFirstResponder()
        searchController.searchBar.isHidden = true
    }
    
    private func setupUI()
    {
        topView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: CustomSize.barHeight + CustomSize.statusBarHeight)
        topView.backgroundColor = CustomColor.medianBlue
        view.addSubview(topView)
        view.sendSubview(toBack: topView)
        
        allNoteButton.setImage(UIImage(named: "all_icon_click.png"), for: .normal)
        singleNoteButton.setImage(UIImage(named: "single_icon_unclick.png"), for: .normal)
        qaNoteButton.setImage(UIImage(named: "qa_icon_unclick.png"), for: .normal)
        
        addButton.tintColor = UIColor.white
        
        tableView.rowHeight = 44
        let nib = UINib(nibName: cellReuseIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellReuseIdentifier)
        
        nothingFoundLabel.frame = CGRect(x: 0, y: tableView.rowHeight, width: UIScreen.main.bounds.width, height:  tableView.rowHeight)
        nothingFoundLabel.text = "Nothing Found"
        nothingFoundLabel.textColor = CustomColor.wordGray
        nothingFoundLabel.textAlignment = .center
        tableView.addSubview(nothingFoundLabel)
    }
    
    func updateUI(noteType: NoteType, searchKeyWord: String?) {
        if let context = container?.viewContext {
            let request: NSFetchRequest<BasicNoteInfo> = BasicNoteInfo.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(
                key: "name",
                ascending: true,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
            )]
            if let searchKeyWord = searchKeyWord, searchKeyWord != "" {
                if noteType != NoteType.all {
                    request.predicate = NSPredicate(format: "type == %@ && name CONTAINS[c] %@", noteType.rawValue, searchKeyWord)
                } else {
                    request.predicate = NSPredicate(format: "name CONTAINS[c] %@", searchKeyWord)
                }
            } else if noteType != NoteType.all {
                request.predicate = NSPredicate(format: "type == %@", noteType.rawValue)
            }
            fetchedResultsController = NSFetchedResultsController<BasicNoteInfo>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            fetchedResultsController?.delegate = self
            try? fetchedResultsController?.performFetch()
            tableView.reloadData()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func showAllNote(_ sender: UIButton) {
        showFlag = NoteType.all
        allNoteButton.setImage(UIImage(named: "all_icon_click.png"), for: .normal)
        qaNoteButton.setImage(UIImage(named: "qa_icon_unclick.png"), for: .normal)
        singleNoteButton.setImage(UIImage(named: "single_icon_unclick.png"), for: .normal)
        updateUI(noteType: showFlag, searchKeyWord: nil)
    }
    
    @IBAction func showQANote(_ sender: UIButton) {
        showFlag = NoteType.qa
        allNoteButton.setImage(UIImage(named: "all_icon_unclick.png"), for: .normal)
        qaNoteButton.setImage(UIImage(named: "qa_icon_click.png"), for: .normal)
        singleNoteButton.setImage(UIImage(named: "single_icon_unclick.png"), for: .normal)
        updateUI(noteType: showFlag, searchKeyWord: nil)
    }
    
    @IBAction func showSingleNote(_ sender: UIButton) {
        showFlag = NoteType.single
        allNoteButton.setImage(UIImage(named: "all_icon_unclick.png"), for: .normal)
        qaNoteButton.setImage(UIImage(named: "qa_icon_unclick.png"), for: .normal)
        singleNoteButton.setImage(UIImage(named: "single_icon_click.png"), for: .normal)
        updateUI(noteType: showFlag, searchKeyWord: nil)
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToNoteViewController" {
            let controller = segue.destination as! NoteViewController
            controller.container = self.container
            if let card = fetchedResultsController?.object(at: selectedCellIndex!) {
                let passCard = MyBasicNoteInfo(id: Int(card.id), time: card.createTime as Date, type: card.type, name: card.name, numberOfCard: Int(card.numberOfCard))
                controller.passedInNoteInfo = passCard
                controller.container = container
            }
        } 
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    @objc func returnKeyBoard(byReactionTo swipeRecognizer: UISwipeGestureRecognizer) {
        if swipeRecognizer.state == .ended {
            if searchController.searchBar.isFirstResponder {
                searchController.searchBar.resignFirstResponder()
                searchController.searchBar.setShowsCancelButton(false, animated: true)
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if searchController.searchBar.isFirstResponder {
            tableView.isScrollEnabled = false
            return true
        } else {
            tableView.isScrollEnabled = true
            return false
        }
    }
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        playSound.playClickSound(SystemSound.buttonClick)
    }
}

extension LibraryViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        updateUI(noteType: showFlag, searchKeyWord: searchController.searchBar.text)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
}

extension LibraryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            if sections[section].numberOfObjects == 0 {
                nothingFoundLabel.isHidden = false
            } else {
                nothingFoundLabel.isHidden = true
            }
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LibraryTableViewCell", for: indexPath) as! LibraryTableViewCell
        if let card = fetchedResultsController?.object(at: indexPath) {
            cell.awakeFromNib()
            cell.updateCell(with: card, lastCardType: lastType)
            lastType = card.type
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCellIndex = indexPath
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ToNoteViewController", sender: indexPath)
    }
        
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let note: BasicNoteInfo! = fetchedResultsController?.object(at: indexPath)
            for i in 0..<Int(note.numberOfCard) {
                CardContent.removeCardContent(with: note.name, at: i, in: note.type)
            }
            let context = container?.viewContext
            Bookmark.remove(matching: note.id, in: context!)
            context?.delete(note)
            try? context?.save()
        }
    }
}

extension LibraryViewController: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: tableView.insertSections([sectionIndex], with: .fade)
        case .delete: tableView.deleteSections([sectionIndex], with: .fade)
        default: break
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
