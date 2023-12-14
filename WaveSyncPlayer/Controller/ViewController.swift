//
//  ViewController.swift
//  WaveSyncPlayer
//
//  Created by iPHTech 15 on 28/11/23.
//

import UIKit
import AVFoundation
import DSWaveformImageViews
import DSWaveformImage

class ViewController: UIViewController, AVAudioRecorderDelegate, WaveformRenderer {
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var waveForm: WaveformLiveView!
    
    let waveformView = WaveformLiveView()
    var player: AVAudioPlayer?
    private let waveformImageDrawer = WaveformImageDrawer()
    private let audioURL = Bundle.main.url(forResource: "audio", withExtension: "mp3")!
    private var timer: Timer?
    var buttonState:Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        let randomInt = Int.random(in: 5..<7)
    }
    
    func updateWaveformWithAudio() {
            // Create a timer that fires every 0.01 seconds
             timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
                self?.updateWaveform()
            }
        }
    
    func updateWaveform() {
            guard let player = player else {
                return
            }
            player.isMeteringEnabled = true
            player.updateMeters()
            let currentAmplitude = 1 - pow(10, player.averagePower(forChannel: 0) / 20)
            print("currentAmplitude = \(currentAmplitude)")
            waveForm.configuration = Waveform.Configuration(
                style: .striped(.init(color: UIColor.stripeColor(), width: 5, spacing: 5)),
                
                damping: .init(percentage: 0.2, sides: .both, easing: { x in pow(x, 4) }),
                verticalScalingFactor: CGFloat(Double.random(in: 0.4..<0.7))
        )
           waveForm.add(sample: currentAmplitude)
        }
    
    @IBAction func playAction(_ sender: UIButton) {
        buttonState = !buttonState
            if buttonState {
                playPauseButton.setImage(UIImage(named: "playButton"), for: .normal)
            } else {
                playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            }
        if let player = player, player.isPlaying{
            //stop playing
            player.stop()
            timer?.invalidate()
        } else {
            // start playing
            let urlString = Bundle.main.path(forResource: "audio", ofType: "mp3")
            do {
                try AVAudioSession.sharedInstance().setMode(.default)
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                
                guard let urlString = urlString else{
                    return
                }
                player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlString))
                guard let player = player else{
                    return
                }
                player.numberOfLoops =  -1
                player.play()
                updateWaveformWithAudio()
            }
            catch {
                print("some error occurred")
            }
        }
    }
}

