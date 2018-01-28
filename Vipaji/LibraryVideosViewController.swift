//
//  LibraryVideosViewController.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 10/26/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "LibraryVideo"

class LibraryVideosViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var videoAssets: PHFetchResult<PHAsset>?
    var videos: [Int : AVURLAsset] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Collection View
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                print("Good to proceed")
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false) ]
                self.videoAssets = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                print("Found \(self.videoAssets!.count) videos")
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                print("Not determined yet")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoAssets!.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Asynchronously load and set preview image
        let asset = videoAssets![indexPath.row]
        guard (asset.mediaType == PHAssetMediaType.video)   else {
            print("Not a valid video media type")
            return cell
        }
        
        DispatchQueue.global(qos: .background).async {
            PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil) { (asset, audioMix, dict) in
                DispatchQueue.main.async {
                    self.videos[indexPath.row] = asset as! AVURLAsset
                    
                    let previewImageView = UIImageView()
                    previewImageView.generated(fromAsset: asset as! AVURLAsset)
                    cell.backgroundView = previewImageView
                }
            }
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width/3 - 1
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Create usable copy of file
        let fileURL = videos[indexPath.row]!.url
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!)
        let timestamp = UInt64((NSDate().timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
        let destURL = documentsPath.appendingPathComponent("\(timestamp).mp4")
        
        /* shouldnt be necessary
        if FileManager.default.fileExists(atPath: destURL!.absoluteString) {
            try! FileManager.default.removeItem(at: destURL!)
        }
        */
        
        do {
            try FileManager.default.copyItem(at: fileURL, to: destURL!)
        } catch {
            print("Error: Unable to copy asset file")
        }
        
        // Create and present upload view
        let uploadVC = storyboard?.instantiateViewController(withIdentifier: "UploadPost") as! NewUploadViewController
        uploadVC.videoURL = destURL
        
        navigationController?.pushViewController(uploadVC, animated: true)
    }
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
