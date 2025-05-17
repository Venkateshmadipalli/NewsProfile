//
//  SplashViewController.swift
//  NewsProfile
//
//  Created by Apple on 17/05/25.
//

import UIKit
import AVKit
import AVFoundation

class SplashViewController: UIViewController {
    @IBOutlet weak var playerView: UIView!
    private var player: AVPlayer?
    private var playerViewController: AVPlayerViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        playSplashVideo()
    }
    private func playSplashVideo() {
        guard let path = Bundle.main.path(forResource: "splash", ofType: "mp4") else {
            print("Video not found")
            goToMainScreen()
            return
        }

        let url = URL(fileURLWithPath: path)
        player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = playerView.bounds
        playerLayer.videoGravity = .resize
        playerLayer.frame = playerView.bounds

        // Add player layer to your playerView
        playerView.layer.addSublayer(playerLayer)

        // Observe when video ends
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidFinish),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )

        player?.play()
    }
    @objc private func videoDidFinish() {
        goToMainScreen()
    }
    private func goToMainScreen() {
        if UserDefaults.standard.bool(forKey: "AutoLogin"){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            homeVC.modalPresentationStyle = .fullScreen
            self.navigationController?.present(homeVC, animated: false)
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            homeVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(homeVC, animated: true)
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
