//
//  UserSettingViewController.swift
//  MeloApp
//
//  Created by Minh Tri on 1/7/21.
//

import UIKit
import FMPhotoPicker
import Firebase

class UserSettingViewController: UIViewController {

    @IBOutlet weak var customNav: NavigationBarNormal!
    @IBOutlet weak var collectionUserSetting: UICollectionView!
    
    let userSettingTitles = ["Thay đổi ảnh đại diện", "Thông tin ứng dụng", "Đăng xuất"]
    let userSettingIcons = [#imageLiteral(resourceName: "userIcon"), UIImage(systemName: "info.circle"), #imageLiteral(resourceName: "logoutIcon")]
    
    lazy var loadingAnimation: LoadingIndicator = {
       let loading = LoadingIndicator()
        loading.isTurnBlurEffect = false
        loading.colorIndicator = .blue
        loading.frame = self.view.bounds
        loading.startAnimation()
        
        return loading
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCustomNav()
        setupCollectionUserSetting()
    }
    
    private func setupCustomNav() {
        customNav.titleLabel.text = "Cài đặt"
        customNav.preferLarge = false
        customNav.delegate = self
    }
    
    private func setupCollectionUserSetting() {
        collectionUserSetting.register(UINib(nibName: "UserSettingCell", bundle: .main), forCellWithReuseIdentifier: K.cellID.userSettingCell)
        collectionUserSetting.register(UINib(nibName: "HeaderUserSettingCell", bundle: .main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: K.cellID.headerUserSettingCell)
        
        collectionUserSetting.delegate = self
        collectionUserSetting.dataSource = self
    }
}

extension UserSettingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == 0 {
            handlePickerProfile()
        } else if indexPath.item == userSettingTitles.count - 1 {
            handleLogoutTapped()
        }
    }
    
    private func handlePickerProfile() {
        var config = FMPhotoPickerConfig()
        config.mediaTypes = [.image]
        config.selectMode = .single
        
        let imagePicker = FMPhotoPickerViewController(config: config)
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func handleLogoutTapped() {
        AuthController.shared.handleLogout()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let vc = storyboard.instantiateViewController(identifier: K.sbID.rootNavigationController)
        self.view.window?.rootViewController = vc
        self.view.window?.makeKeyAndVisible()
    }
}

extension UserSettingViewController: FMPhotoPickerViewControllerDelegate {
    func fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith photos: [UIImage]) {
        
        guard let _ = AuthController.shared.currentUser else { return }
        if photos.count != 1 { return }
        
        dismiss(animated: true, completion: nil)
        
        // Upload thumbnail
        if let thumnbail = photos[0].resize(width: 200) {
            StorageController.uploadImage(thumnbail) { (uploadTask) in
                uploadTask.observe(.success) { (taskSnap) in
                    
                    taskSnap.reference.downloadURL { (url, error) in
                        if (error != nil) {
                            print(error!.localizedDescription)
                            return
                        }
                        
                        Firestore.firestore().collection("users")
                            .document(AuthController.shared.currentUser!.uid!)
                            .updateData(["profileImageThumbnail" : url!.absoluteString])
                    }
                }
            }
        }
        
        // Upload image
        StorageController.uploadImage(photos[0]) { (uploadTask) in
            uploadTask.observe(.success) { (taskSnap) in
                
                taskSnap.reference.downloadURL { (url, error) in
                    if (error != nil) {
                        print(error!.localizedDescription)
                        return
                    }
                    
                    Firestore.firestore().collection("users")
                        .document(AuthController.shared.currentUser!.uid!)
                        .updateData(["profileImage" : url!.absoluteString])
                }
            }
        }
    }
}

extension UserSettingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userSettingTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionUserSetting.dequeueReusableCell(withReuseIdentifier: K.cellID.userSettingCell, for: indexPath) as! UserSettingCell
        
        cell.icon.image = userSettingIcons[indexPath.item]
        cell.settingName.text = userSettingTitles[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionUserSetting.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: K.cellID.headerUserSettingCell, for: indexPath) as! HeaderUserSettingCell
            
            AuthController.shared.listenChangeCurrentUser { (user) in
                if user == nil { return }
                
                let imgLoading = ImageLoading()
                imgLoading.loadingImageAndCaching(
                    target: headerView.avatar,
                    with: AuthController.shared.currentUser?.profileImageThumbnail,
                    placeholder: nil,
                    progressHandler: nil) { (error) in
                    if (error != nil) { print(error!) }
                }
                headerView.userName.text = AuthController.shared.currentUser?.name
            }

            headerView.delegate = self
            return headerView
            
        default:
            return UICollectionReusableView()
        }
    }
}

extension UserSettingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension UserSettingViewController: NavigationBarNormalDelegate {
    func navigationBar(_ naviagtionBarNormal: NavigationBarNormal, backPressed sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath) as! HeaderUserSettingCell
        
        return CGSize(width: self.view.bounds.width, height: headerView.viewHeight() + 20)
    }
}

extension UserSettingViewController: HeaderUserSettingCellDelegate {
    func cellDidTap(_ header: HeaderUserSettingCell) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let vc = storyboard.instantiateViewController(identifier: K.sbID.imageDetailViewController) as! ImageDetailViewController
        
        vc.originUrlImage = URL(string: AuthController.shared.currentUser!.profileImage!)
        navigationController?.pushViewController(vc, animated: false)
    }
}
