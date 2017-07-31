//
// AppDelegate.swift
// SAPGeo
//
// Created by SAP Cloud Platform SDK for iOS Assistant application on 14/06/17
//

import SAPFiori
import SAPFoundation
import SAPCommon
import UserNotifications
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    private let logger = Logger.shared(named: "AppDelegateLogger")
    var sapGeoService: SAPGeoServiceDataAccess!
    var urlSession: SAPURLSession! {
        didSet {
            self.sapGeoService = SAPGeoServiceDataAccess(urlSession: urlSession)
            self.uploadLogs()
        }
    }

    let locationManager = CLLocationManager()
    
    func applicationDidFinishLaunching(_ application: UIApplication) {

        // set the default log level. Note: LogLevel.all may be too much for your use case! Maybe prefer LogLevel.error.
        Logger.root.logLevel = LogLevel.debug

        do {
            // Attaches a LogUploadFileHandler instance to the root of the logging system.d
            try SAPcpmsLogUploader.attachToRootLogger()
        } catch {
            self.logger.error("Failed to attach to root logger.", error: error)
        }

        UINavigationBar.applyFioriStyle()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count - 1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        splitViewController.modalPresentationStyle = .currentContext
        splitViewController.preferredDisplayMode = .allVisible

        // Show the actual authentication' view controller
        self.window!.makeKeyAndVisible()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let logonViewController = storyboard.instantiateViewController(withIdentifier: "SamlAuth") as! SAMLAuthViewController
        splitViewController.present(logonViewController, animated: false)
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsMasterController = secondaryAsNavController.topViewController as? MasterViewController else { return false }
        // Without this, on iPhone the main screen is the detailview and the masterview can not be reached.
        if (topAsMasterController.collectionType == .none) {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }

        return false
    }

    // MARK: - Remote Notification handling
    private var deviceToken: Data?
    private var remoteNotificationClient: SAPcpmsRemoteNotificationClient!

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]? = nil) -> Bool {
        UIApplication.shared.registerForRemoteNotifications()
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            // Enable or disable features based on authorization.
        }
        center.delegate = self
        return true
    }

    // Called to let your app know which action was selected by the user for a given notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping() -> Void) {
        self.logger.info("App opened via user selecting notification: \(response.notification.request.content.body)")
        // Here is where you want to take action to handle the notification, maybe navigate the user to a given screen.
        completionHandler()
    }

    // Called when a notification is delivered to a foreground app.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping(UNNotificationPresentationOptions) -> Void) {
        self.logger.info("Remote Notification arrived while app was in forground: \(notification.request.content.body)")
        // Currently we are presenting the notification alert as the application were in the backround.
        // If you have handled the notification and do not want to display an alert, call the completionHandle with empty options: completionHandler([])
        completionHandler([.alert, .sound])
    }

    func registerForRemoteNotification() -> Void {
        guard let deviceToken = self.deviceToken else {
            // Device token has not been acquired
            return
        }

        self.remoteNotificationClient = SAPcpmsRemoteNotificationClient(sapURLSession: self.urlSession, settingsParameters: Constants.configurationParameters)
        self.remoteNotificationClient.registerDeviceToken(deviceToken) { error in
            if let error = error {
                self.logger.error("Register DeviceToken failed", error: error)
                return
            }
            self.logger.info("Register DeviceToken succeeded")
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.deviceToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        self.logger.error("Failed to register for Remote Notification", error: error)
    }

    // MARK: - Log uploading

    // This function is invoked on every application start, but you can reuse it to manually triger the logupload.
    private func uploadLogs() {
        SAPcpmsLogUploader.uploadLogs(sapURLSession: self.urlSession, settingsParameters: Constants.configurationParameters) { error in
            if let error = error {
                self.logger.error("Error happened during log upload.", error: error)
                return
            }
            self.logger.info("Logs have been uploaded successfully.")
        }
    }
    
    /**
     Processes the geofence event received from one of the `CLLocationManagerDelegate` delegate methods `locationManager(_:didEnterRegion:)` or `locationManager(_:didExitRegion:)`
     If the app is running in the foreground, it will show an alert.
     If the app is running in the background, it will show a local notification
     - Parameters:
       - region: The `CLRegion` instance which has been detected
       - didEnter: `true` if the geofence has been entered, `false` if the geofence has been exited
     */
    func handleEvent(forRegion region: CLRegion!, didEnter: Bool) {
        
        let geoLocation = self.getGeoLocation(fromRegionIdentifier: region.identifier)
        
        if geoLocation != nil {
            let message = geoLocation?.title ?? "Unknown title"
            
            logger.debug("\(didEnter ? "Entered" : "Exited") geofence: \(message)")
            
            if UIApplication.shared.applicationState == .active {
                let view = window?.rootViewController
                let alert = UIAlertController(title: "Geofence crossed", message: message, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(action)
                view?.present(alert, animated: true, completion: nil)
            } else {
                let content = UNMutableNotificationContent()
                content.title = "Geofence crossed"
                content.body = message
                content.sound = UNNotificationSound.default()
                
                let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(identifier: "notification1", content: content, trigger: notificationTrigger)
                
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
        }
    }
    
    /**
     Retrieves an instance of `SAPGeoLocation` from the array stored in `UserDefaults` based on the `identifier` provided
     - Parameters:
       - identifier: The id of the geofence
       - Returns: Instance of `SAPGeoLocation` or `nil` if the geofence could not be found
     */
    func getGeoLocation(fromRegionIdentifier identifier: String) -> SAPGeoLocation? {
        let storedLocations = UserDefaults.standard.array(forKey: Constants.geofencesKey) as? [NSData]
        let sapGeoLocations = storedLocations?.map { NSKeyedUnarchiver.unarchiveObject(with: $0 as Data) as? SAPGeoLocation }
        let index = sapGeoLocations?.index { $0?.identifier == identifier }
        return index != nil ? sapGeoLocations?[index!] : nil
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region, didEnter: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region, didEnter: false)
        }
    }
}

