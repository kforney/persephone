//
//  WindowController.swift
//  Persephone
//
//  Created by Daniel Barber on 2019/1/11.
//  Copyright © 2019 Dan Barber. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
  enum TransportAction: Int {
    case prevTrack = 0
    case playPause = 1
    case stop = 2
    case nextTrack = 3
  }

  override func windowDidLoad() {
    super.windowDidLoad()
    window?.titleVisibility = .hidden

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(stateChanged(_:)),
      name: MPDClient.stateChanged,
      object: AppDelegate.mpdClient
    )
  }

  @objc func stateChanged(_ notification: Notification) {
    guard let state = notification.userInfo?[MPDClient.stateKey] as? MPDClient.State
      else { return }

    stateLabel.stringValue = "\(state)".localizedCapitalized
    setTransportControlState(state)
  }

  func setTransportControlState(_ state: MPDClient.State) {
    transportControls.setEnabled([.playing, .paused].contains(state), forSegment: 0)
    transportControls.setEnabled([.playing, .paused, .stopped].contains(state), forSegment: 1)
    transportControls.setEnabled([.playing, .paused].contains(state), forSegment: 2)
    transportControls.setEnabled([.playing, .paused].contains(state), forSegment: 3)

    if [.paused, .stopped, .unknown].contains(state) {
      transportControls.setImage(NSImage(named: NSImage.Name(rawValue: "playButton")), forSegment: 1)
    } else {
      transportControls.setImage(NSImage(named: NSImage.Name(rawValue: "pauseButton")), forSegment: 1)
    }
  }

  @IBAction func handleTransportControl(_ sender: NSSegmentedControl) {
    guard let transportAction = TransportAction(rawValue: sender.selectedSegment)
      else { return }

    switch transportAction {
    case .prevTrack:
      AppDelegate.mpdClient.prevTrack()
    case .playPause:
      AppDelegate.mpdClient.playPause()
    case .stop:
      AppDelegate.mpdClient.stop()
    case .nextTrack:
      AppDelegate.mpdClient.nextTrack()
    }
  }

  @IBOutlet var stateLabel: NSTextField!
  @IBOutlet var transportControls: NSSegmentedCell!
}
