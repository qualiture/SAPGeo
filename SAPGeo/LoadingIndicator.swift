//
// LoadingIndicator.swift
// SAPGeo
//
// Created by SAP Cloud Platform SDK for iOS Assistant application on 14/06/17
//

import Foundation
import SAPFiori

protocol LoadingIndicator: class {
    var loadingIndicator: FUILoadingIndicatorView? { get set }
}

extension LoadingIndicator where Self: UIViewController {

    func showIndicator(_ message: String = "") {
        if self.loadingIndicator == nil {
            let indicator = FUILoadingIndicatorView(frame: self.view.frame)
            self.loadingIndicator = indicator
        }
        let indicator = self.loadingIndicator!
        indicator.text = message
        DispatchQueue.main.async {
            self.view.addSubview(indicator)
            indicator.show()
        }
    }

    func hideIndicator() {
        DispatchQueue.main.async {
            guard let loadingIndicator = self.loadingIndicator else {
                return
            }
            loadingIndicator.dismiss()
            loadingIndicator.removeFromSuperview()
        }
    }
}
