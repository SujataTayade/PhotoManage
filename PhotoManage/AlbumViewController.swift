//
//  AlbumViewController.swift
//  PhotoManage
//
//  Created by Sujata Tayade on 22/06/20.
//  Copyright © 2020 Sujata Tayade. All rights reserved.
//

import UIKit
import Photos

class AlbumViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var topicsTable: UITableView!
    var topicsarr:[String] = []
    var idalbumarr:[String] = []
    let cellReuseIdentifier = "tcell"
    
    
    @IBOutlet weak var albumtext: UITextField!
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        if textField == albumtext {
//            return false; //do not show keyboard nor cursor
//        }
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem( title: "Something Else", style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem?.title = ""
//        let yourBackImage = UIImage(named: "back_button_image")
//        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
//        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
//        self.navigationController?.navigationBar.backItem?.title = "Custom"
//
        
//        albumtext.delegate = self
//        albumtext.isEnabled = true
        
        
        // Do any additional setup after loading the view.
        
        //Get All user added albums
        //Get all user created albums
        
        /*
        let albumsPhoto:PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        albumsPhoto.enumerateObjects({(collection, index, object) in
            let photoInAlbum = PHAsset.fetchAssets(in: collection, options: nil)
                //print(photoInAlbum.count)
            print("Album Name : \(collection.localizedTitle ?? "nothing") - \(photoInAlbum.count)")
            self.topicsarr += [(collection.localizedTitle ?? "No Album") as String]
            self.idalbumarr += [(collection.localIdentifier) as String]
        })
        */
        
        
        let allPhotosOptions = PHFetchOptions()
//        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
//        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
//        smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
//        userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        
        let albumsPhoto:PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: allPhotosOptions)
        albumsPhoto.enumerateObjects({(collection, index, object) in
            let photoInAlbum = PHAsset.fetchAssets(in: collection, options: nil)
                //print(photoInAlbum.count)
            print("Album Name : \(collection.localizedTitle ?? "nothing") - \(photoInAlbum.count)")
            self.topicsarr += [(collection.localizedTitle ?? "No Album") as String]
            self.idalbumarr += [(collection.localIdentifier) as String]
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
            return 1;
        }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return topicsarr.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellReuseIdentifier)
            }
    //        if self. myArray.count > 0 {
    //            cell?.textLabel!.text = self. myArray[indexPath.row]
    //        }
    //        cell?.textLabel?.numberOfLines = 0
    //
    //        return cell!
            //let geteachsection = topicsarr[indexPath.section] as! NSDictionary
           // let eachsection = geteachsection["topic"] as! NSArray
            // set the text from the data model
            cell?.textLabel?.textColor = UIColor.darkGray
            cell?.textLabel?.text = topicsarr[indexPath.row]

            return cell!
        }
        // method to run when table view cell is tapped
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            print("You tapped cell number \(indexPath.row).")
            
            
            //Delete all user created albums
            let albumName = self.topicsarr[indexPath.row]
            let options = PHFetchOptions()
            options.predicate = NSPredicate(format: "title = %@", albumName)
            let album = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)

            if(album.firstObject?.localIdentifier == self.idalbumarr[indexPath.row]){
                // check if album is available
                if album.firstObject != nil {

                    // request to delete album
                    PHPhotoLibrary.shared().performChanges({PHAssetCollectionChangeRequest.deleteAssetCollections(album)
                }, completionHandler: { (success, error) in
                    if success {
                        print(" \(albumName) removed succesfully")
                        DispatchQueue.main.async {
                            //Do UI Code here.
                            //Call Google maps methods.
                            self.topicsarr.remove(at: indexPath.row)
                            self.idalbumarr.remove(at: indexPath.row)
                            self.topicsTable.reloadData()
                        }
                        
                    } else if error != nil {
                        print("request failed. please try again")
                    }
                })
                }else{
                    print("requested album \(albumName) not found in photos")
                }
            
            }
            else{
                print("\(String(describing: album.firstObject?.localIdentifier))  Not same identifier  \(self.idalbumarr[indexPath.row])")
            }
        }
    @IBAction func addAlbum(_ sender: Any) {
    
        let alertController = UIAlertController(title: NSLocalizedString("New Album", comment: ""), message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = NSLocalizedString("Album Name", comment: "")
        }
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default) { action in
                })
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Create", comment: ""), style: .default) { action in
            let textField = alertController.textFields!.first!
            if let title = textField.text, !title.isEmpty {
                // Create a new album with the entered title.
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title)
                    }, completionHandler: { success, error in
                        if !success { print("Error creating album: \(String(describing: error)).") }
                        else{
                            DispatchQueue.main.async {
                               //Do UI Code here.
                               //Call Google maps methods.
                                self.topicsarr = []
                               self.idalbumarr = []
                               
                               //Get all user created albums
                               let albumsPhoto:PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
                               albumsPhoto.enumerateObjects({(collection, index, object) in
                                   //let photoInAlbum = PHAsset.fetchAssets(in: collection, options: nil)
                                       //print(photoInAlbum.count)
                                   //print("Album Name : \(collection.localizedTitle ?? "nothing") - \(photoInAlbum.count)")
                                   self.topicsarr += [(collection.localizedTitle ?? "No Album") as String]
                                   self.idalbumarr += [(collection.localIdentifier) as String]
                               })
                               self.topicsTable.reloadData()
                               
                           }
                            
                        }
                    })
            }
        })
        
       
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addAlbumOld(_ sender: Any) {
        //Create Album
        let title = self.albumtext.text ?? "Default"
        
        if((self.albumtext.text) != nil) && ((self.albumtext.text) != ""){
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title)
            }, completionHandler: { success, error in
                if !success { print("Error creating album: \(String(describing: error)).") }
                else{
                    DispatchQueue.main.async {
                       //Do UI Code here.
                       //Call Google maps methods.
                        self.topicsarr = []
                       self.idalbumarr = []
                       
                       //Get all user created albums
                       let albumsPhoto:PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
                       albumsPhoto.enumerateObjects({(collection, index, object) in
                           //let photoInAlbum = PHAsset.fetchAssets(in: collection, options: nil)
                               //print(photoInAlbum.count)
                           //print("Album Name : \(collection.localizedTitle ?? "nothing") - \(photoInAlbum.count)")
                           self.topicsarr += [(collection.localizedTitle ?? "No Album") as String]
                           self.idalbumarr += [(collection.localIdentifier) as String]
                       })
                       self.topicsTable.reloadData()
                       self.albumtext.text = ""
                   }
                    
                }
            })
        }
       
    }
    
}
