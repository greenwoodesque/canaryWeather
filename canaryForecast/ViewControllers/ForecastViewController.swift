//
//  ViewController.swift
//  canaryForecast
//
//  Created by David Greenwood on 5/26/18.
//  Copyright © 2018 David Greenwood. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class ForecastViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var toolbar: UIToolbar!
    let flowLayout = UICollectionViewFlowLayout()

    var location: Location?
    var managedObjectContext: NSManagedObjectContext!
    var viewModel: ForecastViewModel!

    var transitionStartFrame: CGRect?
    var isHistoryView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let onLocationChange: (Location) -> () = { [weak self] location in
            self?.navigationItem.title = location.locality
            self?.setupToolbar(for: location)
            self?.location = location
        }
        
        configureBasicSetup()

        guard !isHistoryView else {
            guard let location = location else { dismiss(animated: true)
                return }
            navigationItem.title = location.locality
            let doneButton = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
            navigationItem.rightBarButtonItem = doneButton
            viewModel = ForecastViewModel(context: managedObjectContext, collectionView: collectionView, location: location, historyView: true, daySelectionDelegate: self, onLocationChange: onLocationChange)
            return
        }
        
        toolbar.isTranslucent = true
        toolbar.barTintColor = UIColor(red: 0.5, green: 0, blue: 0.7, alpha: 0.5)
        toolbar.tintColor = .white
        
        viewModel = ForecastViewModel(context: managedObjectContext, collectionView: collectionView, location: location, historyView: false, daySelectionDelegate: self, onLocationChange: onLocationChange)
        
        let refreshButton = UIBarButtonItem.init(barButtonSystemItem: .refresh, target: viewModel, action: #selector(viewModel.getForecast))
        navigationItem.leftBarButtonItem = refreshButton
        
        let searchButton = UIBarButtonItem.init(barButtonSystemItem: .search, target: self, action: #selector(launchSearch))
        navigationItem.rightBarButtonItem = searchButton
        
        if let location = location {
            setupToolbar(for: location)
        }
    }
    
    func setupToolbar(for newLocation: Location) {
        var items = [UIBarButtonItem]()
        
        if let allLocations = Location.findAll(in: managedObjectContext), allLocations.count > 1 {
            let locationsButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(launchLocationSelection))
            items.append(locationsButton)
        }
        
        if let forecasts = newLocation.forecasts, forecasts.count > 8 {
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            items.append(spacer)
            let historyButton = UIBarButtonItem(title: "History", style: .plain, target: self, action: #selector(launchHistory))
            items.append(historyButton)
        }
        if items.count > 0 {
            toolbar.setItems(items, animated: false)
            toolbar.isHidden = false
        }
        else {
            toolbar.isHidden = true
        }
    }
    
    @objc func launchLocationSelection() {
        let vc = LocationSelectionTableViewController(with: managedObjectContext) { [weak self] newLocation in
            self?.viewModel.switchLocationTo(newLocation: newLocation)
        }
        present(vc, animated: true, completion: nil)
    }
    
    @objc func launchSearch() {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "locationSearchViewController") as? LocationSearchViewController {
            vc.delegate = viewModel
            present(vc, animated: true, completion: nil)
        }
    }
    
    @objc func launchHistory() {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        guard let vc = sb.instantiateViewController(withIdentifier: "forecastViewController") as? ForecastViewController else { return }
        vc.managedObjectContext = managedObjectContext
        vc.isHistoryView = true
        vc.location = location
        let nc = UINavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
    
    @objc func donePressed() {
        dismiss(animated: true, completion: nil)
    }
    
    func configureBasicSetup() {
        navigationController?.delegate = self
        toolbar.isHidden = true
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.5, green: 0, blue: 0.7, alpha: 0.5)
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor : UIColor.white]
        collectionView.allowsSelection = true
        flowLayout.itemSize = CGSize(width: collectionView.bounds.width, height: 100)
        flowLayout.minimumLineSpacing = 1
        collectionView.collectionViewLayout = flowLayout
    }
}

extension ForecastViewController: DaySelectionDelegate {
    func launchSelected(item: Forecast, frame: CGRect) {
        transitionStartFrame = frame
        if let vc = DayDetailViewController.createDayDetailViewController(withItem: item) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ForecastViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let frame = transitionStartFrame else { return nil }
        
        switch operation {
        case .push:
            return TransitionAnimator(duration: 0.2, isPresenting: true, originFrame: frame)
        default:
            return TransitionAnimator(duration: 0.2, isPresenting: false, originFrame: frame)
        }
    }
}
