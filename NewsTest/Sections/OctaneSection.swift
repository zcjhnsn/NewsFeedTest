//
//  OctaneSection.swift
//  NewsTest
//
//  Created by Zac Johnson on 1/23/20.
//  Copyright © 2020 Zac Johnson. All rights reserved.
//

import UIKit

struct OctaneSection: Section {
	var numberOfItems: Int = 11
	
	var articles: [OctaneArticle]? {
        didSet {
            guard let articles = articles else { return }
			numberOfItems = articles.count
        }
    }
	

    func layoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.92), heightDimension: .fractionalHeight(0.35))
//		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.92), heightDimension: .absolute(300))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered

        return section
    }

    func configureCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
		if let articles = articles {
			if indexPath.row == articles.count - 1 {
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BlankOctaneCell.defaultReuseIdentifier, for: indexPath) as! BlankOctaneCell
				return cell
			} else {
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OctaneCell.defaultReuseIdentifier, for: indexPath) as! OctaneCell
				cell.article = articles[indexPath.item]
                var splitURL = articles[indexPath.item].image.components(separatedBy: ".jpg")
                let url = splitURL[0] + "l.jpg"
				cell.bg.loadImageFromCacheWithUrlString(urlString: url, withPlaceholder: "octane")
				return cell
			}
		} else {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BlankOctaneCell.defaultReuseIdentifier, for: indexPath) as! BlankOctaneCell
	
			return cell
		}
    }
	
	func handleSelection(collectionView: UICollectionView, indexPath: IndexPath) -> String {
		return "https://octane.gg"
	}
}

