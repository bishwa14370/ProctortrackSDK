//
//  Constants.swift
//   ProctorTrack
//

import UIKit

var offline:Bool = false // true means offline mode is active
let freshHire:Bool = true
var bypassScanUploadFlow: Bool = true
//Check the application type
var screenRecordingStopEnable: Bool = true //Stop screen recording when true
var bluetoothAccessScreen : Bool = false  //False means buletooth is not allowed.
var kibanaLogEnable: Bool = true //False for not logging
var analyticEnable : Bool = false //False for not logging flurry analytics
var checkUpdateAvailable : Bool = true //False for not checking update
var changeVideoCodecFormat : Bool = true
var byPassFacescanResultPage : Bool = true //By pass facescan Result screen for real time face recognition
//Set the Full configuration for the config api
var fullTestConfig : Bool = true
var realTimeFaceVerification: Bool = true //True mean face verificataion is active
var isOnBoarding: Bool = false // true mean test is on boarding exam
//Global Variable for configuration Api dependent call
var testMaxDuration: Int = 0
var buttonRoundCornerValue: CGFloat = 8
var borderColorValue: CGFloat = 6
var monitoringCameraBorder : CGFloat = 2
var cameraRoundCornerValue: CGFloat = 3
var numberOfFaceSnapShot: Int = 3
var numberOfOnBoardingImagePick: Int = 3
var isFaceRecordingStart: Bool = false
var isFaceScanTimeEnd: Bool = false

var chunkCount: Int = 0

//constant view for the scans which we are going to use
var faceScanRequired : Bool = false
var photoIdRequired: Bool = true
var roomScanRequired:Bool =  false
var liveRoomScanRequired:Bool =  false
var liveRoomScanRequiredWithOldUI:Bool =  false
var liveMonitoringScanRequired:Bool =  true
var monitoringWithLocalChunkRequired:Bool =  false

var streamUrls : Dictionary<String,Any> = [:]
//var knuckleScanRequired:Bool =  false

var copyPasteEnable: Bool =  false
var calculatorEnable: Bool =  true
var contactSupportEnable: Bool =  false
var longPressButtonRequired: Bool = false
var callBackUrl : String = ""
var testResultUrl: String = ""
let minimumRam: UInt64 = UInt64(5.12e+8)//512MB
let maxRam: UInt64 = UInt64(3.221e+9) //3GB
    //UInt64(9.664e+9)// 9GB
let minimumMemoryForLiveScanRequired: UInt64 = UInt64(5.12e+8)//500MB
let minimumInternetSpeed : CGFloat = CGFloat(0.64) //128Kbps(converted in to MBPS)
let kibanaLevelName : String = "iOS_Debug"
let kibanaErrorLevelName : String = "iOS_Debug_Error"
let wiFiNetwork : String = "WiFi"
let cellularNetwork : String = "Cellular"
let liveProctoringLabel : String =  "  Live"
//Setting the time For local Notification

// Stream ID extension
var streamIdExtension: Int = 0
var streamIdExtensionForRoomScan: Int = 0
var is_stream_auto_renaming_enabled : Bool = false
let streamAutoRenamingKey = "streamAutoRenamingKey"
var is_bluetooth_check_required : Bool = true
let noteRequired = "noteRequiredKey"
let notesImageName: String = "notes"
var is_diy_proctoring : Bool = false
let firebaseConfigKey = "firebaseConfigKey"
var app_type = ""
let faceScanReviewMessage = "Your Face Scan Is Under Review"
let faceScanDetailMessage = "Please don’t close the app. This could take up to 5 minutes. Thank you for your patience. \n\n Once your face scan is approved, you will automatically be taken to the next step."
let faceScanFailedMessage = "Your Face Scan Verification Is Failed"
let faceScanFailedDescription = "Your face verification is failed. \n Please follow the instructions and try again."
let scanSuccessMessage = "Verification Successful"
let idScanReviewMessage = "Your ID Scan Is Under Review"
let idScanDetailMessage = "Please don’t close the app. This could take up to 5 minutes. Thank you for your patience. \n\n Once your id scan is approved, you will automatically be taken to the next step."
let idScanFailedMessage = "Your ID Scan Verification Is Failed"
let idScanFailedDescription = "Your ID verification is failed. \n Please follow the instructions and try again."

// var requires_face_scan_verification: Bool = false
var requires_id_scan_verification: Bool = false

//ProctorScreen parameters
let institutionKey = "institute"
//let processPool = WKProcessPool()
var chatUrl = ""
let kioskModeKey = "kioskModeEnabled"
let screenRecordingKey = "screenRecordingEnabled"
var screenRecordingUrl = ""
var screenRecordingStreamID = ""
let screenRecordingUrlKey = "screenRecordingUrlKey"
let screenRecordingStreamIDKey = "screenRecordingStreamIDkey"
let screenRecordingTokenID = "screenRecordingTokenID"

let minute:TimeInterval = 60.0
let hour:TimeInterval = 60.0 * minute
let repeatTimeInterval:TimeInterval = 6 * hour
let scheduleTimeForBackgroundNotify = 15

//Time in seconds 
let chunkDeleteTimeInSeconds: String = "86400"

var qrCodeExpiryTime: Int = 15
var selfTerminationSecFortestCompletedScreen = 5.0

var liveRoomScaningStreamID: String = "liveRoomScaningStreamID"
var liveMonitoringStreamID: String = "liveMonitoringStreamID"
var liveStreamingTokenID : String = ""
var roomScanTokenID: String = ""

//Diwakar accounts
//let s3BucketName: String = "diwakargarg" // Update this to your bucket name
//Verificient Account
let s3BucketName: String = "bandwidth-checker"
//Diwakar S3 Pool ID
//let s3PoolID : String = "us-east-1:5a1dff25-d581-45b5-a951-8e4622c7f985"
//Verificient Account
let s3PoolID : String = "us-east-1:ef9eabd6-0ff8-4490-8158-4faf1138d0d1"

//WARNING: To run this sample correctly, you must set the following constants.
let s3DownloadKeyName: String = "chunk.mp4"
let s3UploadKeyName: String = "chunk.mp4"
let fileNameForMonitoring: String = "iOS_monitoringVideo"
let videoExtension: String = "mp4"
let imageExtension: String = "jpg"
let faceScanVideoName: String = "facescan"
let roomScanVideoName: String = "roomscan"
let idScanImageName: String = "idscan"
let monitoring: String = "monitoring"
let dateFormatterStringForUpload: String = "yyyy-MM-dd'T'HH:mm:ss'Z'"

let supportURL: String =  "https://www.verificient.com/support-freshhire/"
//Tushar sir port url for Proctorscreen url
let baseUrlForProctorScreen: String = "http://prestaging.verificient.com:8204"
//temp Url for testing viveak
//let baseUrlForFreshHire: String = "http://prestaging.verificient.com:8342"
////temp Url for testing Pradeep
//let baseUrlForFreshHire: String = "http://prestaging.verificient.com:8376"
////temp Url for testing Aamir sohel
//let baseUrlForFreshHire: String = "http://prestaging.verificient.com:8351"

////temp Url for testing Tanmay
//let baseUrlForFreshHire: String = "http://192.168.1.112:8000"

////testing Url
//let baseUrlForFreshHire: String = "https://prestaging.verificient.com"

////Pre Production URL
//let baseUrlForFreshHire: String = "https://freshhire.co"
//ProductionURL
var baseUrlForFreshHire: String = "https://preproduction.verificient.com"

//ProductionURL
//var liveStreamBaseUrl: String = "wss://livemedia.verificient.com"
var liveStreamBaseUrl: String = ""

let configurationUrl: String = "/screencasts/session/self/config"
let chunkUploadUrl: String = "/screencasts/session/self/chunkupload/"
let idScanUrl: String = "/api/v1/users/self/identity/photo_id"
let startSessionUrl: String = "/screencasts/session/self/startsession/"
let submitAnswerUrl: String = ""
let closeSessionUrl: String = "/screencasts/session/self/closesession/"
let uploadDoneChunkUrl:String = "/screencasts/session/self/chunkupload/done"
let qRScanDoneURL: String = "/screencasts/session/self/set/preverification/done/"

let desktopProctorStatusUrl: String = "/api/v2/screencasts/test-session-meta/"

let onboardingImagefetchUrl:String = "/api/v1/testsession/"
//Offline Api url
let forgotPaswordUrl: String = "/api/v1/forgotPassword/"
let loginUrl: String = "/api/v1/forgotPassword/"

//FreshChat Api Keys for the configuration
let freshChatAppId: String = "727f8765-bb21-43ba-b66c-dda037b4296a"
let freshChatAppKey: String = "M5Yf3hVi85hV4FmKxSjM"

//Url for Proctor Screen
let idScanUrlRequestForUploadForProctorScreen: String = "\(baseUrlForProctorScreen)\(idScanUrl)"
let callUrlRequestForUploadForProctorScreen: String = "\(baseUrlForProctorScreen)\(chunkUploadUrl)"
let startSessionUrlRequestForProctorScreen: String = "\(baseUrlForProctorScreen)\(startSessionUrl)"
let uploadDoneChunkUrlRequestForProctorScreen: String = "\(baseUrlForProctorScreen)\(uploadDoneChunkUrl)"
let closeSessionUrlRequestForProctorScreen: String = "\(baseUrlForProctorScreen)\(closeSessionUrl)"
let qRScanDoneURLRequestForProctorScreen: String = "\(baseUrlForFreshHire)\(qRScanDoneURL)"
//onboardingImagefetchUrl
let onboardingImagefetchUrlRequestForProctorScreen: String = "\(baseUrlForProctorScreen)\(onboardingImagefetchUrl)"
//Url for fresh hire
let idScanUrlRequestForUploadForFreshHire: String = "\(baseUrlForFreshHire)\(idScanUrl)"
let callUrlRequestForUploadForFreshHire: String = "\(baseUrlForFreshHire)\(chunkUploadUrl)"
let startSessionUrlRequestForFreshHire: String = "\(baseUrlForFreshHire)\(startSessionUrl)"
let uploadDoneChunkUrlRequestForFreshHire: String = "\(baseUrlForFreshHire)\(uploadDoneChunkUrl)"
let closeSessionUrlRequestForFreshHire: String = "\(baseUrlForFreshHire)\(closeSessionUrl)"
let qRScanDoneURLRequestForFreshHire: String = "\(baseUrlForFreshHire)\(qRScanDoneURL)"
//onboardingImagefetchUrl
let onboardingImagefetchUrlRequestForFreshHire: String = "\(baseUrlForFreshHire)\(onboardingImagefetchUrl)"

//Url for the terms and condition and privacy policy
let termsAndConditionURL: String = "https://www.proctortrack.com/terms-of-service/"
let privacyPolicyURL: String = "https://www.verificient.com/privacy-policy/"

//Parameters for the url request,response and header constants
let patchKeyForRoomScanProcessing:String = "live_room_scan_acceptance_status"
let authorization: String = "Authorization"
let getRequest: String = "GET"
let putRequest: String = "PUT"
let postRequest: String = "POST"
let failureResponse: String = "failure"
let failedResponse: String = "failed"
let statusResponse: String = "status"
let messageResponse: String = "message"
let successResponse: String = "success"
let formatParameter: String = "fmt"
let typeParameter: String = "type"
let chunkNumberParameter: String = "chunk_num"
let videoLengthParameter: String = "length"
let timeCaptureParameter: String = "time_captured"
let isDeviceParameter:String = "is_device"
let urlKeyResponse: String = "url"
let statusParameter: String = "status"
let manualCheckRequiredParameter: String = "ManualCheckRequired"
let isApprovedParameter: String = "is_approved"
let access_token: String = "access_token"
let testsession_id:String = "testsession_id"
let testsession_uuid:String = "testsession_uuid"
let qrCreatedAt: String = "qr_created_at"
let is_faceKey: String = "is_face"
let is_idKey: String = "is_id"
let is_roomKey: String = "is_room"
let requires_live_monitoringKey: String = "requires_live_monitoring"
let is_crashKey: String = "is_crash"
let uploadBaseUrl: String = "uploadBaseUrl"
let uploadCompleted: String = "uploadCompleted"
let uploadCancelDateTime : String = "uploadCancelDateTime"
let sessionApiState : String = "sessionApiState"
let test_max_duration:String = "test_max_duration"
let is_face_verification_activated :String = "is_face_verification_activated"
let view_app_config: String = "view_app_config"
let stream_urls: String = "stream_urls"
let is_onboarding: String = "is_onboarding"
let is_face_scan_required:String = "is_face_scan_required"
let is_knuckle_scan_required:String = "is_knuckle_scan_required"
let is_room_scan_required:String = "is_room_scan_required"
let is_photo_id_required:String = "is_photo_id_required"
let is_copy_paste_disabled:String = "is_copy_paste_disabled"
let is_onscreen_calculator_allowed:String = "is_onscreen_calculator_allowed"
let is_ContactSupport_Enable:String = "is_ContactSupport_Enable"
let is_Live_RoomScan_Enable:String = "requires_live_scans"
let is_Live_Monitoring_Enable:String = "requires_live_monitoring"
let liveStreamUrls:String = "stream_urls"
let test_callback_url:String = "test_callback_url"
let verifyTheWebUrlToNavigateToApp: String = "pass_attr_to_native_app"
let uploadSpeedValue : String = "uploadSpeedValue"
let downloadSpeedValue : String = "downloadSpeedValue"
let mobileMonitoringType:String = "mobile_monitoring_level"
let desktopSessionStatus:String = "desktopTestSessionStatus"
let monitoringStramId:String = "monitoringStramId"
let roomScanStramId:String = "roomScanStramId"
let appBaseUrl: String = "appBaseUrl"
let roomScanToken:String = "roomScanToken"
let liveStreamingToken = "liveStreamingToken"
let continueAlertTitle: String = "Continue"
//Segue Constant List
let identificationVerificationSegue: String = "identificationVerificationSegue"
let bypassNaviagtionSegue: String = "bypassNaviagtionSegue"
let faceScanSegue: String =  "faceScanSegue"
let systemCheckSegue: String =  "systemCheckSegue"
let faceScanResultSegue: String = "faceScanResultSegue"
let idScanScreenSegue: String = "idScanScreenSegue"
let iDScanResultSegue: String =  "iDScanResultSegue"
let roomScanSegue: String =  "roomScanSegue"
let roomScanResultSegue: String = "roomScanResultSegue"
let verificationCompletedSegue: String = "verificationCompletedSegue"
let screenLockerSegue: String = "screenLockerSegue"
let liveScreenLockerSegue: String = "liveScreenLockerSegue"
let testCompletedSegue: String = "testCompletedSegue"
let testUploadedCompletedSegue: String = "testUploadedCompletedSegue"
let qrCodeTermsAndCondition: String = "qrCodeTermsAndCondition"
let byPassVerificationScreenSegue: String = "byPassVerificationScreenSegue"
let uploadSegue : String =  "uploadSegue"
let liveLockScreenSegue : String = "liveLockScreenSegue"
let liveRoomScanProcessingScreenSegue : String = "liveRoomScanProcessingScreenSegue"
let liveStreamingTestCompletedSegue : String = "liveStreamingTestCompletedSegue"
let chunkUploadFromMonitoringSegue: String = "chunkUploadFromMonitoringSegue"


//StoryBoard View Controller constants
let faceScanViewController: String = "faceScanVC"
let roomScanViewController: String = "roomScanVC"
let idScanViewController:  String = "idScanVC"
let faceScanOverlay: String = "faceScanOverlayVC"
let idScanOverlay: String = "idScanOverlayVC"
let roomScanOverlay: String = "roomScanOverlayVC"
let roomScanNewOverlay: String = "roomScanNewOverlayVC"
let backGroundPopUpVC: String = "backGroundPopUpVC"
let verificationCompletedScreen: String = "verificationCompletedScreen"
let screenLockerScreen: String = "screenLockerScreen"
let testCompletedScreen: String = "testCompletedScreen"
let uploadScreenVC: String = "uploadScreenVC"
let qrCodeReaderVC : String = "QRCodeReaderVC"
let termsAndConditionVC: String = "termsAndConditionVC"
let liveScreenLockerVC: String = "liveScreenLockerVC"
let roomScanProcessionVC: String = "roomScanProcessionVC"

//NavigationBar constants 
let backNavigationBarButton: String = "< Back"
//Alert Title
let okAlertTitle: String = "Ok"
let alertTitle: String = "Alert"
let qRCodeErrorTitle: String = "Wrong QR Code"
let qRCodeExpiredTitle: String = "QR Code Expired"
let cancelAlertTitle: String = "Cancel"
let closeAlertTitle: String = "Close App"
let abortAlertTitle: String = "Abort"
let contactSupportTitle: String = "Contact Support"
let settingAlertTitle: String = "Settings"
let systemCheckAlertTitle: String = "System Check"
let roomScanProcessingAlertTitle: String = "Room Scan Review"
let termsAndComnditionAlertTitle: String = "Agreement to policy"
//Chnage the title
let proctorTrackTitle: String = "Proctortrack"
let identityVerificationTitle : String = "Identity verification"
let faceScanTitle: String = "Video Selfie"
let roomScanTitle: String = "Room Scan"
let faceScanOverlayTitle: String = "Video Selfie Instructions"
let roomScanOverlayTitle: String = "Room Scan Instructions"
let monitoringTitle: String = "Monitoring"
let idScanTitle: String = "ID Scan"
let idScanOverlayTitle: String = "ID Scan Instructions"
let uploadingTitle : String = "Uploading"
let beginTestAlertTitle: String = "Begin Test"
let reTryTitle: String = "Retry"
let reScanTitle: String = "Re-Scan"
let batteryAlertTitle : String = "Battery Alert"
let batteryLowAlertTitle :  String = "Battery is low"
let memoryAlertTitle : String = "Memory Status"
let roomScanFailureTitle : String = "Failure"
let roomScanSnapshotDirectoryName: String =  "roomSnapShot"
//let downloadedOnboardingImage: String =  "onboardingImageDownload"
let startButtonClickNotificationMonitoring: String = "startButtonClickNotificationMonitoring"

//QR Code Expired
//QR code has expired. Please scan the latest QR code.
//QR Code Scan Error
//Error occured while scanning qr code. Please scan again.



//Constants for Flurry analytics starts
let connectivityType : String = "Connectivity_type"
let configurationApiError: String = "configurationApiError"
let forgotPasswordApiError: String = "forgotPasswordApiError"
let loginApiError: String = "loginApiError"
let configurationApiSuccess : String = "configurationApiSuccess"
let s3UploadUrl: String = "s3UploadUrl"
let chunkUploaded : String = "chunk_uploaded"
let chunkUploadFailed : String = "chunk_upload_failed"
let uploadDone : String = "upload_done"
let uploadDoneFailed : String = "upload_done_failed"
let quit : String = "quit"
let appOpen : String = "app_open"
let faceScanSubmit : String = "face_scan_submit"
let roomScanSubmit : String = "room_scan_submit"
let idScanSubmit : String = "id_scan_submit"
let verificationCompleted : String = "verificationCompleted"
let endProctoringButtonClicked : String = "endProctoringButtonClicked"
let quitButtonClicked : String = "Quit Button Clicked in Test Completed Screen"
let vbqScanSubmit : String = "vbq_scan_submit"
let chunksExpired : String = "chunks_expired"
//let errorReplayFaceScan : String = "error_replay_face_scan"
//let errorReplayRoomScan : String = "error_replay_room_scan"
let testSessionStarted : String = "test_session_started"
let testSessionClosed : String = "test_session_closed"
let testSessionStartFail : String = "test_session_start_fail"
let testSessionCloseFail : String = "test_session_close_fail"
let scanCompletedStart : String = "scan_completed_start"
let scanCompletedFail : String = "scan_completed_fail"
//Screen Loadevent in to the flurry
let landingScreenSession : String = "landing_screen_session"
let systemCheckScreenSession : String = "system_check_screen_session"
let identityVerificationScreenSession : String = "identityVerificationScreenSession"
let faceScanOverlayScreenSession : String = "faceScanOverlayScreenSession"
let roomScanOverlayScreenSession : String = "roomScanOverlayScreenSession"
let faceScanScreenSession : String = "face_scan_screen_session"
let faceScanResultScreenSession : String = "faceScanResultScreenSession"
let roomScanResultScreenSession : String = "roomScanResultScreenSession"
let verificationCompletedSession : String = "verificationCompletedSession"
let ScreenLockerSession : String = "ScreenLockerSession"

let idScanOverlayScreenSession : String = "idScanOverlayScreenSession"
let idScanScreenSession : String = "id_scan_screen_session"
let idScanResultScreenSession : String = "idScanResultScreenSession"
//let knuckleScanScreenSession : String = "knuckle_scan_screen_session"
//let knuckleScanResultScreenSession : String = "knuckleScanResultScreenSession"
let roomScanScreenSession : String = "room_scan_screen_session"
let liveRoomScanScreenSession : String = "live_room_scan_screen_session"

let testDeliveryScreenSession : String = "test_delivery_screen_session"
let uploadScreenSession : String = "upload_screen_session"
let violation : String = "violation"
let violationType : String = "violation_type"
let backgroundTestDelivery : String = "pause_test due to app in background"
let foregroundTestDelivery :String = "resume_test app is in foreground"
let screenshotTakenInTestDeliveryScreen : String = "screenshot_taken_in_testdelivery_screen"
let screenshotTakenInOtherScreen : String = "screenshot_taken_in_other_screen"
let leftSessionTimeOut :String = "left_session_timeout"
let seprator : String = "|"
let kibanaPrefix : String = "source:iOS" + seprator


//Constants for Flurry analytics ends
let proctorTrackCameraAlertTitle: String =  "\"Proctortrack\" Would Like To Access the Camera."

//Constants for Flurry analytics ends
let freshHireBluetoothAlertTitle: String = "Bluetooth must be disabled while taking a test on Proctortrack."
let proctorScreenBluetoothAlertTitle: String =  "\"ProctorScreen\" Bluetooth must be disabled while taking a test on ProctorTrack."

let proctorScreenCameraAlertTitle: String =  "\"ProctorScreen\" Would Like To Access the Camera."
let freshHireMicrophoneAlertTitle: String = "\"Proctortrack\" Would Like To Access the MicroPhone."
let proctorScreenMicrophoneAlertTitle: String = "\"ProctorScreen\" Would Like To Access the MicroPhone."
let bluetoothAlertTitle: String = "\"ProctorScreen\" Would Like To Access the Bluetooth."

let requestFailed: String = "Request Failed"
let configurationApiFailed : String = "Problem in receiving test configurations. Please try again."
let qrCodeErrorMessage: String = "Please scan the QR code that is displayed on Desktop app."
let qrCodeExpiredErrorMessage: String = "QR code has expired. Please scan the latest QR code."
let apiRequestFailed: String = "Please contact to the support team to resolve this problem or retry."
let systemCheckAlertMessage : String = "Click start to initialize the System Check and wait while we are getting your system ready."
//let beginTestAlertMessage : String = "Your test is being monitored. Keep your face visible in the camera during the whole test."
let checkCameraAccessMessage: String = "Device has no camera."
let blueToothAlertMessage: String = "Please disable Bluetooth from your device settings to continue."
let cameraAlertMessage: String = "Please grant permission to use the Camera so that you can proceed further."
//let microphonePermissionStatusMessage: String = "Already permission is given."
let microPhoneAccessrequestMessage: String = "Please grant permission to use the microphone so that you can proceed further."
let bluetoothAccessRequestMessage : String = "Please grant permission to use the bluetooth so that you can proceed further."
//let facescanOverlayText: String = "Take a 10 seconds video of your full face,including right and left slide."
let internetAccessAlertMessage: String = "Please connect to the internet."
let closeApplicationDeviceMessage :String = "Your device does not meet minimum hardware requirements, i.e. 512MB RAM."
let closeApplicationNetworkConnectionSpeedMessage : String = "Please check the internet speed and try again."
let closeApplicationDeviceStorageMessage : String = "Please free up storage space in the device and try again."
let closeApplicationBatteryLowMessage : String = "Please connect to a power source and try again."
let notificationMessageForUploadStartMessage : String = "Session data is being uploaded, please wait."
let notificationTitleForUploadStartTitle : String = "Start Uploading"

let notificationMessageForUploadCompletedMessage : String = "Data uploaded successfully."
let notificationTitleForUploadCompletedTitle : String = "Uploading Completed"

let notificationMessageForQuitApplicationCallfromMonitoringScreen : String = "Upload test data with in 24 hours."
let notificationTitleForQuitApplicationCallfromMonitoringScreen : String = "Upload Chunks"

//let batteryAlertMessage: String = "Battery in low power mode"
let batteryLowAlertMessage: String = "Please connect the charger to continue the test."
let memoryAlertMessage : String = "Memory is low."
//let internetConnectionError: String = "Internet Connection Error."
//Constants for notification handling
let dontRemindMeButtonClickNotification: String = "dontRemindMeButtonClickNotification"
let gotButtonClickNotificationIDScan: String = "gotButtonClickNotificationIDScan"
let startButtonClickNotificationSystemCheck: String = "startButtonClickNotificationSystemCheck"
let chunkUploadInProgressInMonitoringScreen :String = "chunkUploadInProgressInMonitoringScreen"

//Message for the face scan Screen for the instruction
let instructionText : String = "Hold the BLUE button below to take a 10 seconds video."
let instructionTextForRTFV : String = "Position your face within the clear oval area. Scanning will automatically start when the BLUE outline appears. Follow the instruction displayed."
let instructionForFaceScanWithButton = "Click the button below to start the scan"
let instructionTextForRoomScan : String = "Hold the BLUE button below to take a minimum 15 seconds video."
let instructionTextFor360RoomScan: String = "Record a 360 degree, 20 seconds long video of your room including Left, Right & Behind you."
let instructionTextForDeskScan: String = "Record a 10 seconds long video including: your desk set up, monitor (front), monitor (back)"

let monitoringCameraMessageForMultiplePeople : String = "Multiple people found."
let monitoringCameraMessageForNoPeople : String = "Your face is not in camera view. Please adjust your device."
let faceVerificationFailed : String = "Your scan is not matching with your original onboarding scan."
let faceverificationFailedMessage : String = "Your face is not detected."
let faceVerificationFailedTitle: String = "Verification Failed"

let idScanInstructionText: String = "Make sure your ID is in focus and its text is readable."
let qrCodeScanInstructionText: String = "Scan the QR code shown on the desktop App."



let roomScanApprovalFailedMessage : String = "Your room scan has been failed, please take a new room scan and make sure to follow the instructions in the app. \n \nYour room scan should include: \n360 video of your room, \nYour desk, \nThe back of your computer."
let roomScanApprovedMessage : String = "Your Room Scan is approved."
let roomScanUnderReviewProcessMessage : String  = "Your Room Scan is under review, you will be able to proceed in a few seconds. If you need help contact support."
//Constant for the color used in the application
//Old blue code
//let textColorCode: UIColor = UIColor(red:0.25, green:0.59, blue:0.91, alpha:1.0) //hex color code 4097E9

let textColorCode: UIColor = UIColor(red:0.12, green:0.45, blue:0.87, alpha:1.0) //hex color code #1F74DE

let lightGreenColor: UIColor = UIColor(red:0.39, green:0.97, blue:1.00, alpha:1.0) //hex color code #64F7FF
let uploadTrackColor: UIColor = UIColor(red:0.17, green:0.23, blue:0.28, alpha:1.0)// hex color code id #2C3A48
let viewBackgroundColorCode: UIColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.2)

let gradientColor1 : UIColor = UIColor(red:0.18, green:0.21, blue:0.24, alpha:1.0) //hex color code 2E353C
let gradientColor2 : UIColor = UIColor(red:0.02, green:0.02, blue:0.02, alpha:1.0) //hex color code 040506

let placeHolderColorCode : UIColor = UIColor(red: 255/255, green: 253/255, blue: 247/255, alpha: 1.0)

let overlayColorCode : UIColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.7)
let overlayColorCodeForBorder : UIColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)

//Hexa of Color 1F74DE
let appThemeColorCode : UIColor = UIColor(red:0.12, green:0.45, blue:0.87, alpha:1.0)
//UDP Message or code
let UDP_CODE_VERIFICATION_SUCCESS: String = "49"
let UDP_CODE_VERIFICATION_FAILED: String = "48"
let UDP_CODE_QRCODE_SCAN_SUCCESS: String = "47"
let UDP_CODE_QRCODE_SCAN_VALIDATION_FAILED: String =  "46"
let UDP_CODE_QRCODE_SCAN_EXPIRED: String = "38"
let UDP_CODE_FACE_SCAN_SUCCESS: String = "45"
let UDP_CODE_ID_SCAN_SUCCESS: String = "44"
let UDP_CODE_ROOM_SCAN_SUCCESS: String = "43"
let UDP_CODE_UPLOAD_FACE_SCAN_SUCCESS: String = "42"
let UDP_CODE_UPLOAD_ID_SCAN_SUCCESS: String = "41"
let UDP_CODE_UPLOAD_ROOM_SCAN_SUCCESS: String = "40"
let UDP_CODE_QRCODE_SCAN_ERROR: String = "37"


//Not Used yet
let UDP_CODE_TEST_COMPLETED: String = "39"
let UDP_CODE_DESKTOP_APP_COMMUNICATION_ACK: String  = "36"
let UDP_CODE_DESKTOP_APP_COMMUNICATION: String  = "35"

////Handling the log printing while debug and release version.
//func print(items: Any..., separator: String = " ", terminator: String = "\n") {
//    #if DEBUG
//        Swift.print(items[0], separator:separator, terminator: terminator)
//    #endif
//}

//Method for calling the different Alerts
func alert(title: String, message: String)
{
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle:UIAlertController.Style.alert)
    
    alertController.addAction(UIAlertAction(title: okAlertTitle, style: UIAlertAction.Style.default,handler:nil))
    
    
    if var topController = UIApplication.shared.keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        topController.present(alertController, animated: true, completion: nil)
        // topController should now be your topmost view controller
    }
}

   /*----------------------------File Directory handling Custom Methods ---------------------*/
//get directory path 
//Function for Get Document Directory Path :
func getDirectoryPath() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

//create directory
func createDirectory(directoryName:String){
    let fileManager = FileManager.default
    let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(directoryName)
    if !fileManager.fileExists(atPath: paths){
        try! fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
    }else{
        print("Already dictionary created.")
    }
}

// delete directory

func deleteDirectory(directoryName:String){
    let fileManager = FileManager.default
    do {
        try fileManager.removeItem(atPath: directoryName)
    }
    catch let error as NSError {
        print("Ooops! Something went wrong: \(error)")
    }
}

//Method for getting all file in list of the data from document directory
func listFilesFromDocumentsFaceSnapShotFolder(directoryName:String)->[String]?{
    let paths =  FileManager.default.urls(for: .documentDirectory,in: .userDomainMask)[0]
    let docs = paths.appendingPathComponent(directoryName).path
    //list all contents of directory and return as [String] OR nil if failed
    return try? FileManager.default.contentsOfDirectory(atPath:docs);
}

//Method for getting all file in list of the data from document directory
func listFilesFromDocumentsFolder()->[String]?{
    //full path to documents directory
    let docs=FileManager.default.urls(for: .documentDirectory,in: .userDomainMask)[0].path;
    //list all contents of directory and return as [String] OR nil if failed
     var tempArray = [String]()
    tempArray = try! FileManager.default.contentsOfDirectory(atPath:docs)
    
    //Remove the folder name from the directory
    tempArray = tempArray.filter{$0 != "faceSnapShot"}
    tempArray = tempArray.filter{$0 != "onboardingImageDownload"}
    print("List of data in the directory",tempArray)
    return tempArray
}

////Delete file from the Directory
 func removeImageAndVideo(itemName:String, fileExtension: String) {
    let fileManager = FileManager.default
    let filePath = "\(itemName).\(fileExtension)"
    do {
        try fileManager.removeItem(atPath: filePath)
    } catch let error as NSError {
        print(error.debugDescription)
    }
}
////Delete file from the Directory
func removeFileFromDirectory(itemName:String) {
    let fileManager = FileManager.default
    let filePath = "\(itemName)"
    do {
        try fileManager.removeItem(atPath: filePath)
    } catch let error as NSError {
        print(error.debugDescription)
    }
}

//Function for clearing temp folder
func clearTempFolder() {
    let fileManager = FileManager.default
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    
    do {
        try fileManager.removeItem(atPath: paths[0])
        print("Clear data")
        
    } catch {
        print("Could not clear value folder: \(error)")
    }
}
//Device Size Finding

func deviceSize()-> String
{
    //Get the screenSize to get width and height of every device.
    let screenSize: CGRect = UIScreen.main.bounds
    let screenWidth = screenSize.width
    let screenHeight = screenSize.height
    
    //If iPhone is 6(s) or 8 set width and height as shown below
    if screenWidth == 375 && screenHeight == 667 {
        return "6And7"
        
        //If iPhone is 6(s)/8 Plus, set width and height as shown below
    } else if screenWidth == 414 && screenHeight == 736 {
        
        return "6And7Plus"
        //If iPhone is 5(s)/SE, set width and height as shown below
    } else if screenWidth == 320 && screenHeight == 568 {
        return "5sAndSE"
    }
    else if screenHeight < 500 {
        return "4s"
    }
        //If iPhone is X or Xs or 11 pro, set width and height as shown below
    else if screenWidth == 375 && screenHeight == 812 {
        return "X"
    }
        //If iPhone is Xr or Xs Max or 11 or 11 pro Max, set width and height as shown below
    else if screenWidth == 414 && screenHeight == 896 {
        return "Xr"
    }
    else if screenWidth > 500 {
        if screenWidth == 768 && screenHeight == 1024 {
            return "iPad 9.7"
        }
        else if screenWidth == 810 && screenHeight == 1020 {
            return "iPad 10.2"
        }
        else if screenWidth == 834 && screenHeight == 1112 {
            return "iPad 10.5"
        }
        else if screenWidth == 834 && screenHeight == 1194 {
            return "iPad 11"
        }
        else if screenWidth == 1024 && screenHeight == 1366 {
            return "iPad 12.9"
        }
        else {
            return "iPad 10.5"
        }
    }
    else
    {
        return "6And7"
    }
}

//resize the image
func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / image.size.width
    let heightRatio = targetSize.height / image.size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }
    
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}

extension UIImage {
func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
    let radiansToDegrees: (CGFloat) -> CGFloat = {
        return $0 * (180.0 / CGFloat.pi)
    }
    let degreesToRadians: (CGFloat) -> CGFloat = {
        return $0 / 180.0 * CGFloat.pi
    }
    
    // calculate the size of the rotated view's containing box for our drawing space
    let rotatedViewBox = UIView(frame: CGRect(origin: .zero, size: size))
    let t = CGAffineTransform(rotationAngle: degreesToRadians(degrees));
    rotatedViewBox.transform = t
    let rotatedSize = rotatedViewBox.frame.size
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize)
    let bitmap = UIGraphicsGetCurrentContext()
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    bitmap?.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
    
    //   // Rotate the image context
    bitmap?.rotate(by: degreesToRadians(degrees))
    
    // Now, draw the rotated/scaled image into the context
    var yFlip: CGFloat
    
    if(flip){
        yFlip = CGFloat(-1.0)
    } else {
        yFlip = CGFloat(1.0)
    }
    
    bitmap?.scaleBy(x: yFlip, y: -1.0)
    let rect = CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height)
    
    bitmap?.draw(cgImage!, in: rect)
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
 }
}

//function for date from the time stamp
func getDateFromTimeStamp(timeStamp : Double, dateFormatter: String) -> String {
    
    let date = NSDate(timeIntervalSince1970: timeStamp)
    
    let dayTimePeriodFormatter = DateFormatter()
    dayTimePeriodFormatter.dateFormat = dateFormatter
    // UnComment below to get only time
    //  dayTimePeriodFormatter.dateFormat = "hh:mm a"
    
    let dateString = dayTimePeriodFormatter.string(from: date as Date)
    return dateString
}
//Current date and time
func currentDateStringFormat(format: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.string(from: Date())
}
//convert time in to the String format
func timeString(time:TimeInterval) -> String {
    
    let hours = Int(time) / 3600
    let minutes = Int(time) / 60 % 60
    let seconds = Int(time) % 60
    
    return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
}

// function for the checking the date string compare with current date
func checkTimeStamp(date: String!) -> Bool {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.locale = Locale(identifier:"en_US_POSIX")
    let datecomponents = dateFormatter.date(from: date)
    
    let now = Date()
    
    if (datecomponents! >= now) {
        return true
    } else {
        return false
    }
}

func nullToNil(value : AnyObject?) -> AnyObject? {
    if value is NSNull {
        return nil
    } else {
        return value
    }
}
