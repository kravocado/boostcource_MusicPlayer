//
//  ViewController.swift
//  BC_MusicPlayer
//
//  Created by SeoDongyeon on 2021/10/16.
//

import UIKit
import SnapKit
import AVFoundation


class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    var player: AVAudioPlayer!
    var timer: Timer!
    
    var playAndPauseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "button_play"), for: .normal)
        button.setImage(UIImage(named: "button_pause"), for: .selected)
        button.addTarget(self, action: #selector(touchUpPlayPauseButton), for: .touchUpInside)
        return button
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.text = "00:00:00"
        label.textColor = UIColor.black
        return label
    }()
    
    var progressSlider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = .red
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        return slider
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        constraintSetup()
        initializePlayer()
    }
    
    func initializePlayer() {
        guard let soundAsset: NSDataAsset = NSDataAsset(name: "sound") else {
            print("음원 파일 에셋을 가져올 수 없습니다")
            return
        }
        do {
            try player = AVAudioPlayer(data: soundAsset.data)
            player.delegate = self
        } catch let error as NSError {
            print("플레이어 초기화 실패")
            print("코드 : \(error.code), 메세지 : \(error.localizedDescription)")
        }
        
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = Float(player.duration)
        progressSlider.value = Float(player.currentTime)
    }
    
    func updateTimeLabelText(time: TimeInterval) {
        let minute: Int = Int(time / 60)
        let second: Int = Int(time.truncatingRemainder(dividingBy: 60))
        let milisecond: Int = Int(time.truncatingRemainder(dividingBy: 1) * 100)
        
        let timeText: String = String(format: "%02ld:%02ld:%02ld", minute, second, milisecond)
        
        timeLabel.text = timeText
    }
    
    func makeAndFireTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [unowned self] (timer: Timer) in
            if progressSlider.isTracking { return }
            
            updateTimeLabelText(time: player.currentTime)
            progressSlider.value = Float(player.currentTime)
        })
        timer.fire()
    }
    
    func invalidateTimer() {
        timer.invalidate()
        timer = nil
    }
    
    
    func constraintSetup() {
        view.addSubview(playAndPauseButton)
        playAndPauseButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.7)
            make.width.equalTo(view.snp.width).multipliedBy(0.3)
            make.height.equalTo(playAndPauseButton.snp.width).multipliedBy(1)
        }
        
        view.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(playAndPauseButton.snp.bottom).offset(10)
        }
        
        view.addSubview(progressSlider)
        progressSlider.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(timeLabel.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(30)
        }
    }
    
    @objc func touchUpPlayPauseButton(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            player?.play()
        } else {
            player?.pause()
        }
        
        if sender.isSelected {
            makeAndFireTimer()
        } else {
            invalidateTimer()
        }
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        updateTimeLabelText(time: TimeInterval(sender.value))
        if sender.isTracking { return }
        player.currentTime = TimeInterval(sender.value)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        guard let error: Error = error else {
            print("오디오 플레이어 디코드 오류 발생")
            return
        }
        
        let message: String
        message = "오디오 플레이어 오류 발생 \(error.localizedDescription)"
        
        let alert: UIAlertController = UIAlertController(title: "알림", message: message, preferredStyle: UIAlertController.Style.alert)
        
        let okAction: UIAlertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { (action: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playAndPauseButton.isSelected = false
        progressSlider.value = 0
        updateTimeLabelText(time: 0)
        invalidateTimer()
    }
}

