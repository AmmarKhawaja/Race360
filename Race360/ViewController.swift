//
//  ViewController.swift
//  Race360
//
//  Created by Ammar Khawaja on 1/3/24.
//

import UIKit
import AuthenticationServices
import FirebaseDatabase

let r = Database.database().reference()
var USERID = ""

class ViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    let userDefaults = UserDefaults.standard
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("SUCCESS")
        switch authorization.credential {
        case let credentials as ASAuthorizationAppleIDCredential:
            //Retrieve login credentials here
            let name = credentials.fullName
            var id = String(credentials.user)
            id = id.replacingOccurrences(of: ".", with: "")
            userDefaults.set(id, forKey: "USERID")
            USERID = userDefaults.string(forKey: "USERID") ?? "NULL"
            print("UID", USERID)
            r.child("users").child(USERID).child("name").setValue("Driver \(Int.random(in: 1..<999999))")
            r.child("users").child(USERID).child("vehicle").setValue("Set Vehicle")
            performSegue(withIdentifier: "signedin", sender: self)
            break
        default:
            break
        }
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("FAILED SIGN IN")
    }
    
    let appleSignIn = ASAuthorizationAppleIDButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PRINT")
        view.addSubview(appleSignIn)
        appleSignIn.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
        USERID = userDefaults.string(forKey: "USERID") ?? "NULL"
        let r = Database.database().reference()
        r.child("test").setValue(Date.timeIntervalBetween1970AndReferenceDate)
    }
    override func viewDidAppear(_ animated: Bool) {
        if USERID != "NULL" {
            performSegue(withIdentifier: "signedin", sender: self)
        }
        print("UID ", USERID)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appleSignIn.frame = CGRect(x: 0, y: 0, width: 250, height: 50)
        appleSignIn.center = view.center
    }

    @objc func appleSignInTapped() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    
}

