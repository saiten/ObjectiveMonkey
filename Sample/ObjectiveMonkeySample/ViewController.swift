//
//  ViewController.swift
//  ObjectiveMonkeySample
//
//  Created by saiten on 2016/12/20.
//

import UIKit
import ObjectiveMonkey

@objc class Foo : NSObject {
    func name() -> String {
        return "Foo"
    }
    
    func sum(A: Int, B: Int, C: Int) -> Int {
        return A + B + C
    }
}

@objc class Bar : Foo {
    override func name() -> String {
        return "Bar"
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func pressButton(sender: Any) {
        assert(false) // fail anyway
    }
    
    func instanceMethod() -> String {
        return "hogehoge"
    }

}

