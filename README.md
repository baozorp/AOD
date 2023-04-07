# AOD Image Viewer

AOD Image Viewer is an iOS app that allows you to display your favorite images on your device's Always On Display (AOD) screen. With AOD Image Viewer, you can select a collection of images to be displayed on your device's AOD screen and easily switch between them using a small, scrollable collection view.

## Technologies Used

- Swift programming language
- UIKit framework
- Core Data framework
- GCD and OperationQueue for managing concurrent tasks
- UIViewPropertyAnimator and CABasicAnimation for implementing animations
- PHPicker framework for selecting images from the device's photo library
- Auto Layout for programmatic UI layout
- The delegate pattern for passing data

## Features

- Select and display your favorite images on your device's AOD screen
- Easily switch between images using a small, scrollable collection view
- Remove images from the collection view
- Add new images to the collection view using the PHPicker framework

## Requirements

- iOS 16.0 or later
- Xcode 14.0 or later

## Installation

1. Clone or download the repository.
2. Open `AODImageViewer.xcodeproj` in Xcode.
3. Build and run the app on a connected device or simulator.

## Usage

1. Launch the app.
2. Scroll through the collection view on the main screen to change images.
3. Long-press an image to open the selection menu.
4. Tap the "+" button to add images from your device's photo library.
5. Long-press an image on the main screen to enter delete mode.
6. Tap an image to select it for display on the main screen or for deletion if in delete mode.
