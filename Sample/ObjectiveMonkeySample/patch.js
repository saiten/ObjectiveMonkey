var appVersion = $p.getAppVersion();

$p.consoleLog(`app version = ${appVersion}`);

if(appVersion == '1.0') {

  $p.addPatch('ObjectiveMonkeySample.Foo', 'name', (
    self // OMKObjcBox<Bar *>
  ) => {
    return self.callSuper('name'); // call Foo#name
  });

  $p.addPatch('ObjectiveMonkeySample.Bar', 'sumWithA:B:C:', (
    self, // OMKObjcBox<Foo *>
    a,
    b,
    c
  ) => {
    let ret = self.originalImplementation(a, b, c);
    return ret + 12;
  });

  $p.addPatch('ObjectiveMonkeySample.ViewController', 'pressButtonWithSender:', (
    self,  // OMKObjcBox<STViewController *>
    sender // OMKObjcBox<id>
  ) => {
    let UIColor = $p.NSClassFromString('UIColor');
    let color = UIColor.call('colorWithRed:green:blue:alpha:', Math.random(), Math.random(), Math.random(), 1.0);
    self.call('view').call('setBackgroundColor:', color);

    $p.consoleLog("patched pressButton");
    let nsString = self.call("instanceMethod"); // OMKObjcBox<NSString *>
    $p.consoleLog("instanceMethod = " + nsString.jsString());

    // create instance
    let BarClass = $p.NSClassFromString('ObjectiveMonkeySample.Bar'); // OMKObjcBox<Class>
    let bar = BarClass.call('alloc').call('init'); // OMKObjcBox<Bar *>

    let sum = bar.call('sumWithA:B:C:', 10, 24, 32);
    $p.consoleLog(`Bar#sum = ${sum}`);

    let name = bar.call('name').jsString();
    $p.consoleLog(`Bar#name = ${name}`);
  });

}
