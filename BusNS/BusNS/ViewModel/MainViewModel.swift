//
//  MainViewModel.swift
//  BusNS
//
//  Created by Mariana Samardzic on 14/11/2019.
//  Copyright © 2019 Crystal Pigeon. All rights reserved.
//

import Foundation

protocol  MainObserver {
    func refreshUI()
    func showError(message: String)
}

class MainViewModel {
    public var observer: MainObserver?
    
    public private(set) var currentSeason: Season?
    public private(set) var urbanLines = [Line]()
    public private(set) var suburbanLines = [Line]()
    public var favorites: [String] {
        return BusManager.favorites
    }
    public let tagsDict = [0:"R", 1: "S", 2: "N"]
    private var lastCount = BusManager.favorites.count
    
    init(){}
    
    public func resetLastCount() {
        lastCount = BusManager.favorites.count
    }
    
    public func shouldSetNeedsLayout() -> Bool {
        return (lastCount == 0 && favorites.count != 0) || (lastCount != 0 && favorites.count == 0)
    }
    
    public func getData() {
        if !NetworkManager.shared.isInternetAvailable() {
            if StorageManager.fileExists(StorageKeys.season, in: .caches) {
                self.currentSeason = StorageManager.retrieve(StorageKeys.season, from: .caches, as: Season.self)
                return
            }
            else {
                guard let delegate = self.observer else { return }
                delegate.showError(message: "No internet connection".localized())
            }
        }
        else {
            self.fetchSeason()
        }
    }
    
    private func fetchSeason() {
        SeasonService.self.shared.getSeason { (seasons, error) in
            guard let delegate = self.observer else { return }
            if let error = error {
                delegate.showError(message: error.message)
                return
            }
            if let seasons = seasons{
                let newSeason = seasons[0]
                let oldSeason: Season?
                if StorageManager.fileExists(StorageKeys.season, in: .caches) {
                    oldSeason = StorageManager.retrieve(StorageKeys.season, from: .caches, as: Season.self)
                } else {
                    oldSeason = nil
                }
                self.currentSeason = newSeason
                guard newSeason != oldSeason else { return }
                
                StorageManager.store(self.currentSeason, to: .caches, as: StorageKeys.season)
                self.fetchUrbanLines()
                self.fetchSuburbanLines()
                
            }
        }
    }
    
    private func fetchUrbanLines() {
        LineService.shared.getUrbanLines { (lines, error) in
            guard let delegate = self.observer else { return }
            if let error = error {
                delegate.showError(message: error.message)
                return
            }
            if let lines = lines {
                self.urbanLines = lines
                StorageManager.store(self.urbanLines, to: .caches, as: StorageKeys.urbanLines)
                
                let favouriteUrban = self.urbanLines.filter { self.favorites.contains($0.id)}
                favouriteUrban.forEach { line in
                    self.fetchUrbanBus(line: line, isFavourite: true)
                }
                
                let notFavouriteUrban = self.urbanLines.filter{ !self.favorites.contains($0.id)}
                notFavouriteUrban.forEach { line in
                    self.fetchUrbanBus(line: line, isFavourite: false)
                }
            }
        }
    }
    
    private func fetchSuburbanLines() {
        LineService.shared.getSuburbanLines { (lines, error) in
            guard let delegate = self.observer else { return }
            if let error = error {
                delegate.showError(message: error.message)
                return
            }
            if let lines = lines {
                self.suburbanLines = lines
                StorageManager.store(self.suburbanLines, to: .caches, as: StorageKeys.suburbanLines)
                
                let favouriteSuburban = self.suburbanLines.filter { self.favorites.contains($0.id)}
                favouriteSuburban.forEach { line in
                    self.fetchSuburbanBus(line: line, isFavourite: true)
                }
                
                let notFavouriteSuburban = self.suburbanLines.filter{ !self.favorites.contains($0.id)}
                notFavouriteSuburban.forEach { line in
                    self.fetchSuburbanBus(line: line, isFavourite: false)
                }
            }
        }
    }
    
    private func fetchUrbanBus(line: Line, isFavourite: Bool) {
        guard let delegate = self.observer else { return }
        let id = line.id
        BusService.shared.getUrbanBus(id: id) { (buses, error) in
            if let error = error {
                delegate.showError(message: error.message)
                return
            }
            if let buses = buses {
                let sk = StorageKeys.bus + "\(id)"
                StorageManager.store(buses, to: .caches, as: sk)
                if isFavourite {
                    delegate.refreshUI()
                }
            }
        }
    }
    
    private func fetchSuburbanBus(line: Line, isFavourite: Bool) {
        guard let delegate = self.observer else { return }
        let id = line.id
        BusService.shared.getSuburbanBus(id: id) { (buses, error) in
            if let error = error {
                delegate.showError(message: error.message)
                return
            }
            if let buses = buses {
                let sk = StorageKeys.bus + "\(id)"
                StorageManager.store(buses, to: .caches, as: sk)
                if isFavourite {
                    delegate.refreshUI()
                }
            }
        }
    }
}