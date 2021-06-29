//
//  Firestore.swift
//  ProctortrackSDK

import Foundation
import Firebase
import FirebaseAuth

class FirestoreDB {
    
    static let shared = FirestoreDB()
    private var docRefForLiveproctoring: DocumentReference? = nil
    private var docRefForRoomScan: DocumentReference? = nil
    private var docRefForElectronAppState: DocumentReference? = nil
    private var quoteListener: ListenerRegistration? = nil
    private var app: FirebaseApp?
    
    private init() {
        self.setupFirebaseConfig()
    }
    
    private func setupFirebaseConfig() {
        if let dict = UserDefaults.standard.value(forKey: firebaseConfigKey) as? [String:String] {
            guard let googleAppID = dict["firebaseApplicationId"] else {return}
            guard let gcmSenderID = dict["gcmSenderID"] else {return}
            guard let apiKey = dict["firebaseApiKey"] else {return}
            guard let projectID = dict["firebaseProjectId"] else {return}
            let firOption = FirebaseOptions(googleAppID: googleAppID, gcmSenderID: gcmSenderID)
            firOption.apiKey = apiKey
            firOption.projectID = projectID
            FirebaseApp.configure(name: "proctorTrack", options: firOption)
            self.app = FirebaseApp.app(name: "proctorTrack")
        }
    }
    
    func updateStreamIDForLiveProctoring(documentID: String, streamID: String, completionHandler : @escaping (String) -> Void) {
        guard let app = self.app else { return }
        self.docRefForLiveproctoring = Firestore.firestore(app: app).collection("sessions").document(documentID)
        self.docRefForLiveproctoring?.updateData(["monitoring_stream_names": FieldValue.arrayUnion([streamID])], completion: {[weak self] (error) in
            if let this = self {
                if let err = error {
                    completionHandler(err.localizedDescription)
                }
                else {
                    if let ref = this.docRefForLiveproctoring {
                        completionHandler("Document updated on ID: \(ref.documentID) with stream id \(streamID)")
                    }
                }
            }
        })
    }
    
    func getStreamIdForLiveProctoring(documentID: String, completionHandler : @escaping (Bool, [String]) -> Void) {
        guard let app = self.app else { return }
        self.docRefForLiveproctoring = Firestore.firestore(app: app).collection("sessions").document(documentID)
        self.docRefForLiveproctoring?.getDocument(completion: {[weak self] (docSnapshot, error) in
            if let this = self {
                if let err = error {
                    completionHandler(false, [err.localizedDescription])
                }
                else {
                    if let docSnapshot = docSnapshot, docSnapshot.exists {
                        if let allData = docSnapshot.data() {
                            if let streamIdArray = allData["monitoring_stream_names"] as? [String] {
                                print(this)
                                completionHandler(true, streamIdArray)
                            }
                            else {
                                completionHandler(false, ["monitoring_stream_names field is nil/not created"])
                            }
                        }
                        else {
                            completionHandler(false, ["docSnapshot data is nil"])
                        }
                    }
                    else {
                        completionHandler(false, ["No document found, docSnapshot exist false"])
                    }
                }
            }
        })
    }
    
    func updateStreamIDForRoomScan(documentID: String, streamID: String, completionHandler : @escaping (String) -> Void) {
        guard let app = self.app else { return }
        self.docRefForRoomScan = Firestore.firestore(app: app).collection("sessions").document(documentID).collection("session_extra").document(documentID)
        self.docRefForRoomScan?.updateData(["room_scan_stream_names": FieldValue.arrayUnion([streamID])], completion: {[weak self] (error) in
            if let this = self {
                if let err = error {
                    completionHandler(err.localizedDescription)
                }
                else {
                    if let ref = this.docRefForRoomScan {
                        completionHandler("Document updated on ID: \(ref.documentID) with stream id \(streamID)")
                    }
                }
            }
        })
    }
    
    func getStreamIdForRoomScan(documentID: String, completionHandler : @escaping (Bool, [String]) -> Void) {
        guard let app = self.app else { return }
        self.docRefForRoomScan = Firestore.firestore(app: app).collection("sessions").document(documentID).collection("session_extra").document(documentID)
        self.docRefForRoomScan?.getDocument(completion: {[weak self] (docSnapshot, error) in
            if let this = self {
                if let err = error {
                    completionHandler(false, [err.localizedDescription])
                }
                else {
                    if let docSnapshot = docSnapshot, docSnapshot.exists {
                        if let allData = docSnapshot.data() {
                            if let streamIdArray = allData["room_scan_stream_names"] as? [String] {
                                print(this)
                                completionHandler(true, streamIdArray)
                            }
                            else {
                                completionHandler(false, ["room_scan_stream_names field is nil/not created"])
                            }
                        }
                        else {
                            completionHandler(false, ["docSnapshot data is nil"])
                        }
                    }
                    else {
                        completionHandler(false, ["No document found, docSnapshot exist false"])
                    }
                }
            }
        })
    }
    
    func listenToRoomScanApprovalStatus(completionHandler : @escaping (Bool, [String : Any]?, String) -> Void) {
        guard let app = self.app else { return }
        guard let documentID = UserDefaults.standard.string(forKey: testsession_uuid) else {return}
        self.docRefForRoomScan = Firestore.firestore(app: app).collection("sessions").document(documentID).collection("session_extra").document(documentID)
        self.quoteListener = docRefForRoomScan?.addSnapshotListener({(docSnapshot, error) in
            if let err = error {
                completionHandler(false, nil, err.localizedDescription)
            }
            else if let docSnapshot = docSnapshot, docSnapshot.exists {
                if let data = docSnapshot.data() {
                    completionHandler(true, data, "listened to updated data successfully")
                }
            }
            else {
                completionHandler(false, nil, "listened to updated data failed")
            }
        })
    }
    
    func removeQuoteListener() {
        if let quoteListener = self.quoteListener {
            quoteListener.remove()
        }
    }
    
    func signUpWithFirebaseToken(auth_token: String, completionHandler : @escaping (Bool, String) -> Void) {
        guard let app = self.app else { return }
        Auth.auth(app: app).signIn(withCustomToken: auth_token) { (user, error) in
            if let err = error {
                completionHandler(false, err.localizedDescription)
            }
            else if let user = user {
                completionHandler(true, user.description)
            }
            else {
                completionHandler(false, "error sign up with firebase token")
            }
        }
    }
    
    func signOutFirebaseAuth() {
        guard let app = self.app else { return }
        let firebaseAuth = Auth.auth(app: app)
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func updateRoomScanStateForElectronApp(documentID: String, completionHandler : @escaping (Bool, String) -> Void) {
        guard let app = self.app else { return }
        self.docRefForElectronAppState = Firestore.firestore(app: app).collection("desktop_applications").document(documentID)
        self.docRefForElectronAppState?.updateData(["state": 5], completion: {[weak self] (error) in
            if let this = self {
                if let err = error {
                    completionHandler(false, err.localizedDescription)
                }
                else {
                    if let ref = this.docRefForElectronAppState {
                        completionHandler(true, "Room scan state updated on ID: \(ref.documentID)")
                    }
                }
            }
        })
    }
}
