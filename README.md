# DXVideoPlay


[![Version](https://img.shields.io/cocoapods/v/DXVideoPlay.svg?style=flat)](https://cocoapods.org/pods/DXVideoPlay)
[![License](https://img.shields.io/cocoapods/l/DXVideoPlay.svg?style=flat)](https://cocoapods.org/pods/DXVideoPlay)
[![Platform](https://img.shields.io/cocoapods/p/DXVideoPlay.svg?style=flat)](https://cocoapods.org/pods/DXVideoPlay)

## Features

- Support HLS, MP4
- Support multi quality video source
- Support playlist
- Support SRT subtitle
- Subtitle control


![alt text](https://raw.githubusercontent.com/yasirdx777/square_progress_bar/main/Example/DXVideoPlay/preview.gif)


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

DXVideoPlay is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DXVideoPlay'
```


## Usage

First import DXVideoPlay

```swift
import DXVideoPlay
```

And prepare the DXVideoPlay data model.

```swift
let videoMP4Source480p = VideoSource(sourceTitel: "480p", sourceVideo: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
let videoMP4Source720p = VideoSource(sourceTitel: "720p", sourceVideo: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
let subtitleSRTSource = URL(string: "https://raw.githubusercontent.com/nick-vanpraet/subtitles-test/master/D20/FHSY/e01.srt")!
        
        
let assetItemOne = AssetItem(id: 0, itemTitle: "Clip 1", itemSubtitle: subtitleSRTSource, itemVideoSources: [videoMP4Source480p, videoMP4Source720p])
let assetItemTwo = AssetItem(id: 0, itemTitle: "Clip 2", itemSubtitle: subtitleSRTSource, itemVideoSources: [videoMP4Source480p, videoMP4Source720p])
        
        
let model = DXPlayerModel(id: 101, assetItems: [assetItemOne, assetItemTwo])
```
Then create the DXVideoPlay VC and initiate it with the data model you prepared.

```swift
let dxPlayer = DXVideoPlay(playerModel: model)
```
In the end just set the VC modal presentation style to fullScreen and present it.

```swift
dxPlayer.modalPresentationStyle = .fullScreen
present(dxPlayer, animated: true, completion: nil)
```

## Author

Yasir Romaya, yasir.romaya@gmail.com

## License

DXVideoPlay is available under the MIT license. See the LICENSE file for more info.
