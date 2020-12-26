//
//  FMPhotoPickerOptions.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/09.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import Foundation
import Photos

public enum FMSelectMode {
    case multiple
    case single
}

public enum FMMediaType {
    case image
    case video
    case unsupported
    
    public func value() -> Int {
        switch self {
        case .image:
            return PHAssetMediaType.image.rawValue
        case .video:
            return PHAssetMediaType.video.rawValue
        case .unsupported:
            return PHAssetMediaType.unknown.rawValue
        }
    }
    
    init(withPHAssetMediaType type: PHAssetMediaType) {
        switch type {
        case .image:
            self = .image
        case .video:
            self = .video
        default:
            self = .unsupported
        }
    }
}

public struct FMPhotoPickerConfig {
    public var mediaTypes: [FMMediaType] = [.image]
    public var selectMode: FMSelectMode = .multiple
    public var maxImage: Int = 10
    public var maxVideo: Int = 10
    public var availableFilters: [FMFilterable]? = kDefaultAvailableFilters
    public var availableCrops: [FMCroppable]? = kDefaultAvailableCrops
    public var useCropFirst: Bool = false
    public var alertController: FMAlertable = FMAlert()

    /// Whether you want FMPhotoPicker returns PHAsset instead of UIImage.
    public var shouldReturnAsset: Bool = false
    
    public var forceCropEnabled = false
    public var eclipsePreviewEnabled = false
    
    public var titleFontSize: CGFloat = 17
    
    public var strings: [String: String] = [
        "picker_button_cancel":                     "Huỷ",
        "picker_button_select_done":                "Gửi",
        "picker_warning_over_image_select_format":  "Bạn có thể chọn tối đa %d ảnh",
        "picker_warning_over_video_select_format":  "Bạn có thể chọn tối đa %d video",
        
        "present_title_photo_created_date_format":  "yyyy/M/d",
        "present_button_back":                      "Trở lại",
        "present_button_edit_image":                "Chỉnh sửa",
        
        "editor_button_cancel":                     "Huỷ",
        "editor_button_done":                       "Hoàn tất",
        "editor_menu_filter":                       "Filter",
        "editor_menu_crop":                         "Cắt",
        "editor_menu_crop_button_reset":            "Reset",
        "editor_menu_crop_button_rotate":           "Xoay",
        
        "editor_crop_ratio4x3":                     "4:3",
        "editor_crop_ratio16x9":                    "16:9",
        "editor_crop_ratio9x16":                    "9x16",
        "editor_crop_ratioCustom":                  "Tuỳ chỉnh",
        "editor_crop_ratioOrigin":                  "Ảnh gốc",
        "editor_crop_ratioSquare":                  "Vuông",

        "permission_dialog_title":                  "tChat",
        "permission_dialog_message":                "tChat muốn sử dụng Photo Library",
        "permission_button_ok":                     "OK",
        "permission_button_cancel":                 "Huỷ"
    ]
    
    public init() {
        
    }
}
