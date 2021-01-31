# KSTimerView

A simple `SwiftUI` timer view with **Background**, **LocalNotification** and **Haptic** support.

## Usage

Initialise the KSTimerView with `TimeInterval` and present it using `.sheet` or `.fullScreenCover` modifier or use with `ZStack`.

```
.sheet(isPresented: $shouldPresentTimerView, content: {
   KSTimerView(timerInterval: $timeInterval)
})
```

### Customisation

You can customise the **KSTimerView** using `KSTimerView.Configuration` and initialise KSTimerView with your configuration.

```
let configuration = KSTimerView.Configuration(timerBgColor: .yellow, timerRingBgColor: .red, actionButtonsBgColor: .blue, foregroundColor: .white, stepperValue: 10, enableLocalNotification: true, enableHapticFeedback: true)

KSTimerView(timerInterval: $timeInterval, configuration: configuration)

```
![Image](https://drive.google.com/file/d/15CyR_DkukNdbUNkrALo0vamPe3RLRzKL/view?usp=sharing)

## Background 
Background to foreground will be handled by default. You no need to do anything.

## LocalNotification

It is disabled by default. Enable it using `enableLocalNotification` in `KSTimerView.Configuration`. 

```
let configuration = KSTimerView.Configuration(..., enableLocalNotification: true, ...)
```

> ⚠️ Note: You need to get permission from user to use `LocalNotification`. Get it before presenting the timer view to the user.

## Haptic Feedback
It is disabled by default. Enable it using `enableHapticFeedback` in `KSTimerView.Configuration`.

```
let configuration = KSTimerView.Configuration(..., enableHapticFeedback: true)

```

## Integration
KSTimerView supports SPM (Swift Package Manager). You can integrate it using Xcode, `File -> Swift Packages -> Add Package Dependency...`

Enter, **https://github.com/karthironald/KSTimerView** in repo URL.

## Contribution
1. Open an issue, if you need any improvements or if you face any issues.

Thanks! 👨🏻‍💻