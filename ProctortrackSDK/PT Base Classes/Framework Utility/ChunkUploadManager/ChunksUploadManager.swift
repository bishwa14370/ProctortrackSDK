//
//  ChunksUploadManager.swift
//  ProctorTrack
//
//  Created by Diwakar Garg on 28/01/2019.
//  Copyright © 2017 Diwakar Garg. All rights reserved.
//

import UIKit
//Mutable Array declare and initialize the DirectoryFilePathArray
var directoryFilePathArray = [String]()
var chunkNumber: String?


class ChunksUploadManager {
    
    //Method for fetching the chunk from directory
    class func chunksListFromDirectory(completionHandler : @escaping (Bool) -> Void)
    {
        var tempArray = [String]()
        if let listArray = listFilesFromDocumentsFolder() {
            tempArray = listArray
        }
        directoryFilePathArray = tempArray.sorted { $0.compare($1, options: .numeric) == .orderedAscending }
        
        if (directoryFilePathArray.count > 0) {
            self.requestOneByOneChunkUpload(completionHandler: {(success) in
                if(success)
                {
                    completionHandler(true)
                }
                else
                {
                    completionHandler(false)
                }
            })
        }
    }
    
    //Chunk Uploding One by one request
    class  func requestOneByOneChunkUpload(completionHandler : @escaping (Bool) -> Void)
    {
        if (directoryFilePathArray.count > 0)
        {
            let queue = DispatchQueue(label: "Chunk upload", qos: DispatchQoS.background)
            queue.async {
                do {
                    let videoData = try NSData(contentsOfFile: (getDirectoryPath() as NSString).appendingPathComponent((directoryFilePathArray[0])), options: .mappedIfSafe)
                    if (((getDirectoryPath() as NSString).appendingPathComponent((directoryFilePathArray[0])).slice(from: fileNameForMonitoring, to: ".")) != nil)
                    {
                        chunkNumber = ((getDirectoryPath() as NSString).appendingPathComponent((directoryFilePathArray[0])).slice(from: fileNameForMonitoring, to: "."))
                    }
                    else if ((getDirectoryPath() as NSString).appendingPathComponent((directoryFilePathArray[0])).slice(from: notesImageName, to: ".")) != nil {
                        
                        chunkNumber = ((getDirectoryPath() as NSString).appendingPathComponent((directoryFilePathArray[0])).slice(from: notesImageName, to: "."))
                    }
                    // I think this is not necessary
                    else if((getDirectoryPath() as NSString).appendingPathComponent((directoryFilePathArray[0])).slice(from: roomScanVideoName, to: ".")) != nil
                    {
                        if(roomScanRequired == true && photoIdRequired == true && faceScanRequired == true)
                        {
                            chunkNumber = "3"
                        }
                        else if(roomScanRequired == true && photoIdRequired == false && faceScanRequired == true)
                        {
                            chunkNumber = "2"
                        }
                        else if(roomScanRequired == true && photoIdRequired == false && faceScanRequired == false)
                        {
                            chunkNumber = "1"
                        }
                    }
                    else if ((getDirectoryPath() as NSString).appendingPathComponent((directoryFilePathArray[0]))).contains("InstitutionList") {
                        //   SearchInstitutionServices.removeDirectory(directoryName: "InstitutionList")
                    }
                    self.requestForUploadUrl(fileSize: ((String(describing: videoData.length) as NSString) as String) as String, videoFileName:(((directoryFilePathArray[0]) as NSString) as String) as String, videoFile:videoData, filePath:(getDirectoryPath() as NSString).appendingPathComponent((directoryFilePathArray[0])) as NSString,completionHandler: {(success) in
                        
                        if(success){
                            completionHandler(true)
                        }
                        else
                        {
                            completionHandler(false)
                        }
                    })
                } catch
                {
                    print(error)
                    completionHandler(false)
                }
                
            }
        }
        else
        {
            completionHandler(false)
        }
    }
    
    //Function for Chcek extension
    class func fileExtension(filename: String) -> String {
        if let fileExtension = NSURL(fileURLWithPath: filename).pathExtension {
            return fileExtension
        } else {
            return ""
        }
    }
    
    //Method for request url and upload video (facescan and monitoring)
    class func requestForUploadUrl(fileSize:String, videoFileName:String, videoFile:NSData, filePath:NSString, completionHandler : @escaping (Bool) -> Void) {
        var parameters = [String : AnyObject]()
        
        if ((videoFileName) == (faceScanVideoName + "." + videoExtension))
        {
            parameters[formatParameter] = videoExtension as AnyObject
            parameters[typeParameter] = faceScanVideoName as AnyObject
            
            if(faceScanRequired == true)
            {
                parameters[chunkNumberParameter] = "1" as AnyObject
            }
        }
        else  if ((videoFileName) == (idScanImageName + "." + imageExtension))
        {
            parameters[formatParameter] = imageExtension as AnyObject
            parameters[typeParameter] = idScanImageName as AnyObject
            if(photoIdRequired == true && faceScanRequired == true)
            {
                parameters[chunkNumberParameter] = "2" as AnyObject
            }
            else if(photoIdRequired == true && faceScanRequired == false)
            {
                parameters[chunkNumberParameter] = "1" as AnyObject
            }
        }
        else  if ((videoFileName) == (roomScanVideoName + "." + videoExtension))
        {
            parameters[formatParameter] = videoExtension as AnyObject
            parameters[typeParameter] = roomScanVideoName as AnyObject
            if(roomScanRequired == true && photoIdRequired == true && faceScanRequired == true)
            {
                parameters[chunkNumberParameter] = "3" as AnyObject
            }
            else if(roomScanRequired == true && photoIdRequired == false && faceScanRequired == true)
            {
                parameters[chunkNumberParameter] = "2" as AnyObject
            }
            else if(roomScanRequired == true && photoIdRequired == false && faceScanRequired == false)
            {
                parameters[chunkNumberParameter] = "1" as AnyObject
            }
        }
        else if (videoFileName.contains(notesImageName)) {
            parameters[formatParameter] = imageExtension as AnyObject
            parameters[typeParameter] = notesImageName as AnyObject
            parameters[chunkNumberParameter] = chunkNumber as AnyObject
        }
        else
        {
            parameters[formatParameter] = videoExtension as AnyObject
            parameters[typeParameter] = monitoring as AnyObject
            parameters[chunkNumberParameter] = chunkNumber as AnyObject
        }
        
        parameters[videoLengthParameter] = fileSize as AnyObject //File length in Bytes
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatterGet.amSymbol = ""
        dateFormatterGet.pmSymbol = ""
        dateFormatterGet.locale = .current
        let finalDate = dateFormatterGet.string(from: Date()).trimmingCharacters(in: .whitespaces) + "Z"
        parameters[timeCaptureParameter] = finalDate as AnyObject
        
        parameters[isDeviceParameter] = true as AnyObject
        parameters[testsession_id] = UserDefaults.standard.string(forKey: testsession_id) as AnyObject
        let url: String
        if (freshHire ==  true)
        {
            url = callUrlRequestForUploadForFreshHire
        }
        else
        {
            url = callUrlRequestForUploadForProctorScreen
        }
        
        NetworkingClass.requestChunksUploadUrlAndSendChunksToUrl(uploadUrl: url, parameters: parameters, videoData: videoFile, fileName: videoFileName as String, filePath: NSURL(fileURLWithPath: filePath as String) as URL) { (success) in
            if success
            {
                completionHandler(true)
            }
            else
            {
                completionHandler(false)
            }
        }
    }
}
