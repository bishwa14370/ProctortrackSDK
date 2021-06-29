//
//  Utility.swift
//  FrameWorkTestPOC

import UIKit
import Foundation
class Utility {
    
    static func performSegueToIdentityVerification(caller: UIViewController) {
        let bundle = Bundle(for: SystemCheckVC.self)
        let storyboard = UIStoryboard(name: "FrameWork", bundle: bundle)
        DispatchQueue.main.async {
            if let vc = storyboard.instantiateViewController(withIdentifier: "systemCheckVC") as? SystemCheckVC, let navController = caller.navigationController {
                navController.pushViewController(vc, animated: true)
            }
        }
    }
}

extension UINavigationController {
    
    func backToViewController(vc: Any) {
        // iterate to find the type of vc
        for element in viewControllers as Array {
            if "\(type(of: element)).Type" == "\(type(of: vc))" {
                self.popToViewController(element, animated: true)
                break
            }
        }
    }
    
    func popBack(_ count: Int) {
        
        let index = viewControllers.count - count - 1
        if index <= 0 {
            popToRootViewController(animated: true)
        }else
        {
            popToViewController(viewControllers[index], animated: true)
        }
    }
}
