//
//  PlayerViewController.swift
//  Jammin92
//
//  Created by gitwebmobi on 10/15/17.
//  Copyright © 2017 gitwebmobi All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class Song {
    var title:String?
    var artist:String?
    var album:String?
  
}

enum PlayState {
    case play
    case pause
    case stop
}
private struct Observation {
    static let VolumeKey = "outputVolume"
    static var Context = 0
}
class PlayerViewController: UIViewController {
    var player: AVPlayer!
    //var audioUrlStr:String = "http://s2.stationplaylist.com:7030/listen.aac.m3u"
   
    @IBOutlet var playPauseButton:PlayPauseButton!
    @IBOutlet var volumeSlider:DLSlider!
    @IBOutlet var songTitleLabel:UILabel!
    @IBOutlet var sloganLabel:UILabel!
    @IBOutlet var artistTitleLabel:UILabel!
    @IBOutlet var artworkImageView:UIImageView!
    @IBOutlet var currentTimeLabel:UILabel!
    @IBOutlet var menuButton:UIButton!
    @IBOutlet var totalTimeLabel:UILabel!
    @IBOutlet var progressView:UIProgressView!
    
    var airplayRouteButton: UIButton?
    var volumeView:MPVolumeView?
    var isInitialLoad:Bool = true

    var slogan:String = "Cleveland's Dance Music Station"
    var albumTitle:String?
    var timer:Timer?
    var playerCurrentTime:Double = 0
    var playerTotalTime:Double = 0
    
    var playState:PlayState = .stop{
        didSet{}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSlogan()
        getAlbumTitle()
        isInitialLoad = true
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            do{
                try
                    AVAudioSession.sharedInstance().setActive(true)
                AVAudioSession.sharedInstance().addObserver(self, forKeyPath: Observation.VolumeKey, options: [.initial, .new], context: &Observation.Context)
                
            }catch{
                print(error)
            }
            
        } catch {
            print(error)
        }
        //UIApplication.shared.beginReceivingRemoteControlEvents()
      

       // player?.volume = 1.0
    
        player?.allowsExternalPlayback = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChanged), name: .AVAudioSessionRouteChange, object: nil)
        NotificationCenter.default.addObserver(self,selector:#selector(playInterrupt),name:NSNotification.Name.AVAudioSessionInterruption,object:nil)
        
        // playState = .stop
        //changeButton(state: playState)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.chagePlayState(_:)), name: Notification.Name("ChangePlayState"), object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(playerStalled), name: NSNotification.Name(rawValue: AVPlayerItemFailedToPlayToEndTimeErrorKey) , object: player.currentItem)
        //AVPlayerItemPlaybackStalledNotification
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.updateTimer(_:)), name: Notification.Name("UpdateTimer"), object: nil)
    }
    
   
    private func airPlayButton() -> UIButton {

        let wrapperView = UIButton(frame: .zero)
        
        wrapperView.setImage(UIImage.init(named: "airplay"), for: .normal)
        //wrapperView.setBackgroundImage(UIImage.init(named: "airplay"), for: .normal)
        wrapperView.tintColor = UIColor.white
        wrapperView.backgroundColor = .clear
        wrapperView.addTarget(self, action: #selector(PlayerViewController.replaceRouteButton), for: .touchUpInside)
        wrapperView.imageEdgeInsets = UIEdgeInsetsMake(4, 0, 4, 0)
        
        let volumeView = MPVolumeView(frame: wrapperView.bounds)
        volumeView.showsVolumeSlider = false
        volumeView.showsRouteButton = false
        volumeView.isUserInteractionEnabled = false
        
        self.airplayRouteButton = volumeView.subviews.filter { $0 is UIButton }.first as? UIButton
        
        wrapperView.addSubview(volumeView)
        
        return wrapperView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let volume = AVAudioSession.sharedInstance().outputVolume
        volumeSlider.value = volume
        
        let airplayRouteButton1 = airPlayButton()
        self.view.addSubview(airplayRouteButton1)
        //airplayRouteButton?.autoPinEdge(toSuperviewEdge: .top, withInset: 23)
        
        airplayRouteButton1.autoSetDimensions(to: CGSize.init(width: 30, height: 30))
        airplayRouteButton1.autoAlignAxis(.horizontal, toSameAxisOf: self.menuButton)
        airplayRouteButton1.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
/*
     NotificationCenter.default.addObserver(self,selector: #selector(systemVolumeDidChange),name: NSNotification.Name(rawValue:"AVSystemController_SystemVolumeDidChangeNotification"),object: nil)
        */
        setupNowPlayingInfoCenter()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.endReceivingRemoteControlEvents()
        self.resignFirstResponder()
          NotificationCenter.default.removeObserver(self)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()

    }
    @objc private func replaceRouteButton() {
        airplayRouteButton?.sendActions(for: .touchUpInside)
    }
    
    @IBAction func menuButtonAction(sender:UIButton){
        self.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
   
    @IBAction func volumeChange(sender:UISlider){
  (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(sender.value, animated: false)
        
    }

    @IBAction func playPauseButtonAction(sender:UIButton){
        
        switch playState {
        case .stop:
            
            self.initializePlay()
            changeButton(state: PlayState.play)
            
        case .pause:
            self.play()
            changeButton(state: PlayState.play)
            
        case .play:
            self.pause()
            changeButton(state: PlayState.pause)
        }
    }
    
    @objc func chagePlayState(_ notification:Notification){
        let dict = notification.object as! NSDictionary
        let state = dict["State"] as! PlayState
        changeButton(state: state)
    }
    
    func changeButton(state:PlayState)  {
       
        switch state {
        case .stop:
            playPauseButton?.btnState = .play
        case .play:
            playPauseButton?.btnState = .stop
            
        case .pause:
            playPauseButton?.btnState = .play
        }
    }
    
    @IBAction func share(sender:UIButton){
        var shareT:String = ""
        if let title = songTitleLabel.text{
            shareT = title
        }
        if let art = artistTitleLabel.text{
            shareT = shareT + art
        }
        let shareText = shareT
        
        let activityController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        /* if UIDevice.current.userInterfaceIdiom == .pad {
         let popoverController = UIPopoverController(contentViewController: activityController)
         popoverController.present(from: sender, permittedArrowDirections: .any
         , animated: true)
         } else {
         */
        self.present(activityController, animated: true, completion: nil)
        // }
    }
}

extension PlayerViewController{
    
    func initializePlay() {
        let appdeleage:AppDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        let url = URL.init(string:appdeleage.audioUrlStr)
        player = AVPlayer(url:url!)
        
       // player.volume = 1.0
       // player.rate = 1.0
        player.play()
        postStateChange(playState)

       // playState = .play
  
       // player.currentItem?.addObserver(self, forKeyPath: "timedMetadata", options: [], context: nil)

       // postStateChange(playState)
     
        //DL
       // timer?.invalidate()
      //  timer = Timer.scheduledTimer(timeInterval: 1.0, target: self,   selector: (#selector(PlayerViewController.updateTimer(_:))), userInfo: nil, repeats: true)
        
        /*
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        */
    }
    
    func play() {
        if let plyr = self.player{
            
            plyr.play()
            playState = .play
            postStateChange(playState)
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.isInitialLoad ? 0:self.playerCurrentTime
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = self.isInitialLoad ? 0 : (self.playerTotalTime - self.playerCurrentTime)
        }
        else{
            initializePlay()
        }
       // timer?.invalidate()

       // timer = Timer.scheduledTimer(timeInterval: 1.0, target: self,   selector: (#selector(PlayerViewController.updateTimer(_:))), userInfo: nil, repeats: true)

    }
    
    func pause() {
        player.pause()
        playState = .pause
        postStateChange(playState)
    }
    
    func playerItemDidReachEnd() {
        player?.seek(to: kCMTimeZero)
        player?.play()
    }

    func postStateChange(_ state: PlayState){
        
        let dict = ["State":state] as NSDictionary
        NotificationCenter.default.post(name: Notification.Name("ChangePlayState"), object: dict)
    }
   
    override func remoteControlReceived(with event:UIEvent?)  {
        guard let revent = event else{return}
        if (revent.type == .remoteControl) {
            switch revent.subtype {
            case .remoteControlTogglePlayPause:
                if player.rate > 0.0 {
                    pause()
                } else {
                    play()
                }
            case .remoteControlPlay:
                play()
            case .remoteControlPause:
                pause()
            default:
                print("received sub type \(revent.subtype) Ignoring")
            }
        }
    }
}

extension PlayerViewController{
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timedMetadata" {
            let data: AVPlayerItem = object as! AVPlayerItem
            guard let datai:[AVMetadataItem] = data.timedMetadata else {
                return
            }
            self.updateMetaData(datai)
        }
        else if keyPath == "status"{
            if (self.player.status == .readyToPlay) {
                print("Ready to play")
                
                self.playState = .play
                //timer?.invalidate()

                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self,   selector: (#selector(PlayerViewController.updateTimer(_:))), userInfo: nil, repeats: true)

                self.postStateChange(PlayState.play)
            }
        }
        else if keyPath == Observation.VolumeKey{
            if context == &Observation.Context {
                
                let volume = (change?[NSKeyValueChangeKey.newKey] as!
                    NSNumber).floatValue
                print("volume " + volume.description)
                volumeSlider.value = volume
            } else {
               
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
        }
    }
    
    @objc func audioRouteChanged(note: Notification) {
        if let userInfo = note.userInfo {
            if let reason = userInfo[AVAudioSessionRouteChangeReasonKey] as? Int {
                if reason == AVAudioSessionRouteChangeReason.oldDeviceUnavailable.hashValue {
                    // headphones plugged out
                    //player.play()
                    self.play()
                }
            }
        }
    }
    
    @objc func playInterrupt(notification: NSNotification) {
        guard let info = notification.userInfo else {return}
        var intValue: UInt = 0
        (info[AVAudioSessionInterruptionTypeKey] as! NSValue).getValue(&intValue)
        if let type = AVAudioSessionInterruptionType(rawValue: intValue) {
            switch type {
            case .began:
                self.pause()
               // player.pause()
                
            case .ended:
                _ = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(resumeNow(_:)), userInfo: nil, repeats: false)
            }
        }
    }
    
    @objc func resumeNow(_ timer: Timer) {
        self.play()
        //player.play()
    }
    
    func updateMetaData(_ datai:[AVMetadataItem]) {
        for item:AVMetadataItem in datai {
            if let song:String = item.value as? String{
                
                let songArtist = song.getSongAuthor()
                let songTitle = song.getSongTitle()
                let totalDuration = song.getSongDuration()
                print("song:\(song)")
                let appd:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                
                if appd.isInitialLoad{
                    appd.isInitialLoad = false
                }
                else{
                    isInitialLoad = false
                }

                playerCurrentTime = 0
                playerTotalTime = Double(totalDuration)
                songTitleLabel?.text = songTitle
                artistTitleLabel?.text = songArtist
                
                //stationAlbumArt
                let artImage = UIImage(named: "artworks")!
                
                var artwork:MPMediaItemArtwork = MPMediaItemArtwork.init(image: artImage)
                
               // var artImage = UIImage.init(data: item.dataValue!)
                if #available(iOS 10.0, *) {
                    artwork = MPMediaItemArtwork.init(boundsSize: CGSize.init(width: 60, height: 60), requestHandler: { (size) -> UIImage in
                        return UIImage(named: "artworks")!
                    })
                } else {
                }
              
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
               // artworkImageView.image =  artImage
                
               self.getAlbumTitle()
                self.getSlogan()

                
                var albumTitle:String = "Jammin' 92"
                if let at = self.albumTitle, !at.isEmpty{
                    albumTitle = "\(albumTitle) - \(at)"
                }
                MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: songTitle, MPMediaItemPropertyArtist: songArtist,MPMediaItemPropertyArtwork:artwork, MPMediaItemPropertyAlbumTitle:albumTitle,MPNowPlayingInfoPropertyElapsedPlaybackTime: isInitialLoad ?0:playerCurrentTime,MPMediaItemPropertyPlaybackDuration: isInitialLoad ?0:playerTotalTime]
            }
        }
    }
    
    private func setupNowPlayingInfoCenter() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        MPRemoteCommandCenter.shared().playCommand.addTarget {event in
            self.play()
            
            
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget {event in
            self.pause()
            return .success
        }
    }
}

extension String{
    func getSongAuthor()-> String  {
        let songArray = self.components(separatedBy: " - ")
        if songArray.count >= 2{
            let soa:NSMutableArray = NSMutableArray(array: songArray)
            soa.removeObject(at: 0)
            soa.removeObject(at: 1)
            return soa.componentsJoined(by: "")
        }
        
        let songAray = self.components(separatedBy: "/")
        if songAray.count >= 2{
            let sona:NSMutableArray = NSMutableArray(array: songAray)
            sona.removeObject(at: 0)
            sona.removeObject(at: 1)
            return sona.componentsJoined(by: "")
        }
        return ""
    }
    func getSongTitle()->String {
         let songa = self.components(separatedBy: " - ")
        if songa.count > 1{
            return songa.first ?? ""
        }
        else {
           let songar = self.components(separatedBy: "/")
            if songar.count > 1{
                return songar.first ?? ""
            }
        }
        return ""
    }
    
    func getSongDuration()->Int {
        var duration = 0
        var durationStr:String?
        let songa = self.components(separatedBy: " - ")
        if songa.count >= 2{
            durationStr = songa.last
        }
        else {
            let songar = self.components(separatedBy: "/")
            if songar.count >= 2{
                durationStr = songar.last
            }
        }
        if let dur = durationStr{
            let durationArray = dur.components(separatedBy: ":")
            if durationArray.count == 3{
                let hour = durationArray[0]
                    if let hourInt = Int(hour){
                      duration = hourInt * 3600
                    }
                let min = durationArray[1]
                if let minInt = Int(min){
                    duration = duration + (minInt * 60)
                }
            
                let sec = durationArray[2]
                if let secInt = Int(sec){
                    duration = duration + secInt
                }
            }
            else if durationArray.count == 2{
                let min = durationArray[0]
                if let minInt = Int(min){
                    duration = duration + (minInt * 60)
                }
                
                let sec = durationArray[1].trimmingCharacters(in: .whitespaces)
                if let secInt = Int(sec){
                    duration = duration + secInt
                }
            }
        }
        return duration
    }
}

extension PlayerViewController{
    func postTimerUpdate()  {
        NotificationCenter.default.post(name: Notification.Name("UpdateTimer"), object: nil)
    }
    
    @objc func updateTimer(_ notification:Timer){
        playerCurrentTime = playerCurrentTime + 1

        updateProgressLabel()
        updateSlider()
    }
    func updateProgressLabel()  {
      
        switch playState {
        case .stop:
            print("stop")
        case .play:
            //let appd:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            if isInitialLoad {
                currentTimeLabel?.text = "__:__"
            }
            else{
                if playerCurrentTime > 0{
                    currentTimeLabel?.text = formatTimeFor(seconds: playerCurrentTime)
                }
                else{
                    currentTimeLabel?.text = "__:__"
                }
            }
        case .pause:
            currentTimeLabel?.text = "__:__"
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.isInitialLoad ? 0:self.playerCurrentTime
          //  MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = self.isInitialLoad ? 0 : (self.playerTotalTime - self.playerCurrentTime)
            
            print("pasue")
        }
        
        if playerTotalTime > 0{
            totalTimeLabel?.text = formatTimeFor(seconds: playerTotalTime)
        }
        else{
            totalTimeLabel?.text = "__:__"
        }
    }
    func updateSlider(isInitial:Bool=false) {
        
       // let appd:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        switch playState {
        case .stop:
            print("stop")
        case .play:
            print("play")
            
            if isInitialLoad{
                self.progressView.progress = 1
            }
            else{
                self.progressView.progress = Float(playerCurrentTime/playerTotalTime)
            }
        case .pause:
            print("pause")
        }
    }
    
    func getHoursMinutesSecondsFrom(seconds: Double) -> (hours: Int, minutes: Int, seconds: Int) {
        let secs = Int(seconds)
        let hours = secs / 3600
        let minutes = (secs % 3600) / 60
        let seconds = (secs % 3600) % 60
        return (hours, minutes, seconds)
    }
    
    func formatTimeFor(seconds: Double) -> String {
        let result = getHoursMinutesSecondsFrom(seconds: seconds)
        let hoursString = "\(result.hours)"
        var minutesString = "\(result.minutes)"
        if minutesString.characters.count == 1 {
            minutesString = "0\(result.minutes)"
        }
        var secondsString = "\(result.seconds)"
        if secondsString.characters.count == 1 {
            secondsString = "0\(result.seconds)"
        }
        var time = "\(hoursString):"
        if result.hours >= 1 {
            time.append("\(minutesString):\(secondsString)")
        }
        else {
            time = "\(minutesString):\(secondsString)"
        }
        return time
    }
}


extension PlayerViewController{
    func getSlogan() {
        let url = URL(string: "http://jammin92.com/config/slogan.txt")
        
        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            
            guard let data = data, error == nil else { return }
            
            if let strVal = String.init(data: data, encoding: .utf8){
                self.slogan = strVal
                
               // DispatchQueue.main.async {
                    self.sloganLabel.text = strVal
               // }
            }
        }
        
        task.resume()
    }
    
    func getAlbumTitle() {
        let url = URL(string: "http://jammin92.com/config/inappalbumtitle.txt")
        
        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            
            guard let data = data, error == nil else { return }
            
            if let strVal = String.init(data: data, encoding: .utf8){
                
                DispatchQueue.main.async {
                    self.albumTitle = strVal

                    var albumTitle:String = "Jammin' 92"
                    if let at = self.albumTitle, !at.isEmpty{
                        albumTitle = "\(albumTitle) - \(at)"
                    }
                    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyAlbumTitle] = albumTitle

                }
            }
        }
        
        task.resume()
    }
}
