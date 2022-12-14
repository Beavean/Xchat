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

final class FileStorage {

    // MARK: - Images

    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String?) -> Void) {
        let storageReference = storage.reference(forURL: Constants.fileReference).child(directory)
        guard let imageData = image.jpegData(compressionQuality: 0.6) else { return }
        var task: StorageUploadTask!
        task = storageReference.putData(imageData, metadata: nil, completion: { _, error in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            if let error {
                print("DEBUG: Error uploading image \(error.localizedDescription)")
                return
            }
            storageReference.downloadURL { url, _ in
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

    class func downloadImage(imageUrl: String, completion: @escaping (_ image: UIImage?) -> Void) {
        let imageFileName = fileNameFrom(fileUrl: imageUrl)
        if fileExistsAtPath(path: imageFileName) {
            if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)) {
                completion(contentsOfFile)
            } else {
                completion(UIImage(systemName: "person.crop.circle.fill"))
            }
        } else {
            if !imageUrl.isEmpty, let documentUrl = URL(string: imageUrl) {
                let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
                downloadQueue.async {
                    let data = NSData(contentsOf: documentUrl)
                    if let data {
                        FileStorage.saveFileLocally(fileData: data, fileName: imageFileName)
                        DispatchQueue.main.async {
                            completion(UIImage(data: data as Data))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Videos

    class func uploadVideo(_ video: NSData, directory: String, completion: @escaping (_ videoLink: String?) -> Void) {
        let storageRef = storage.reference(forURL: Constants.fileReference).child(directory)
        var task: StorageUploadTask!
        task = storageRef.putData(video as Data, metadata: nil, completion: { _, error in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            if let error {
                print("DEBUG: error uploading video \(error.localizedDescription)")
                return
            }
            storageRef.downloadURL { url, _ in
                guard let downloadUrl = url  else {
                    completion(nil)
                    return
                }
                completion(downloadUrl.absoluteString)
            }
        })
        task.observe(StorageTaskStatus.progress) { snapshot in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }

    class func downloadVideo(videoLink: String, completion: @escaping (_ isReadyToPlay: Bool, _ videoFileName: String) -> Void) {
        let videoUrl = URL(string: videoLink)
        let videoFileName = fileNameFrom(fileUrl: videoLink) + ".mov"
        if fileExistsAtPath(path: videoFileName) {
            completion(true, videoFileName)
        } else {
            let downloadQueue = DispatchQueue(label: "VideoDownloadQueue")
            downloadQueue.async {
                let data = NSData(contentsOf: videoUrl!)
                if let data {
                    FileStorage.saveFileLocally(fileData: data, fileName: videoFileName)
                    DispatchQueue.main.async {
                        completion(true, videoFileName)
                    }
                } else {
                    print("no document in database")
                }
            }
        }
    }

    // MARK: - Audio

    class func uploadAudio(_ audioFileName: String, directory: String, completion: @escaping (_ audioLink: String?) -> Void) {
        let fileName = audioFileName + ".m4a"
        let storageRef = storage.reference(forURL: Constants.fileReference).child(directory)
        var task: StorageUploadTask!
        if fileExistsAtPath(path: fileName) {
            if let audioData = NSData(contentsOfFile: fileInDocumentsDirectory(fileName: fileName)) {
                task = storageRef.putData(audioData as Data, metadata: nil, completion: { _, error in
                    task.removeAllObservers()
                    ProgressHUD.dismiss()
                    if let error {
                        print("error uploading audio \(error.localizedDescription)")
                        return
                    }
                    storageRef.downloadURL { url, _ in
                        guard let downloadUrl = url  else {
                            completion(nil)
                            return
                        }
                        completion(downloadUrl.absoluteString)
                    }
                })
                task.observe(StorageTaskStatus.progress) { snapshot in
                    let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
                    ProgressHUD.showProgress(CGFloat(progress))
                }
            } else {
                print("nothing to upload (audio)")
            }
        }
    }

    class func downloadAudio(audioLink: String, completion: @escaping (_ audioFileName: String) -> Void) {
        let audioFileName = fileNameFrom(fileUrl: audioLink) + ".m4a"
        if fileExistsAtPath(path: audioFileName) {
            completion(audioFileName)
        } else {
            let downloadQueue = DispatchQueue(label: "AudioDownloadQueue")
            downloadQueue.async {
                let data = NSData(contentsOf: URL(string: audioLink)!)
                if let data {
                    FileStorage.saveFileLocally(fileData: data, fileName: audioFileName)
                    DispatchQueue.main.async {
                        completion(audioFileName)
                    }
                } else {
                    print("no document in database audio")
                }
            }
        }
    }

    // MARK: - Save locally

    class func saveFileLocally(fileData: NSData, fileName: String) {
        let documentURL = getDocumentsURL().appendingPathComponent(fileName, isDirectory: false)
        fileData.write(to: documentURL, atomically: true)
    }
}

// MARK: - Helpers

func fileInDocumentsDirectory(fileName: String) -> String {
    getDocumentsURL().appendingPathComponent(fileName).path
}

func getDocumentsURL() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}

func fileExistsAtPath(path: String) -> Bool {
    FileManager.default.fileExists(atPath: fileInDocumentsDirectory(fileName: path))
}
