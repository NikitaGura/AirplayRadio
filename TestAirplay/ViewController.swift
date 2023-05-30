//
//  ViewController.swift
//  TestAirplay
//
//  Created by Mykyta Hura on 29/05/2023.
//

import UIKit
import AVFoundation
import MediaPlayer
import AVKit

class ViewController: UIViewController {
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var airPlayView: UIView!
    var nowPlayingInfo: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAirPlayButton()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback,
                                         mode: .default,
                                         policy: .longFormAudio)
        } catch {
            
        }
        
       
   
        setupRemoteTransportControls()
        setNowPlayingTitle(title: "Test")
        setNowPlayingArtwork(backgroundNotificationImage: "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg")
        
        RadioPlayer.sharedInstance.play()
        playButton.setImage(UIImage(systemName: "pause.fill" ), for: UIControl.State.normal)
        
    }
    func setupAirPlayButton() {
          var buttonView: UIView = UIView()
          let buttonFrame = CGRect(x: -25, y: -25, width: 100, height: 100)
                  
        
              let routerPickerView = AVRoutePickerView(frame: buttonFrame)
              buttonView.addSubview(routerPickerView)
              
              routerPickerView.tintColor = UIColor(named: "PrimaryColor")
              routerPickerView.activeTintColor = .white
              routerPickerView.prioritizesVideoDevices = false
         
          airPlayView.addSubview(routerPickerView)
      }
    
    
    func setNowPlayingArtwork(backgroundNotificationImage: String?) {
      guard let posterURL = URL(string: backgroundNotificationImage ?? "") else{ return }
            URLSession.shared.dataTask(with: posterURL) { data, response, error in
                guard error == nil,
                      let httpResponse = response as? HTTPURLResponse,
                      200 ... 299 ~= httpResponse.statusCode,
                      let imageData = data,
                      let image = UIImage(data: imageData) else { return }
              
                let mediaItemArtwork = MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
                }

                DispatchQueue.main.async {
                    self.poster.image = image
                    self.updateNowPlayingMetadata(key: MPMediaItemPropertyArtwork, value: mediaItemArtwork)
                }
            }.resume()
      }

    func setNowPlayingTitle(title: String?){
      updateNowPlayingMetadata(key: MPMediaItemPropertyTitle, value: title ?? "")
    }
    
    func updateNowPlayingMetadata(key: String, value: Any) {
            nowPlayingInfo[key] = value
            refreshNowPlayingMetadata()
    }
    
    func refreshNowPlayingMetadata() {
      MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { event in
            
            RadioPlayer.sharedInstance.pause()
            return .success
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { event in
            RadioPlayer.sharedInstance.pause()
            return .success
        }
    }
    @IBAction func onSwitch(_ sender: UISwitch) {
        RadioPlayer.sharedInstance.player.allowsExternalPlayback = sender.isOn
    }
    
    @IBAction func onPlayTap(_ sender: Any) {
        playButton.setImage(UIImage(systemName: RadioPlayer.sharedInstance.currentlyPlaying() ? "play.fill" : "pause.fill" ), for: UIControl.State.normal)
        RadioPlayer.sharedInstance.toggle()
    }
}

class RadioPlayer {

  static let sharedInstance = RadioPlayer()

  var player = AVPlayer(playerItem: RadioPlayer.radioPlayerItem())
  var isPlaying = false

  class func radioPlayerItem() -> AVPlayerItem {
      return AVPlayerItem(url: URL(string: "https://live-cdn.sr.se/pool2/p2musik/p2musik.isml/p2musik-audio=192000.m3u8")!)
  }

  func toggle() {
    if isPlaying == true {
      pause()
    } else {
      play()
    }
  }

  func play() {
    player.play()
    isPlaying = true
  }

  func pause() {
    player.pause()
    isPlaying = false
  }

  func currentlyPlaying() -> Bool {
    return isPlaying
  }
}
