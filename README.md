# ObjectiveMonkey

Hot patch for iOS App

## Requirements

- iOS 8 or Later

## Installation

ObjectiveMonkey is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ObjectiveMonkey"
```

## Usage

### Setup

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // apply remote patch
    ObjectiveMonkey.default().patch(from: URL(string: "https://example.com/patch.js")!)
    return true
}
```

### Patch code

problem code

```swift
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func pressButton(sender: Any) {
        assert(false) // fail anyway
    }
}
```

patch script

```js
$p.addPatch('ViewController', 'pressButtonWithSender:', (
  self,  // OMKObjcBox<ViewController *>
  sender // OMKObjcBox<id>
) => {
  $p.consoleLog("patched pressButton");

  // change background color
  let UIColor = $p.NSClassFromString('UIColor');　// -> OMKObjcBox<Class>
  let color = UIColor.call('colorWithRed:green:blue:alpha:', Math.random(), Math.random(), Math.random(), 1.0); // -> OMKObjcBox<UIColor *>
  self.call('view').call('setBackgroundColor:', color);
});
```

## Author

saiten, saiten@isidesystem.net

## License

ObjectiveMonkey is available under the MIT license. See the LICENSE file for more info.
