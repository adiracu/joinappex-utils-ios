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
        print("Login: \(box.bool(forKey: .userIsLogin))")
        print("Onbarding: \(box.bool(forKey: .onboardingPassed))")
        
        box.set(true, forKey: .onboardingPassed)
        box.set(true, forKey: .userIsLogin)

        print("Login: \(box.bool(forKey: .userIsLogin))")
        print("Onbarding: \(box.bool(forKey: .onboardingPassed))")

        let stringBox = Box<String>.load(boxKey: "MySettings", type: .secure)
        print("TestKey: \(stringBox.get(String.self, forKey: "TestKey") ?? "No value")")

        stringBox.set("TestValue", forKey: "TestKey")
        print("TestKey: \(stringBox.get(String.self, forKey: "TestKey") ?? "No value")")

        stringBox.setEncodable(TestCodable(), forKey: "TestKeyCodable")
        print("TestKey: \(stringBox.getDecodable(TestCodable.self, forKey: "TestKeyCodable")!)")
    }
}


struct TestCodable: Codable {
    var value: Int = 0
}
