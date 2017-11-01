//
//  ReadNoteViewController.swift
//  MemoryMaster
//
//  Created by apple on 11/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit
import CoreData

private let cellReuseIdentifier = "ReadCollectionViewCell"

class ReadNoteViewController: EnlargeImageViewController {

    // public api
    var passedInNoteInfo: MyBasicNoteInfo?
    var passedInNotes = [CardContent]()
    var startCardIndexPath: IndexPath?
    
    @IBOutlet weak var progressBarView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    let addBookmarkButton = UIButton()
    let barFinishedPart = UIView()
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    var currentCardIndex: Int {
        return Int(collectionView.contentOffset.x) / Int(collectionView.bounds.width)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.setNeedsLayout()
        if let indexPath = startCardIndexPath {
            collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if var dict = UserDefaults.standard.dictionary(forKey: UserDefaultsKeys.lastReadStatus) {
            dict.updateValue((passedInNoteInfo?.id)!, forKey: UserDefaultsDictKey.id)
            dict.updateValue(currentCardIndex, forKey: UserDefaultsDictKey.cardIndex)
            dict.updateValue(ReadType.read.rawValue, forKey: UserDefaultsDictKey.readType)
            dict.updateValue("", forKey: UserDefaultsDictKey.cardStatus)
            UserDefaults.standard.set(dict, forKey: UserDefaultsKeys.lastReadStatus)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        super.titleLabel.text = passedInNoteInfo?.name
        self.automaticallyAdjustsScrollViewInsets = false
        
        addBookmarkButton.frame = CGRect(x: topView.bounds.width - CustomSize.buttonWidth - CustomDistance.midEdge,
                                  y: (CustomSize.barHeight - CustomSize.buttonHeight) / 2 + CustomSize.statusBarHeight,
                                  width: CustomSize.buttonWidth, height: CustomSize.buttonHeight)
        addBookmarkButton.setTitle("Save", for: .normal)
        addBookmarkButton.setTitleColor(UIColor.white, for: .normal)
        addBookmarkButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        addBookmarkButton.addTarget(self, action: #selector(addBookmarkAction), for: .touchUpInside)
        topView.addSubview(addBookmarkButton)
        
        progressBarView.layer.cornerRadius = 4
        progressBarView.layer.masksToBounds = true
        progressBarView.layer.borderWidth = 1
        progressBarView.layer.borderColor = CustomColor.medianBlue.cgColor
        progressBarView.backgroundColor = UIColor.white
        
        barFinishedPart.backgroundColor = CustomColor.medianBlue
        let startIndex = startCardIndexPath?.row ?? 0
        let barFinishedPartWidth = progressBarView.bounds.width / CGFloat(passedInNotes.count) * CGFloat(startIndex + 1)
        barFinishedPart.frame = CGRect(x: 0, y: 0, width: barFinishedPartWidth, height: progressBarView.bounds.height)
        progressBarView.addSubview(barFinishedPart)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: (collectionView?.bounds.width)!, height: (collectionView?.bounds.height)!)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionView.collectionViewLayout = layout
        
        let nib = UINib(nibName: cellReuseIdentifier, bundle: Bundle.main)
        collectionView?.register(nib, forCellWithReuseIdentifier: cellReuseIdentifier)
    }
    
    @objc func addBookmarkAction(_ sender: UIButton) {
        playSound.playClickSound(SystemSound.buttonClick)
        let placeholder = String(format: "%@-%@-%@-%d", (passedInNoteInfo?.name)!, (passedInNoteInfo?.type)!, ReadType.read.rawValue, currentCardIndex + 1)
        
        let alert = UIAlertController(title: "Bookmark", message: "Give a name for the bookmark.", preferredStyle: .alert)
        alert.addTextField { textFiled in
            textFiled.placeholder = placeholder
        }
        let ok = UIAlertAction(title: "OK", style: .default, handler: { [weak self] action in
            self?.playSound.playClickSound(SystemSound.buttonClick)
            var text = placeholder
            if alert.textFields![0].text! != "" {
                text = alert.textFields![0].text!
            }
            let isNameUsed = try? Bookmark.find(matching: text, in: (self?.container?.viewContext)!)
            if isNameUsed! {
                self?.showAlert(title: "Error!", message: "Name already used, please give another name.")
            } else {
                let bookmark = MyBookmark(name: text, id: (self?.passedInNoteInfo?.id)!, time: Date(), readType: ReadType.read.rawValue, readPage: (self?.currentCardIndex)!, readPageStatus: nil)
                self?.container?.performBackgroundTask({ (context) in
                    Bookmark.findOrCreate(matching: bookmark, in: context)
                    DispatchQueue.main.async {
                        self?.showSavedPrompt()
                    }
                })
            }
        })
        let cancel = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: draw prograss bar
    private func updatePrograssLing(readingIndex: CGFloat) {
        let width = progressBarView.bounds.width * (readingIndex + 1) / CGFloat(passedInNotes.count)
        UIView.animate(withDuration: 0.3, delay: 0.02, options: [], animations: {
            self.barFinishedPart.frame.size.width = width
        }, completion: nil)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePrograssLing(readingIndex: CGFloat(currentCardIndex))
    }
}

extension ReadNoteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return passedInNotes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let newCell = cell as! ReadCollectionViewCell
        newCell.updateUI(noteType: (passedInNoteInfo?.type)!, title: passedInNotes[indexPath.row].title, body: passedInNotes[indexPath.row].body, index: indexPath.row)
        newCell.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
    }
}
