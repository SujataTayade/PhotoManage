//
//  TheMultiSelectorViewController.swift
//  AlbumDemo
//
//  Created by Weshare on 2018/3/28.
//  Copyright © 2018年 Weshare. All rights reserved.
//

import UIKit

import Photos

class TheMultiSelectorViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
//    let cLayout = UICollectionViewFlowLayout()
    @IBOutlet weak var cLayout: UICollectionViewFlowLayout!
    
    var assetsArray = [[PHAsset]]()
    var sectionHeaderTitleArray = [String]()
    var sectionItemCountArray = [Int]()
    
    var selectedType: PHAssetCollectionType = .album
    var selectedSubtype: PHAssetCollectionSubtype = .albumRegular
    
    var totalAssets: Int = 0

    //MARK: Lifecircle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupUI()
        initData()
    }
    // Initialize the UI
    func setupUI() {
        
        let nib = UINib(nibName: "PhotoSelectionCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "PhotoSelectionCellID")
        let headerNib = UINib(nibName: "HeaderCollectionReusableView", bundle: nil)
        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerID")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footerID")
        
        let swidth = UIScreen.main.bounds.width
//        let sheight = UIScreen.main.bounds.height
        let leading: CGFloat = 5
        let trailing: CGFloat = 5
        let spacing: CGFloat = 5
        let itemW: CGFloat = (swidth - leading - trailing - spacing*2)/4.0
        
        cLayout.minimumInteritemSpacing = spacing
        cLayout.minimumLineSpacing = spacing
        cLayout.itemSize = CGSize(width: itemW, height: itemW)
        cLayout.sectionInset = UIEdgeInsets(top: spacing, left: leading, bottom: spacing, right: trailing)
        cLayout.headerReferenceSize = CGSize(width: swidth, height: 40)
        cLayout.footerReferenceSize = CGSize(width: swidth, height: 0)
//        collectionView.setCollectionViewLayout(cLayout, animated: false)
        
        
    }
    //Initialization data
    func initData() {
        
        getAllCollections()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //MARK: - touch event
    
    //MARK: task
    
    func getAllCollections() -> Void {
        
        let assetCollections_album = PHAssetCollection.fetchAssetCollections(with: selectedType, subtype: selectedSubtype, options: nil)
        debugPrint("...........assetCollections.count = \(assetCollections_album.count)")
        if assetCollections_album.count != 0 {
            assetCollections_album.enumerateObjects { (collection, index, stop) in
                debugPrint("assetCollections index = \(index)")
                debugPrint("assetCollections name : \(collection.localizedTitle ?? "--title--")")
                debugPrint("assetCollections location : \(collection.localizedLocationNames.first ?? "--location--")")
                self.enumerateAssetsInAssetCollection(assetCollection: collection as PHAssetCollection)
            }
        }
    }
    
    func enumerateAssetsInAssetCollection(assetCollection: PHAssetCollection) -> Void {
        let assets = PHAsset.fetchAssets(in: assetCollection, options: nil)
        if assets.count > 0 {
            var assetArray = [PHAsset]()
            assets.enumerateObjects({ (asset, index, stop) in
                debugPrint("assets index = \(index)")
                assetArray.append(asset)
                if index == assets.count - 1 {
                    debugPrint("assets enum done!......")
                }
            })
            
            let title = assetCollection.localizedTitle ?? ""
            let location = assetCollection.localizedLocationNames.first ?? ""
            var showTitle = "???"
            if title != "" {
                showTitle = title
            }else if location != "" {
                showTitle = location
            }else if let date = assetCollection.startDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy,M,d"
                let dateStr = formatter.string(from: date)
                showTitle = dateStr
            }
            sectionHeaderTitleArray.append(showTitle)
            
            totalAssets += assetArray.count
            debugPrint("assetsArray append......totalAssets = \(totalAssets)")
            
            self.assetsArray.append(assetArray)
            self.collectionView.reloadData()
        }
    }
    
    //MARK: request
    
    

}

extension TheMultiSelectorViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return assetsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionArray = assetsArray[section]
        return sectionArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoSelectionCellID", for: indexPath) as! PhotoSelectionCell
        let sectionArray = assetsArray[indexPath.section]
        let asset = sectionArray[indexPath.row]
        
        let scale = UIScreen.main.scale
        let cellSize = cell.frame.size
        let AssetGridThumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        
        PHImageManager.default().requestImage(for: asset, targetSize: AssetGridThumbnailSize, contentMode: PHImageContentMode.default, options: nil) { (image, info) in
            cell.cstImageView.image = image
            cell.cstImageView.contentMode = .scaleAspectFit
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerID", for: indexPath) as! HeaderCollectionReusableView
            header.title = sectionHeaderTitleArray[indexPath.section]
            return header
        }else {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footerID", for: indexPath)
            return footer
        }
    }
    
}

extension TheMultiSelectorViewController: UICollectionViewDelegateFlowLayout {
    
    
    
}


