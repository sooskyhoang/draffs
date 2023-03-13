//
//  FeedbackViewController.swift
//  chatGPT2
//
//  Created by nguyen van hoang on 09/03/2023.
//

import UIKit
import Tactile
import YPImagePicker
import AVFoundation

class FeedbackViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var submitBtn: UIButton!
    
    // Contraint
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollContentViewHeight: NSLayoutConstraint!
    
    var selectedItems = [YPMediaItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureNavigationBar()
        configureEmailTextField()
        configureFeedbackTextView()
        configureCollectionView()
        configureSubmitBtn()
        hideKeyboardWhenTappedAround()
    }


    private func configureNavigationBar() {
        navigationItem.title = ""
        navigationItem.setHidesBackButton(true, animated: true)
        
        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "back-img"), for: .normal)
        backBtn.frame = CGRectMake(0, 0, 40, 24.23)
        backBtn.addTarget(self, action: #selector(self.popController), for: .touchUpInside)
        
        let welcomeText = UILabel()
        welcomeText.text = "Feedback"
        welcomeText.font = AppFont.sfProRoundedBold(ofSize: 24.0)
        
        self.navigationItem.setLeftBarButtonItems([
            UIBarButtonItem(customView: backBtn),
            UIBarButtonItem(customView: welcomeText)
        ], animated: true)
    }
    
    @objc private func popController() {
        navigationController?.popViewController(animated: true)
    }
    
    private func configureEmailTextField() {
        emailTextField.delegate = self
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter your email",
            attributes: [.foregroundColor: UIColor.lightGray]
        )
    }
    
    private func configureFeedbackTextView() {
        feedbackTextView.text = "Enter your feedback"
        feedbackTextView.textColor = UIColor.lightGray
        feedbackTextView.layer.cornerRadius = 8
        feedbackTextView.layer.borderWidth = 0.5
        feedbackTextView.layer.borderColor = UIColor(hexString: "E1E6EF").cgColor
        feedbackTextView.delegate = self
    }
    
    private func configureCollectionView() {
        collectionView.register(UINib(nibName: "ImageAttachCell", bundle: nil), forCellWithReuseIdentifier: "ImageAttachCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let product = max(1, UIScreen.main.bounds.height/844)
        let estimateCollectionViewHeight = 80 * product + 30
        collectionViewHeight.constant = estimateCollectionViewHeight
        scrollContentViewHeight.constant = 364 + estimateCollectionViewHeight + 50
    }
    
    private func configureSubmitBtn() {
        submitBtn.setTitleColor(UIColor(hexString: "FFFFFF"), for: .normal)
        submitBtn.setTitleColor(UIColor(hexString: "7B7B7B"), for: .disabled)
        submitBtn.backgroundColor = UIColor(hexString: "E1E1E1")
        submitBtn.layer.cornerRadius = 10
        
        submitBtn.tap { _ in
            
            guard let yourEmail = self.emailTextField.text, !yourEmail.isEmpty else {
                self.showAlertDialog(title: "Please enter your email!", subtitle: "", cancelTitle: "OK", cancelHandler: nil)
                return
            }
            
            guard let feedback = self.feedbackTextView.text, !feedback.isEmpty else {
                self.showAlertDialog(title: "Please enter your feedback!", subtitle: "", cancelTitle: "OK", cancelHandler: nil)
                return
            }
            
            var uploadFiles : [UploadFile] = []
            
            self.selectedItems.forEach { item in
                switch item {
                case .photo(let photo):
                    if let imageData = photo.image.jpegData(compressionQuality: 0.5) {
                        let media = UploadFile(data: imageData, type: .image, fileName: "\(Date().timeIntervalSince1970).jpeg")
                        uploadFiles.append(media)
                    }
                    break
                case .video(let video):
                    let assetURL = video.url
                    
                    if let data = try? Data(contentsOf: assetURL) {
                        let media = UploadFile(data: data, type: .video, fileName: "\(Date().timeIntervalSince1970).mp4")
                        uploadFiles.append(media)
                    }
                    break
                }
            }
            
            APIClient.sendFeedback(yourEmail: yourEmail, feedBack: feedback, uploadFiles: uploadFiles) { mess in
                if mess?.status == "success"{
                    self.showAlertDialog(title: "Feedback welcome !", subtitle: "Please get in touch and our expert support team will answer all your questions.", cancelTitle: "OK") { str in
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    self.showAlertDialog(title: mess?.message ?? "Send feedback failed. Please try again!", subtitle: "", cancelTitle: "OK") { str in
                    }
                }
            }
        }
    }
    
    private func setColorSubmitButton() {
        if emailTextField.hasText && feedbackTextView.hasText && feedbackTextView.text != "Enter your feedback" {
            submitBtn.backgroundColor = UIColor(hexString: "003DFB")
        } else {
            submitBtn.backgroundColor = UIColor(hexString: "E1E1E1")
        }
    }
}

// MARK: UITextViewDelegate

extension FeedbackViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter your feedback"
            textView.textColor = UIColor.lightGray
        }
        
        setColorSubmitButton()
    }
}

// MARK: UITextFieldDelegate

extension FeedbackViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        setColorSubmitButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

// MARK: UICollectionViewDelegate

extension FeedbackViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedItems.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageAttachCell", for: indexPath) as! ImageAttachCell
        
        if row == 0 {
            cell.deleteBtn.isHidden = true
            cell.imgView.image = UIImage(named: "feedback_add_attach")
        } else {
            cell.deleteBtn.isHidden = false
            
            let item = self.selectedItems[row-1]
            switch item {
            case .photo(let photo):
                cell.imgView.image = photo.image
                break
            case .video(let video):
                cell.imgView.image = video.thumbnail
                break
            }
            
            cell.deleteBtn.tap { _ in
                let actionSheet = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .actionSheet)
                
                actionSheet.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action: UIAlertAction) in
                    self.selectedItems.remove(at: row-1)
                    collectionView.deleteItems(at: [IndexPath(row: row, section: 0)])
                }))
                
                actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                actionSheet.popoverPresentationController?.sourceView = self.view
                actionSheet.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
                actionSheet.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                self.present(actionSheet, animated: true, completion: nil)
            }
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let estimateSize = 80 * (UIScreen.main.bounds.height/844)
        let size = min(80, estimateSize)
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let deviceWidth = UIScreen.main.bounds.width
        return UIEdgeInsets(top: 0, left: 5*deviceWidth/100, bottom: 0, right: 5*deviceWidth/100)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        // spacing ngang
        return 14
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.showPicker()
        }
    }
}

// MARK: YPImagePickerConfiguration

extension FeedbackViewController {
    
    func showPicker() {
        
        var config = YPImagePickerConfiguration()
        
        /* Uncomment and play around with the configuration 👨‍🔬 🚀 */
        
        /* Set this to true if you want to force the  library output to be a squared image. Defaults to false */
        // config.library.onlySquare = true
        
        /* Set this to true if you want to force the camera output to be a squared image. Defaults to true */
        // config.onlySquareImagesFromCamera = false
        
        /* Ex: cappedTo:1024 will make sure images from the library or the camera will be
         resized to fit in a 1024x1024 box. Defaults to original image size. */
        // config.targetImageSize = .cappedTo(size: 1024)
        
        /* Choose what media types are available in the library. Defaults to `.photo` */
        config.library.mediaType = .photo
        config.library.itemOverlayType = .grid
        config.library.isSquareByDefault = false
        config.colors.libraryScreenBackgroundColor = #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1)
        /* Enables selecting the front camera by default, useful for avatars. Defaults to false */
        // config.usesFrontCamera = true
        
        /* Adds a Filter step in the photo taking process. Defaults to true */
        // config.showsFilters = false
        
        /* Manage filters by yourself */
        // config.filters = [YPFilter(name: "Mono", coreImageFilterName: "CIPhotoEffectMono"),
        //                   YPFilter(name: "Normal", coreImageFilterName: "")]
        // config.filters.remove(at: 1)
        // config.filters.insert(YPFilter(name: "Blur", coreImageFilterName: "CIBoxBlur"), at: 1)
        
        /* Enables you to opt out from saving new (or old but filtered) images to the
         user's photo library. Defaults to true. */
        config.shouldSaveNewPicturesToAlbum = false
        
        /* Choose the videoCompression. Defaults to AVAssetExportPresetHighestQuality */
        config.video.compression = AVAssetExportPresetPassthrough
        
        /* Choose the recordingSizeLimit. If not setted, then limit is by time. */
        // config.video.recordingSizeLimit = 10000000
        
        /* Defines the name of the album when saving pictures in the user's photo library.
         In general that would be your App name. Defaults to "DefaultYPImagePickerAlbumName" */
        // config.albumName = "ThisIsMyAlbum"
        
        /* Defines which screen is shown at launch. Video mode will only work if `showsVideo = true`.
         Default value is `.photo` */
        config.startOnScreen = .library
        
        /* Defines which screens are shown at launch, and their order.
         Default value is `[.library, .photo]` */
        config.screens = [.library]
        
        /* Can forbid the items with very big height with this property */
        // config.library.minWidthForItem = UIScreen.main.bounds.width * 0.8
        
        /* Defines the time limit for recording videos.
         Default is 30 seconds. */
        // config.video.recordingTimeLimit = 5.0
        
        /* Defines the time limit for videos from the library.
         Defaults to 60 seconds. */
        config.video.libraryTimeLimit = 500.0
        
        /* Adds a Crop step in the photo taking process, after filters. Defaults to .none */
        config.showsCrop = .none//.rectangle(ratio: (16/9))
        
        /* Changes the crop mask color */
        config.colors.albumTitleColor = .white
        config.colors.albumTintColor = .white
        config.colors.albumBarTintColor = #colorLiteral(red: 0.09411764706, green: 0.09411764706, blue: 0.09411764706, alpha: 1)
        config.colors.safeAreaBackgroundColor = #colorLiteral(red: 0.09411764706, green: 0.09411764706, blue: 0.09411764706, alpha: 1)
        //        config.colors.tintColor = .white
        /* Defines the overlay view for the camera. Defaults to UIView(). */
        // let overlayView = UIView()
        // overlayView.backgroundColor = .red
        // overlayView.alpha = 0.3
        // config.overlayView = overlayView
        
        /* Customize wordings */
        config.wordings.libraryTitle = "Gallery"
        
        
        /* Defines if the status bar should be hidden when showing the picker. Default is true */
        config.hidesStatusBar = false
        
        /* Defines if the bottom bar should be hidden when showing the picker. Default is false */
        config.hidesBottomBar = false
        
        config.maxCameraZoomFactor = 2.0
        
        config.library.maxNumberOfItems = 5
        config.library.defaultMultipleSelection = true
        config.gallery.hidesRemoveButton = true
        
        /* Disable scroll to change between mode */
        // config.isScrollToChangeModesEnabled = false
        // config.library.minNumberOfItems = 2
        
        /* Skip selection gallery after multiple selections */
        config.library.skipSelectionsGallery = true
        
        /* Here we use a per picker configuration. Configuration is always shared.
         That means than when you create one picker with configuration, than you can create other picker with just
         let picker = YPImagePicker() and the configuration will be the same as the first picker. */
        
        /* Only show library pictures from the last 3 days */
        //let threDaysTimeInterval: TimeInterval = 3 * 60 * 60 * 24
        //let fromDate = Date().addingTimeInterval(-threDaysTimeInterval)
        //let toDate = Date()
        //let options = PHFetchOptions()
        // options.predicate = NSPredicate(format: "creationDate > %@ && creationDate < %@", fromDate as CVarArg, toDate as CVarArg)
        //
        ////Just a way to set order
        //let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        //options.sortDescriptors = [sortDescriptor]
        //
        //config.library.options = options
        
        config.library.preselectedItems = selectedItems
        
        
        // Customise fonts
        //config.fonts.menuItemFont = UIFont.systemFont(ofSize: 22.0, weight: .semibold)
        //config.fonts.pickerTitleFont = UIFont.systemFont(ofSize: 22.0, weight: .black)
        //config.fonts.rightBarButtonFont = UIFont.systemFont(ofSize: 22.0, weight: .bold)
        //config.fonts.navigationBarTitleFont = UIFont.systemFont(ofSize: 22.0, weight: .heavy)
        //config.fonts.leftBarButtonFont = UIFont.systemFont(ofSize: 22.0, weight: .heavy)
        
        let picker = YPImagePicker(configuration: config)
        
        picker.imagePickerDelegate = self
        
        /* Change configuration directly */
        // YPImagePickerConfiguration.shared.wordings.libraryTitle = "Gallery2"
        
        /* Multiple media implementation */
        picker.didFinishPicking { [weak picker] items, cancelled in
            
            if cancelled {
                print("Picker was canceled")
                picker?.dismiss(animated: true, completion: nil)
                return
            }
            
            self.selectedItems = items
            picker?.dismiss(animated: true, completion: {[weak self] in
                guard let `self` = self else {return}
                DispatchQueue.main.async {
//                    if self.selectedItems.count > 0{
//                        self.heightCollectionView.constant = 72
//                        self.heightContentScrollView.constant = 680
//                    }else{
//                        self.heightCollectionView.constant = 0
//                        self.heightContentScrollView.constant = 680 - 72
//                    }
//                    self.view.layoutIfNeeded()
                    self.collectionView.reloadData()
                }
            })
        }
        
        /* Single Photo implementation. */
        // picker.didFinishPicking { [weak picker] items, _ in
        //     self.selectedItems = items
        //     self.selectedImageV.image = items.singlePhoto?.image
        //     picker.dismiss(animated: true, completion: nil)
        // }
        
        /* Single Video implementation. */
        // picker.didFinishPicking { [weak picker] items, cancelled in
        //    if cancelled { picker.dismiss(animated: true, completion: nil); return }
        //
        //    self.selectedItems = items
        //    self.selectedImageV.image = items.singleVideo?.thumbnail
        //
        //    let assetURL = items.singleVideo!.url
        //    let playerVC = AVPlayerViewController()
        //    let player = AVPlayer(playerItem: AVPlayerItem(url:assetURL))
        //    playerVC.player = player
        //
        //    picker.dismiss(animated: true, completion: { [weak self] in
        //        self?.present(playerVC, animated: true, completion: nil)
        //        print("😀 \(String(describing: self?.resolutionForLocalVideo(url: assetURL)!))")
        //    })
        //}
        
        present(picker, animated: true, completion: nil)
    }
}

// MARK: YPImagePickerDelegate
extension FeedbackViewController: YPImagePickerDelegate {
    func noPhotos() {
        
    }
    
    func imagePickerHasNoItemsInLibrary(_ picker: YPImagePicker) {
        
    }

    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true
    }
}
