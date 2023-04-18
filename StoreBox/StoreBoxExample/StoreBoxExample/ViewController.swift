import UIKit
import StoreBox

enum AppSettings: String, BoxKey {
    case onboardingPassed
    case userIsLogin
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let box = Box<AppSettings>.load(type: .secure)
        print("Login: \(box.getBool(forKey: .userIsLogin))")
        print("Onbarding: \(box.getBool(forKey: .onboardingPassed))")
        
        box.set(object: true, forKey: .onboardingPassed)
        box.set(object: true, forKey: .userIsLogin)

        print("Login: \(box.getBool(forKey: .userIsLogin))")
        print("Onbarding: \(box.getBool(forKey: .onboardingPassed))")

        let stringBox = Box<String>.load(boxKey: "MySettings", type: .secure)
        print("TestKey: \(stringBox.get(String.self, forKey: "TestKey") ?? "No value")")
        stringBox.set(object: "TestValue", forKey: "TestKey")
        print("TestKey: \(stringBox.getString(forKey: "TestKey") ?? "No value")")
    }
}

