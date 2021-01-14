unicon
===

[日本語はこちら](./README-ja.md)

A simple macOS app for showing architecture (instruction set) of running application in status menu.

The main purpose of this app is to make easier checking what app supports Arm-based Macs natively.

<img src="./docs/finder@2x.png" width="443px">
<img src="./docs/getting_over_it@2x.png" width="511px">

How to install
---

1. Download notalized app from [GitHub Releases](https://github.com/otofune/unicon/releases)
2. Copy unicon.app to /Applications
3. (Optional) Add to Login Items to start the app automatically when you log in. See https://support.apple.com/guide/mac-help/mtusr003/mac

Of course, you can build it by yourself.
Please open unicon.xcworkspace with Xcode.

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

```
The MIT License (MIT)

Copyright (c) 2020- otofune <otofune@otofune.me>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

LICENSE (AppIcon)
---

(c) みふねたかし (いらすとや)

See [unicon/Assets.xcassets/AppIcon.appiconset/LICENSE](./unicon/Assets.xcassets/AppIcon.appiconset/LICENSE)
