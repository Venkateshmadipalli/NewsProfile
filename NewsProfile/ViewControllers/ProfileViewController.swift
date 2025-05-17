//
//  ProfileViewController.swift
//  NewsProfile
//
//  Created by Apple on 16/05/25.
//
import UIKit
import PhotosUI
import AVFoundation
import CoreLocation

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var currentLatitude: Double?
    var currentLongitude: Double?
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var emailLBL: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameLBL: UILabel!
    @IBOutlet weak var LocationLBL: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpImage()
    }
    override func viewWillAppear(_ animated: Bool) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        nameLBL.text = UserDefaults.standard.string(forKey: "UseName")
        emailLBL.text = UserDefaults.standard.string(forKey: "UseEmail")
        phoneNumber.text = UserDefaults.standard.string(forKey: "UsePhone") ?? ""
        profileImg.layer.cornerRadius = 50
        profileImg.clipsToBounds = true
        
        loadSavedProfileImage()
       
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapProfileIMG))
        profileImg.addGestureRecognizer(tap)
        profileImg.isUserInteractionEnabled = true
    }
    override func viewDidAppear(_ animated: Bool) {
        print(1111)
    }
    
    
    func setUpImage(){
        
        let photoURL = UserDefaults.standard.string(forKey: "UseProfileImg")
        if let imageData = UserDefaults.standard.data(forKey: "UserProfileImageData"),
           let image = UIImage(data: imageData) {
            profileImg.image = image
        }else{
            if let photoURLString = photoURL,
               let photoURL = URL(string: photoURLString) {
                URLSession.shared.dataTask(with: photoURL) { data, response, error in
                    if let error = error {
                        print("Failed to download image: \(error.localizedDescription)")
                        return
                    }
                    guard let data = data,
                          let image = UIImage(data: data) else {
                        print("Invalid image data")
                        return
                    }
                    DispatchQueue.main.async {
                        self.profileImg.image = image
                    }
                }.resume()
            }
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLatitude = location.coordinate.latitude
        currentLongitude = location.coordinate.longitude
        LocationLBL.text = "Latitude: \(currentLatitude!), Longitude: \(currentLongitude!)"
    }
    @objc func tapProfileIMG(tap: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Update Profile Picture", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.checkCameraPermissionAndPresent()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.checkPhotoLibraryPermissionAndPresent()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    func checkCameraPermissionAndPresent() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            openImagePicker(sourceType: .camera)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.openImagePicker(sourceType: .camera)
                    }
                }
            }
        case .denied, .restricted:
            self.showPermissionAlert(for: "Camera")
        @unknown default:
            break
        }
    }
    
    func checkPhotoLibraryPermissionAndPresent() {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized:
            openImagePicker(sourceType: .photoLibrary)
        case .limited:
            openImagePicker(sourceType: .photoLibrary)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    if status == .authorized || status == .limited {
                        self.openImagePicker(sourceType: .photoLibrary)
                    }
                }
            }
        case .denied, .restricted:
            self.showPermissionAlert(for: "Photo Library")
        @unknown default:
            break
        }
    }
    
    func showPermissionAlert(for type: String) {
        let alert = UIAlertController(
            title: "\(type) Permission Denied",
            message: "Please enable \(type) access in Settings to update your profile picture.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            print("Source type not available: \(sourceType)")
            return
        }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = true
        self.present(picker, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        
        if let edited = info[.editedImage] as? UIImage {
            selectedImage = edited
        } else if let original = info[.originalImage] as? UIImage {
            selectedImage = original
        }
        if let image = selectedImage {
            self.profileImg.image = image
            self.saveImageLocally(image)
        }
        picker.dismiss(animated: true)
    }
    
   
    func saveImageLocally(_ image: UIImage) {
        if let imageData = image.jpegData(compressionQuality: 0.9) {
            UserDefaults.standard.set(imageData, forKey: "UserProfileImageData")
        }
    }
    func loadSavedProfileImage() {
        if let imageData = UserDefaults.standard.data(forKey: "UserProfileImageData"),
           let image = UIImage(data: imageData) {
                   profileImg.image = image
               }
    }
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
