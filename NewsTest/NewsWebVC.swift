//
//  NewsWebVC.swift
//  NewsTest
//
//  Created by Zac Johnson on 1/23/20.
//  Copyright © 2020 Zac Johnson. All rights reserved.
//

import UIKit
import WebKit

class NewsWebVC: UIViewController, WKNavigationDelegate {
	var link: String? {
		didSet {
			titleLabel.text = link
		}
	}
	
	var webView: WKWebView!
	
	let headerView: UIView = {
		let header = UIView()
		header.backgroundColor = .black
		header.usesAutoLayout()
		return header
	}()
	
	let closeButton: UIButton = {
		let btn = UIButton()
		btn.setImage(UIImage(systemName: "xmark"), for: .normal)
		btn.tintColor = .white
		btn.addTarget(self, action: #selector(close(sender:)), for: .touchUpInside)
		return btn
	}()
	
	let refreshButton: UIButton = {
		let btn = UIButton()
		btn.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
		btn.tintColor = .white
		btn.addTarget(self, action: #selector(refresh(sender:)), for: .touchUpInside)
		return btn
	}()
	
	let titleLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .center
		label.textColor = .white
		label.font = .systemFont(ofSize: 14, weight: .regular)
		label.numberOfLines = 1
		return label
	}()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		configureHeader()
		
		webView = WKWebView()
		webView.usesAutoLayout()
		webView.navigationDelegate = self
		
		configureWebView()

		if let urlString = link {
			if let url = URL(string: urlString) {
				webView.load(URLRequest(url: url))
				webView.allowsBackForwardNavigationGestures = true
			}
		}
        // Do any additional setup after loading the view.
    }
	
	func configureHeader() {
		view.addSubview(headerView)
		headerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor)
		headerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
		
		headerView.addSubview(closeButton)
		closeButton.makeSquare(of: 50)
		closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
		closeButton.leadingAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
		
		headerView.addSubview(refreshButton)
		refreshButton.makeSquare(of: 50)
		refreshButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
		refreshButton.trailingAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
		
		headerView.addSubview(titleLabel)
		titleLabel.center(in: headerView)
		titleLabel.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 16).isActive = true
		titleLabel.trailingAnchor.constraint(equalTo: refreshButton.leadingAnchor, constant: -16).isActive = true
		
	}
	
	func configureWebView() {
		view.addSubview(webView)
		webView.anchor(top: headerView.bottomAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
	}
	
	@objc func close(sender: UIButton!) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@objc func refresh(sender: UIButton!) {
		webView.reload()
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
