//
//  ViewController.swift
//  NewsTest
//
//  Created by Zac Johnson on 1/2/20.
//  Copyright © 2020 Zac Johnson. All rights reserved.
//

import UIKit
import CloudKit

enum Site {
	case octane
	case rocketeers
	case twitch
}

class ViewController: UIViewController {
    
    var articles = [Article]()
    var octaneArticles = [OctaneArticle]()
    var players = [Player]()
    static var isDirty = true
    var settings = Settings()
    var livePlayers = [Streamer]()
    
    let publicDB = CKContainer(identifier: "iCloud.zacjohnson.news-test").publicCloudDatabase
	
	var sections: [Section] = [
		SectionTitleSection(title: "Rocketeers.gg"),
		RocketeersSection(),
		SectionTitleSection(title: "Octane.gg"),
		OctaneSection(),
        SectionTitleSection(title: "Who's Live"),
        TwitchSection()
	]
	
	 lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .systemBackground
		collectionView.showsVerticalScrollIndicator = false
		collectionView.isPrefetchingEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
		
		collectionView.register(SectionTitleCell.self, forCellWithReuseIdentifier: SectionTitleCell.defaultReuseIdentifier)
		collectionView.register(RocketeersCell.self, forCellWithReuseIdentifier: RocketeersCell.defaultReuseIdentifier)
		collectionView.register(BlankRocketeersCell.self, forCellWithReuseIdentifier: BlankRocketeersCell.defaultReuseIdentifier)
		collectionView.register(OctaneCell.self, forCellWithReuseIdentifier: OctaneCell.defaultReuseIdentifier)
		collectionView.register(BlankOctaneCell.self, forCellWithReuseIdentifier: BlankOctaneCell.defaultReuseIdentifier)
		collectionView.register(TwitchCell.self, forCellWithReuseIdentifier: TwitchCell.defaultReuseIdentifier)
		
		collectionView.usesAutoLayout()
        
        return collectionView
    }()
	
	lazy var collectionViewLayout: UICollectionViewLayout = {
        var sections = self.sections
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            return sections[sectionIndex].layoutSection()
        }
        return layout
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupCollectionView()
        
        
        DispatchQueue.global().async {
            self.getRocketeersArticles()
            self.getOctaneArticles()
        }
        
        getPlayers()
        
        
    }
    
    func setupCollectionView() {
		view.addSubview(collectionView)
		
		collectionView.fillSuperview()
		
    }
	
	override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 13.0, *) {
            // Workaround for incorrect initial offset by `.groupPagingCentered`
            collectionView.reloadData()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if #available(iOS 13.0, *) {
            // Workaround for incorrect initial offset by `.groupPagingCentered`
            collectionView.reloadData()
        }
    }
    
    func getRocketeersArticles() {
        // https://medium.com/flawless-app-stories/writing-network-layer-in-swift-protocol-oriented-approach-4fa40ef1f908
		articles.removeAll()
		
			let urlString = "https://rocketeers.gg/wp-json/wp/v2/posts?per_page=5&_embed"
			
			if let url = URL(string: urlString) {
				if let data = try? Data(contentsOf: url) {
                    let responseString = String(data: data, encoding: .utf8)
                    print("❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️ - \(responseString)")
					self.parse(json: data, from: .rocketeers)
					return
				}
			}
		
    }
	
	func getOctaneArticles() {
		octaneArticles.removeAll()
		
			let urlString = "https://api.octane.gg/api/news_section"
			
			if let url = URL(string: urlString) {
				if let data = try? Data(contentsOf: url) {
					self.parse(json: data, from: .octane)
					return
				}
			}
		
	}

    func parse(json: Data, from site: Site) {
        let decoder = JSONDecoder()
        
        if site == .rocketeers {
            //decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let jsonArticles = try decoder.decode(Articles.self, from: json)
                articles = jsonArticles
                var section = sections[1] as! RocketeersSection
                section.articles = articles
                sections[1] = section
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
        } else if site == .octane {
            if let jsonArticles = try? decoder.decode(OctaneArticles.self, from: json) {
                octaneArticles = jsonArticles.data
				var section = sections[3] as! OctaneSection
				section.articles = octaneArticles
				sections[3] = section
            }
		} else if site == .twitch {
			if let jsonStreamers = try? decoder.decode(Streamers.self, from: json) {
				livePlayers = jsonStreamers.data
				var section = sections[5] as! TwitchSection
				section.streamers = livePlayers
				sections[5] = section
			}
		}
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
		
    }
    
    private func getClientID() {
        var zoneID: CKRecordZone.ID = CKRecordZone.ID()
        
        publicDB.fetchAllRecordZones { (zones, error) in
            if let zones = zones {
                zoneID = zones.first!.zoneID
            }
        }
        let pred = NSPredicate(value: true)
        //let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        let query = CKQuery(recordType: "Settings", predicate: pred)
        //query.sortDescriptors = [sort]
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["twitchClientID"]
        operation.resultsLimit = 1
        operation.zoneID = zoneID
        
        var newSettings = Settings()
        
        operation.recordFetchedBlock = { record in
            let settings = Settings()
            settings.twitchClientID = record["twitchClientID"]!
            newSettings = settings
        }
        
        operation.queryCompletionBlock = { [unowned self] (cursor, error) in
            DispatchQueue.main.async {
                if error == nil {
                    self.settings = newSettings
                    print(self.settings.twitchClientID)
                    self.getLivePlayers(from: self.players, withID: self.settings.twitchClientID)
                } else {
                    let ac = UIAlertController(title: "Fetch Failed", message: "There was an error fetching from CK: \(error!.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
    
        CKContainer(identifier: "iCloud.zacjohnson.news-test").publicCloudDatabase.add(operation)
    }
    
    private func getPlayers() {
		players.removeAll()
		livePlayers.removeAll()
        var zoneID: CKRecordZone.ID = CKRecordZone.ID()
        
        publicDB.fetchAllRecordZones { (zones, error) in
            if let zones = zones {
				print(zones)
                zoneID = zones.first!.zoneID
            }
        }
        
        let pred = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "twitchName", ascending: false)
        let query = CKQuery(recordType: "Player", predicate: pred)
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["id", "twitchName"]
        operation.resultsLimit = 50
        operation.zoneID = zoneID
        
        print(CKRecordZone.default().zoneID)
        
        var newPlayers = [Player]()
        
        operation.recordFetchedBlock = { record in
            let player = Player()
            player.recordID = record.recordID
            player.id = record["id"]
            player.twitchName = record["twitchName"]
            newPlayers.append(player)
        }
        
        operation.queryCompletionBlock = { [unowned self] (cursor, error) in
            DispatchQueue.main.async {
                if error == nil {
                    ViewController.isDirty = false
                    self.players = newPlayers
                    self.getClientID()
                } else {
                    let ac = UIAlertController(title: "Player Fetch Failed", message: "There was an error fetching from CK: \(error!.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
        
        CKContainer(identifier: "iCloud.zacjohnson.news-test").publicCloudDatabase.add(operation)
    }
    
    private func getLivePlayers(from: [Player], withID id: String) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.twitch.tv"
        components.path = "/helix/streams"
        
        var queryItems = [URLQueryItem]()
        for player in players {
            queryItems.append(URLQueryItem(name: "user_login", value: player.twitchName))
        }
        components.queryItems = queryItems
                
        var request = URLRequest(url: components.url!)
        
        request.setValue(id, forHTTPHeaderField: "Client-ID")
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let _ = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
			if let data = data {
			    if let jsonString = String(data: data, encoding: .utf8) {
                    print("🧡🧡🧡🧡🧡🧡🧡🧡🧡🧡 - \(jsonString)")
				    self.parse(json: data, from: .twitch)
			    }
			}
			else {
                print("Error: \(String(describing: error))")
            }
		}.resume()
        
        
    }

}

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return sections[indexPath.section].configureCell(collectionView: collectionView, indexPath: indexPath)
    }
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let controller = NewsWebVC()
		controller.link = sections[indexPath.section].handleSelection(collectionView: collectionView, indexPath: indexPath)
		present(controller, animated: true, completion: nil)
	}
}
