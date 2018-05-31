//
//  CollectionViewSource.swift
//  canaryForecast
//
//  Created by David Greenwood on 5/27/18.
//  Copyright © 2018 David Greenwood. All rights reserved.
//

import UIKit

protocol DaySelectionDelegate: class {
    func launchSelected(item: Forecast, frame: CGRect)
}

class CollectionViewSource: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    let forecastCell = "ForecastCell"
    
    private let collectionView: UICollectionView
    var items: [Forecast]
    weak var delegate: DaySelectionDelegate?
    
    init(collectionView: UICollectionView, items: [Forecast], delegate: DaySelectionDelegate) {
        self.collectionView = collectionView
        self.items = items
        self.delegate = delegate
        super.init()

        collectionView.register(UINib(nibName: forecastCell, bundle: nil), forCellWithReuseIdentifier: forecastCell)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: forecastCell, for: indexPath) as? ForecastCell else { fatalError("Unexpected cell type") }
        cell.configure(withItem: items[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var frame: CGRect
        if let attributes = collectionView.layoutAttributesForItem(at: indexPath) {
            frame = collectionView.convert(attributes.frame, to: collectionView.superview)
        }
        else {
            frame = CGRect(origin: collectionView.center, size: CGSize(width: 300, height: 100))
        }
        delegate?.launchSelected(item: items[indexPath.row], frame: frame)
    }
}
