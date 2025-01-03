//
//  SaveAudioManager.swift
//  AudioRecApp
//
//  Created by Yusuf Tarık Gün on 8.12.2024.
//

import UIKit
import NeonSDK
import FirebaseStorage

final class SaveAudioManager {
    static let shared = SaveAudioManager()
    
    func uploadAudio(_ data: Data, completion: @escaping (String?) -> Void) {
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let audioID = UUID().uuidString
        let audioRef = storageReference.child("Audio/\(audioID).wav")
        
        let metadata = StorageMetadata()
        metadata.contentType = "audio/wav"
        
        audioRef.putData(data, metadata: metadata) { metadata, error in
            if let error = error {
                print("Failed to upload audio: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            audioRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                if let downloadURL = url {
                    print("Audio uploaded successfully: \(downloadURL.absoluteString)")
                    completion(downloadURL.absoluteString)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func getAudio(_ url: String, completion: @escaping (Data?, Error?) -> Void) {

        let storage = Storage.storage().reference(forURL: url)
        storage.getData(maxSize: 6400000) { data, error in
            
            if let error = error {
                print("Failed to get audio: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            if let data = data {
                completion(data, nil)
            } else {
                let error = NSError(domain: "FirebaseStorage", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])
                completion(nil, error)
            }
        }
    }
}
