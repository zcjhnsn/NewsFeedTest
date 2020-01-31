//
//  Section.swift
//  NewsTest
//
//  Created by Zac Johnson on 1/22/20.
//  Copyright © 2020 Zac Johnson. All rights reserved.
//

import UIKit

protocol Section {
    var numberOfItems: Int { get }
    func layoutSection() -> NSCollectionLayoutSection
	func configureCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell
	func handleSelection(collectionView: UICollectionView, indexPath: IndexPath) -> String
}

enum Identifiers: String {
	case blankRocketeersCell
	case rocketeersCell
	case sectionTitleCell
}
