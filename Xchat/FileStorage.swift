//
//  FileStorage.swift
//  Xchat
//
//  Created by Beavean on 11.11.2022.
//

import Foundation
import FirebaseStorage
import ProgressHUD

let storage = Storage.storage()

class FileStorage {
    
    //MARK: - Images
    
    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String?) -> Void) {
        let storageReference = storage.reference(forURL: kFILEREFERENCE).child(directory)
        guard let imageData = image.jpegData(compressionQuality: 0.6) else { return }
        var task: StorageUploadTask!
        task = storageReference.putData(imageData, metadata: nil, completion: { metadata, error in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            if let error {
                print("DEBUG: Error uploading image \(error.localizedDescription)")
                return
            }
            storageReference.downloadURL { url, error in
                guard let url else {
                    completion(nil)
                    return
                }
                completion(url.absoluteString)
            }
        })
        task.observe(StorageTaskStatus.progress) { snapshot in
            if let snapshotProgress = snapshot.progress {
                let progress = snapshotProgress.completedUnitCount / snapshotProgress.totalUnitCount
                ProgressHUD.showProgress(CGFloat(progress))
            }
        }
    }
    
    //MARK: - Save locally
    
    class func saveFileLocally(fileData: NSData, fileName: String) {
        let documentURL = getDocumentsURL().appendingPathComponent(fileName, isDirectory: false)
        fileData.write(to: documentURL, atomically: true)
    }
}

//MARK: - Helpers

func fileInDocumentsDirectory(fileName: String) -> String {
    getDocumentsURL().appendingPathComponent(fileName).path
}

func getDocumentsURL() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}

func fileExistsAtPath(path: String) -> Bool {
    FileManager.default.fileExists(atPath: fileInDocumentsDirectory(fileName: path))
}
