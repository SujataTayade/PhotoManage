//
//  ViewController.swift
//  PhotoManage
//
//  Created by Sujata Tayade on 22/06/20.
//  Copyright © 2020 Sujata Tayade. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    var imagePicker = UIImagePickerController()
    var images:[UIImage] = []
    var imageassets:[PHAsset] = []
    var imagesidentifier:[String] = []
    var assetCollection: PHAssetCollection!
    var showalbum: String = "SujataNew"
    
    @IBOutlet weak var imageSuperView: UIView!
    @IBOutlet weak var imageSubView: UIView!
    @IBOutlet weak var imageDeleteView: UIView!
    @IBOutlet weak var albumtext: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Photos"
        self.imageSuperView.tag = 10
        self.imageSubView.tag = 11
        self.fetchPhotos()
    }
    func fetchPhotos () {
        
        self.images = []
        self.imagesidentifier = []
        self.imageassets = []
        for subview in self.imageSuperView.subviews {
            if (subview != self.imageDeleteView && subview != self.imageSubView) {
                if subview is UIView{
                    subview.removeFromSuperview()
                }
            }
        }
        
           // Sort the images by descending creation date and fetch the first 3
           let fetchOptions = PHFetchOptions()
           fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
           fetchOptions.fetchLimit = 16

           // Fetch the image assets
           let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)

           // If the fetch result isn't empty,
           // proceed with the image request
           if fetchResult.count > 0 {
               let totalImageCountNeeded = 16// <-- The number of images to fetch
               fetchPhotoAtIndexNew(0, totalImageCountNeeded, fetchResult)
           }
       }
    func fetchPhotoAtIndexNew(_ index:Int, _ totalImageCountNeeded: Int, _ fetchResult: PHFetchResult<PHAsset>) {
          let albumName = self.showalbum //"SujataNew"
            // Note that if the request is not set to synchronous
            // the requestImageForAsset will return both the image
            // and thumbnail; by setting synchronous to true it
            // will return just the thumbnail
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            let collection: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            for k in 0 ..< collection.count {
                //let obj:AnyObject! = collection.object(at: k)
              let checkalbum:String! = collection.object(at: k).localizedTitle!
              
              //print("collection : \(String(describing: collection.object(at: k).localizedTitle))")
             // print("collection1 : \(obj.title)")
              if (String(checkalbum!) == String(albumName)) {
                    //print("Yeap!")
                      print("checkalbum: \(checkalbum!) albumName: \(albumName)")
                  
                    // Perform the image request
                    PHImageManager.default().requestImage(for: fetchResult.object(at: index) as PHAsset, targetSize: CGSize(width: 1000, height: 1000), contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, info) in

                        if let image = image {
                            // Add the returned image to your array
                            self.images += [image]
                            self.imagesidentifier += [fetchResult.object(at: index).localIdentifier]
                            self.imageassets += [fetchResult.object(at: index)]
                            //print(fetchResult.object(at: index)) _ category
                        }
                        // If you haven't already reached the first
                        // index of the fetch result and if you haven't
                        // already stored all of the images you need,
                        // perform the fetch request again with an
                        // incremented index
                        if index + 1 < fetchResult.count && self.images.count < totalImageCountNeeded {
                            self.fetchPhotoAtIndexNew(index + 1, totalImageCountNeeded, fetchResult)
                        } else {
                            // Else you have completed creating your array
                            print("Completed array: \(self.images[0])")
                            //print("Image URL \(String(describing: info!["PHImageFileURLKey"]))")
                            //self.imageUrl = "\(info!["PHImageFileURLKey"]!)"
                            self.allimagesaddinview()
                        }
                      })
                }
            }
        }
    func allimagesaddinview(){
        
        var xval = Float()
        var yval = Float()
        xval = 0
        yval = 0
        var tagassign = NSInteger()
        tagassign = 0
        for eachimg in self.images {
            self.imageSuperView.addSubview(self.addeachviewimage(eachimg, CGFloat(xval), CGFloat(yval), tagassign))
            xval = xval + Float(CGFloat(self.imageSuperView.frame.size.width/4))
            if xval == Float(self.imageSuperView.frame.size.width){
                yval = yval + Float(CGFloat(self.imageSuperView.frame.size.height/6))
                xval = 0
            }
            tagassign = tagassign + 1
        }
    }
    func addeachviewimage(_ eachimg: UIImage, _ xval: CGFloat, _ yval: CGFloat, _ tag: NSInteger) -> UIView{
        
        let imageadd = UIView(frame: CGRect(x: CGFloat(xval), y: CGFloat(yval), width: self.imageSuperView.frame.size.width/4, height: self.imageSuperView.frame.size.height/6))
        imageadd.backgroundColor = UIColor.white
        imageadd.tag = tag
        imageadd.addGestureRecognizer(self.addpan())
        imageadd.addGestureRecognizer(self.addtab())
        var newimgview = UIImageView()
        newimgview = UIImageView(frame: CGRect(x: 1, y: 1, width: self.imageSuperView.frame.size.width/4-2, height: self.imageSuperView.frame.size.height/6-2))
        newimgview.clipsToBounds = true
        newimgview.image = eachimg
        newimgview.backgroundColor = UIColor.black
        newimgview.contentMode = UIView.ContentMode.scaleAspectFit
        imageadd.addSubview(newimgview)
        
        return imageadd
    }
    @IBAction func openGallery(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
           imagePicker.allowsEditing = true
           imagePicker.delegate = self
           imagePicker.sourceType = .savedPhotosAlbum //photoLibrary, camera, savedPhotosAlbum
           if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) {
             imagePicker.mediaTypes = mediaTypes
           }
           present(imagePicker, animated: true)
        }
    }
   @IBAction func ShowMulti(_ sender: Any) {
           let vc = TheMultiSelectorViewController(nibName: "TheMultiSelectorViewController", bundle: nil)
   //        vc.selectedType = selectedType
   //        vc.selectedSubtype = selectedSubtype
   //        vc.title = selectedTypeName + "->" + selectedSubtypeName
           
           vc.selectedType = .album
           vc.selectedSubtype = .albumRegular
           vc.title = "All User Created Albums"
           navigationController?.pushViewController(vc, animated: true)
       }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true, completion:nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        dismiss(animated: true, completion: (({
            //self.imageView.image = UIImage(named: "BGImage")
            if (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) != nil {
//                var newimgview = UIImageView()
//                 newimgview = UIImageView(frame: CGRect(x: 50, y: 100, width: 200, height:200))
//                 newimgview.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
//                 //self.addtoview.addSubview(newimgview)
//
//
//                 UIGraphicsBeginImageContext(newimgview.image!.size)
//                 newimgview.image!.draw(at: CGPoint.zero)
//                 let context:CGContext = UIGraphicsGetCurrentContext()!;
//                 let bez = UIBezierPath(rect: CGRect(x: 100, y: 100, width: 200, height: 200))
//                 context.addPath(bez.cgPath)
//                 context.clip();
//                 context.clear(CGRect(x: 0,y: 0,width: newimgview.image!.size.width,height: newimgview.image!.size.height));
//                 let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
//                 newimgview.image = newImage
//                 self.imageSuperView.addSubview(newimgview)
//                 UIGraphicsEndImageContext();
                let  newimg:UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
                self.images += [newimg]
                self.imagesidentifier += [ (info[UIImagePickerController.InfoKey.phAsset] as! PHAsset).localIdentifier]
                self.imageassets += [info[UIImagePickerController.InfoKey.phAsset] as! PHAsset]
                for subview in self.imageSuperView.subviews {
                    if (subview != self.imageDeleteView && subview != self.imageSubView) {
                        if subview is UIView{
                            subview.removeFromSuperview()
                        }
                    }
                }
                self.allimagesaddinview()
            }
            self.dismiss(animated: true, completion: nil)
        })))
    }
    
    
    
    
    func addpan() -> UITapGestureRecognizer{
            let tapGesture = UITapGestureRecognizer(
              target: self,
              action: #selector(self.handleTab)
            )
            tapGesture.delegate = self
            return tapGesture
        }
        func addtab() -> UIPanGestureRecognizer{
            let panGesture = UIPanGestureRecognizer(
              target: self,
              action: #selector(self.handlePan)
            )
            panGesture.delegate = self
            return panGesture
        }
        
        @IBAction func handlePan(_ gesture: UIPanGestureRecognizer) {
          // 1
          let translation = gesture.translation(in: view)

          // 2
          guard let gestureView = gesture.view else {
            return
          }
         
          gestureView.center = CGPoint(
            x: gestureView.center.x + translation.x,
            y: gestureView.center.y + translation.y
          )

    //        print("x: \(gestureView.frame.origin.x) and y: \(gestureView.frame.origin.y)")
    //        print("x1: \(self.imageSubView.frame.origin.x) and y1: \(self.imageSubView.frame.origin.y)")
            gesture.setTranslation(.zero, in: view)
           let frameInParent = self.imageSuperView.convert(self.imageSubView.frame, from: self.imageSubView.superview)
           let isOverlaps = frameInParent.intersects(gestureView.frame)
            
            let frameInParent1 = self.imageSuperView.convert(self.imageDeleteView.frame, from: self.imageDeleteView.superview)
            let isOverlaps1 = frameInParent1.intersects(gestureView.frame)
            
            
//            if(isOverlaps){
//                self.imageSubView.backgroundColor = UIColor.gray
//            }
//            else{
//                self.imageSubView.backgroundColor = UIColor.white
//            }
            
           if gesture.state == .began {
               // Save the view's original position.
                gestureView.alpha = 0.7
                gestureView.frame.size.height = 10
                gestureView.frame.size.width  = 10
           }
           else if gesture.state == .ended{
                if(isOverlaps1){
                    print("isOverlaps \(isOverlaps)")
                    let sView =  gestureView.superview! as UIView//.compactMap{$0 as? UIView}
                    print("gestureView.tag = \(gestureView.tag)")
                    if(sView.tag == 10){
                        var indexdelete = NSInteger()
                        indexdelete = gestureView.tag

                        var iddelete = String()
                        iddelete = self.imagesidentifier[indexdelete]

                        self.deleteImg(photoid: iddelete, toAlbum: "Sujata1", completionHandler: { success, error in
                            if !success { print("Error deleting album: \(String(describing: error)).")}
                            else{
                                DispatchQueue.main.async {
                                    //gestureView.removeFromSuperview()
                                    self.fetchPhotos()
                                }
                            }
                        })
                    }
                }
            
                if(isOverlaps){
                     print("isOverlaps \(isOverlaps)")
    //                var immg = UIImageView()
    //                immg = gesture.view.subviews.filter{$0 is UIImageView}
    //                print(immg)
                    let sView =  gestureView.superview! as UIView//.compactMap{$0 as? UIView}
                    print("gestureView.tag = \(gestureView.tag)")
                    if(sView.tag == 10){
                        //Remove Image
                        //deleteImg(photoid: String, toAlbum titled: String
                        var indexdelete = NSInteger()
                        indexdelete = gestureView.tag
    //
    //                    var iddelete = String()
    //                    iddelete = self.imagesidentifier[indexdelete]
    //
    //                    self.deleteImg(photoid: iddelete, toAlbum: "Sujata1", completionHandler: { success, error in
    //                        if !success { print("Error deleting album: \(String(describing: error)).")}
    //                    })
                        let title = self.albumtext.text!
                        if(title == ""){
                            let refreshAlert = UIAlertController(title: "Album", message: "Add album name", preferredStyle: UIAlertController.Style.alert)
                            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
                             }))
                            present(refreshAlert, animated: true, completion: nil)
                        }
                        else{
                            let fetchOptions = PHFetchOptions()
                            fetchOptions.predicate = NSPredicate(format: "title = %@", title)
                            var collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
                            if((collections.firstObject) == nil){
                                PHPhotoLibrary.shared().performChanges({
                                    PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title)
                                }, completionHandler: { success, error in
                                    if !success {
                                        print("Error creating album: \(String(describing: error)).")
                                        
                                    }
                                    else{
                                         collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
                                        
                                        
                                        self.moveImage(image: self.images[indexdelete], album: collections.firstObject!, completionHandler: { success, error in
                                            print("Moved")
                                            if !success { print("Error coping album: \(String(describing: error)).")}
                                            else{
                                                DispatchQueue.main.async {
                                                    //gestureView.removeFromSuperview()
                                                    self.fetchPhotos()
                                                }
                                            }
                                        })
                                    }
                                    
                                })
                               
                            }
                            else{
                                self.moveImage(image: self.images[indexdelete], album: collections.firstObject!, completionHandler: { success, error in
                                    if !success { print("Error coping album: \(String(describing: error)).")}
                                    else{
                                        DispatchQueue.main.async {
                                            //gestureView.removeFromSuperview()
                                            self.fetchPhotos()
                                        }
                                    }
                                })
                            }
                        }
                        
                        
                    }
                    
                    /*if((sView.tag == 10) && (gestureView.tag != 10)){
                        //Copy Image
                        let myViews = gestureView.subviews.compactMap{$0 as? UIImageView}
                        var immgv = UIImageView()
                        immgv = myViews[0]
                        var immg = UIImage()
                        immg = immgv.image!
                        print(immg)
                        self.save(photo:immg, toAlbum: "Sujata1", completionHandler:{ success, error in
                            if !success { print("Error creating album: \(String(describing: error)).")}
                        })
                        gestureView.tag = 10
                    }*/
                    
                }
                else{
                    print("isOverlaps \(isOverlaps)")
                }
                gestureView.alpha = 1
//                self.imageSubView.backgroundColor = UIColor.white
            
                gestureView.frame.size.height = self.imageSuperView.frame.size.height/6-2
                gestureView.frame.size.width  = self.imageSuperView.frame.size.width/4-2
            }
        }
        
         @IBAction func handleTab(_ gesture: UITapGestureRecognizer) {
    //        let translation = gesture.view
            // 2
            guard let gestureView = gesture.view else {
              return
            }
            if(gestureView.tag == 0){
                let blurrview = UIView(frame: CGRect(x: 0, y: 0, width: gestureView.frame.size.width, height: gestureView.frame.size.height))
                blurrview.backgroundColor = UIColor.black
                blurrview.alpha = 0.4
                blurrview.tag = 5
                gestureView.addSubview(blurrview)
                
                let checkview = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
                checkview.backgroundColor = UIColor.green
                checkview.tag = 5
                gestureView.addSubview(checkview)
                gestureView.tag = 1
            }
            else{
                for view in gestureView.subviews{
                    if(view.tag == 5){
                        view.removeFromSuperview()
                    }
                }
                gestureView.tag = 0
            }
        }
    
    func deleteImg(photoid: String, toAlbum titled: String, completionHandler: @escaping (Bool, Error?) -> ()) {
        getAlbum(title: titled) { (album) in
            DispatchQueue.global(qos: .background).async {
                
                let fetchopt = PHFetchOptions()
                let assetToDelete = PHAsset.fetchAssets(withLocalIdentifiers: [photoid], options: fetchopt)
                PHPhotoLibrary.shared().performChanges({
                  PHAssetChangeRequest.deleteAssets(assetToDelete)
                }, completionHandler: { (created, error) in
                    if (error == nil){
                        print("created : \(created)")
                        completionHandler(created, error)
                    }

                    
                })
            }
        }
        
    }
    
    func moveImage(image: UIImage, album: PHAssetCollection, completionHandler: @escaping (Bool, Error?) -> ()) {
                var placeholder: PHObjectPlaceholder?
                PHPhotoLibrary.shared().performChanges({
                        // Request creating an asset from the image
                        let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                        // Request editing the album
                        guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) else {
                            assert(false, "Album change request failed")
                            return
                        }
                        // Get a placeholder for the new asset and add it to the album editing request
                        guard let photoPlaceholder = createAssetRequest.placeholderForCreatedAsset else {
                            assert(false, "Placeholder is nil")
                            return
                        }
                        placeholder = photoPlaceholder
                        albumChangeRequest.addAssets([photoPlaceholder] as NSFastEnumeration)
                        //albumChangeRequest.moveAssets(at: [1], to: 2)
                }, completionHandler: { (created, error) in
                    if (error == nil){
                        print("created : \(created)")
                        completionHandler(created, error)
                    }

                    
                })
        }
    func getAlbum(title: String, completionHandler: @escaping (PHAssetCollection?) -> ()) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", title)
            let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

            if let album = collections.firstObject {
                
                
                
                completionHandler(album)
            } else {
                self?.createAlbum(withTitle: title, completionHandler: { (album) in
                    completionHandler(album)
                })
            }
        }
    }
    func createAlbum(withTitle title: String, completionHandler: @escaping (PHAssetCollection?) -> ()) {
        DispatchQueue.global(qos: .background).async {
            var placeholder: PHObjectPlaceholder?

            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title)
                placeholder = createAlbumRequest.placeholderForCreatedAssetCollection
            }, completionHandler: { (created, error) in
                var album: PHAssetCollection?
                if created {
                    let collectionFetchResult = placeholder.map { PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [$0.localIdentifier], options: nil) }
                    album = collectionFetchResult?.firstObject
                }

                completionHandler(album)
            })
        }
    }
}

