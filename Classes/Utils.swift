
//
//  PlayerLayer.swift
//  weeanaiOSPlayer
//
//  Created by Yasir N.Ramaya on 7/7/20.
//  Copyright © 2020 qi. All rights reserved.
//

import Foundation

class Utils {
    
    static func myBundle() -> Bundle? {
        let bundle = Bundle(for: Self.self)
        let path = bundle.path(forResource: "Bundle", ofType: "bundle")
        print(path ?? "nil")
        return Bundle(path: path ?? "")
    }

    static func viewController(withStoryboard storyboardName: String, storyboardID id: String) -> UIViewController? {
        let storyboard = UIStoryboard(name: storyboardName, bundle: myBundle())
        if #available(iOS 13.0, *) {
            return storyboard.instantiateViewController(identifier: id)
        }
        return storyboard.instantiateViewController(withIdentifier: id)
    }

    static func xib(withNibName nibName: String) -> UINib? {
       return UINib(nibName: nibName, bundle: myBundle())
    }

    static func image(named name: String) -> UIImage? {
        return UIImage(named: name, in: myBundle(), compatibleWith: nil)
    }

    static func localizedString(_ key: String) -> String {
        guard let bundle = myBundle() else { return "" }
        return NSLocalizedString(key, tableName: "Localizable", bundle: bundle, value: "", comment: "")
    }
}
