# YZImagePicker

![YZImagePicker](/Resource/PickImage.gif "Sample YZImagePicker")

**YZImagePicker** is a simple and easy-to-use image picker class for iOS, written in Swift. It provides a convenient way to pick images from the device's photo library or camera.

## Prerequisites

Please add following permissions into the info.plist file:
1. Privacy - Photo Library Usage Description for `photoLibrary`
1. Privacy - Camera Usage Description for `camera`

## Features

- Pick images from the device's photo library.
- Capture images using the device's camera.
- Option to allow image editing before selection.
- Designed to work seamlessly with UIKit.

## Usage

- Create an instance of YZImagePicker in your view controller:

```
var yzImagePicker: YZImagePicker!
yzImagePicker = YZImagePicker(presentationController: self)
```

- Pick an image from the Photos / Carema:

```
yzImagePicker.pick(type: .photoLibrary, allowEditing: true) { image in
        // Handle the selected image here
    }
```

## Parameters

- type: The source type to pick the image. It can be either photoLibrary or camera.
- allowEditing: A boolean value to allow image editing. default value is false.
