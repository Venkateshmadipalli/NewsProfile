//
//  HomeViewController.swift
//  NewsProfile
//
//  Created by Apple on 16/05/25.
//

import UIKit
class HomeViewController: UIViewController {
    @IBOutlet weak var sigment: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    var news: NewsPagingViewController?
    var search: SearchViewController?
    var profile: ProfileViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        setupChildViewControllers()
        updateContainer(index: sigment.selectedSegmentIndex)
        sigment.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
    }
    
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        updateContainer(index: sender.selectedSegmentIndex)
    }

    private func setupChildViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let newsVC = storyboard.instantiateViewController(withIdentifier: "NewsPagingViewController") as? NewsPagingViewController {
            news = newsVC
            addChild(newsVC)
            newsVC.view.frame = containerView.bounds
            containerView.addSubview(newsVC.view)
            newsVC.didMove(toParent: self)
        }

        if let searchVC = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController {
            search = searchVC
            addChild(searchVC)
            searchVC.view.frame = containerView.bounds
            containerView.addSubview(searchVC.view)
            searchVC.didMove(toParent: self)
        }

        if let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
            profile = profileVC
            addChild(profileVC)
            profileVC.view.frame = containerView.bounds
            containerView.addSubview(profileVC.view)
            profileVC.didMove(toParent: self)
        }
    }
    private func updateContainer(index: Int) {
        news?.view.isHidden = index != 0
        search?.view.isHidden = index != 1
        profile?.view.isHidden = index != 2
    }
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

