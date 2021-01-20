//
//  Theme.swift
//  MeloApp
//
//  Created by Minh Tri on 1/19/21.
//

import Foundation

struct Theme {
    var uid: StringUID?
    var backgroundImage: String?
    var colors: [StringHex]?
    
    init(uid: StringUID, dataFromServer: [String: Any]) {
        self.uid = uid
        self.backgroundImage = dataFromServer["backgroundImage"] as? StringUID
        self.colors = dataFromServer["colors"] as? [StringHex]
    }
    
    init(backgroundImage: String?, colors: [StringHex]?) {
        self.backgroundImage = backgroundImage
        self.colors = colors
    }
    
    func dictionaryForSend() -> [String: Any] {
        var dict: [String: Any] = [:]
       
        dict["backgroundImage"] = backgroundImage
        dict["colors"] = colors
        
        return dict
    }
}
