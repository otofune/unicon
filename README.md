unicon
===

[日本語はこちら](./README-ja.md)

A simple macOS app for showing architecture (instruction set) of running application in status menu.

The main purpose of this app is to make easier checking what app supports Arm-based Macs natively.

<img src="./docs/finder@2x.png" width="443px">
<img src="./docs/getting_over_it@2x.png" width="511px">

How to install
---

1. Download app archive from [Latest release](https://github.com/otofune/unicon/releases/latest)
1. Open dmg and copy `unicon.app` to /Applications
1. (Optional) Add to Login Items to start the app automatically when you log in. See https://support.apple.com/guide/mac-help/mtusr003/mac

Of course, you can build it by yourself.
Please open `unicon.xcworkspace` with Xcode.

This project doesn't use any external dependencies at now, so you can build this project soon after opening.

Questions
---

[Opening GitHub Issues](https://github.com/otofune/unicon/issues/new) about any problems or questions are always welcome!

You can write in English or Japanese.

### Q. Why is "Architectures supported" sometimes not shown?

Almost cases caused by no permission to open executable file of running application. For getting supported architectures, that's required to open executable file.

This is not a problem for most apps having executables in world-readable `/Applications` directory.  
But sometimes executables are saved as user data.
This app can't open user data without selecting in Open Dialog due to enable App Sandbox. So "Architecture supported" can't be shown.

For example executables of Steam games and iOS apps installed by .ipa are saved in user space.

LICENSE
---

MIT, See [`LICENSE`](./LICENSE)

LICENSE (AppIcon)
---

(c) みふねたかし (いらすとや)

See [`unicon/Assets.xcassets/AppIcon.appiconset/LICENSE`](./unicon/Assets.xcassets/AppIcon.appiconset/LICENSE)
