//
//  ViewController.swift
//  PitchPlease
//
//  Created by David Park on 6/14/16.
//  Copyright © 2016 David Park. All rights reserved.
//

import UIKit
import AVFoundation

var engine: AVAudioEngine!
var playerA: AVAudioPlayerNode!                     //reverb
var playerB: AVAudioPlayerNode!                     //distortion
var playerC: AVAudioPlayerNode!                     //normal

class ViewController: UIViewController {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var sliderReverb: UISlider!
    @IBOutlet weak var sliderDistortion: UISlider!

    @IBAction func playButtonTapped(sender: AnyObject) {
        playerA.play()
        playerB.play()
        playerC.play()
        print("play tapped")
        togglePlayPauseHidden()
        playButton.enabled = false
        pauseButton.enabled = true
    }
    
    @IBAction func pauseButtonTapped(sender: AnyObject) {
        playerA.pause()
        playerB.pause()
        playerC.pause()
        print("pause tapped")
        togglePlayPauseHidden()
        playButton.enabled = true
        pauseButton.enabled = false
    }
    
    @IBAction func sliderChanged(sender: UISlider) {
        playerA.volume = sender.value * 2.1
        playerB.volume = sliderDistortion.value
        playerC.volume = 1 - sliderDistortion.value - sliderReverb.value
        print("slider moved")
        print(playerA.volume)
        print(playerC.volume)
    }
    
    @IBAction func sliderTwoChanged(sender: UISlider) {
        playerB.volume = sender.value * 0.8
        playerA.volume = sliderReverb.value
        playerC.volume = 1 - sliderDistortion.value - sliderReverb.value
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        engine = AVAudioEngine()
        playerA = AVAudioPlayerNode()
        playerB = AVAudioPlayerNode()
        playerC = AVAudioPlayerNode()
        playerA.volume = 0.0
        playerB.volume = 0.0
        playerC.volume = 1.0

        
        let path = NSBundle.mainBundle().pathForResource("Galantis - Runaway (U & I)", ofType: "mp3")!
        let url = NSURL.fileURLWithPath(path)

        let file = try? AVAudioFile(forReading: url)
        let buffer = AVAudioPCMBuffer(PCMFormat: file!.processingFormat, frameCapacity: AVAudioFrameCount(file!.length))
        try! file!.readIntoBuffer(buffer)
        
        let reverb = AVAudioUnitReverb()
        reverb.loadFactoryPreset(AVAudioUnitReverbPreset.LargeHall)
        reverb.wetDryMix = 100
        
        let distortion = AVAudioUnitDistortion()
        distortion.loadFactoryPreset(AVAudioUnitDistortionPreset.DrumsLoFi)
        distortion.wetDryMix = 80
        
        let normal = AVAudioUnitReverb()
        normal.loadFactoryPreset(AVAudioUnitReverbPreset.LargeHall)
        normal.wetDryMix = 0
        
        engine.attachNode(playerA)
        engine.attachNode(playerB)
        engine.attachNode(playerC)
        engine.attachNode(reverb)
        engine.attachNode(distortion)
        engine.attachNode(normal)
        
        engine.connect(playerA, to:reverb, format: buffer.format)
        engine.connect(reverb, to:engine.mainMixerNode, format: buffer.format)
        engine.connect(playerB, to: distortion, format: buffer.format)
        engine.connect(distortion, to: engine.mainMixerNode, format:buffer.format)
        engine.connect(playerC, to:normal, format: buffer.format)
        engine.connect(normal, to:engine.mainMixerNode, format:buffer.format)
        
        playerA.scheduleBuffer(buffer, atTime:nil, options:AVAudioPlayerNodeBufferOptions.Loops, completionHandler: nil)
        playerB.scheduleBuffer(buffer, atTime:nil, options: AVAudioPlayerNodeBufferOptions.Loops, completionHandler: nil)
        playerC.scheduleBuffer(buffer, atTime:nil, options: AVAudioPlayerNodeBufferOptions.Loops, completionHandler: nil)
        
        engine.prepare()
        try! engine.start()
    }
    
    func togglePlayPauseHidden() {
        pauseButton.hidden = !pauseButton.hidden
        playButton.hidden = !playButton.hidden
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}