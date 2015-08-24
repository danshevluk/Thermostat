//
//  Observable.swift
//  Thermostat
//
//  Created by Dan Shevlyuk on 25/08/15.
//  Copyright (c) 2015 Team #19. All rights reserved.
//

protocol Observable: class {
    typealias ObserverProtocol
    var observers: [ObserverProtocol] {get set}
    func addObserver(observer: ObserverProtocol)
    func removeObserver(observer: ObserverProtocol)
    func notifyObservers(notify: (observer: ObserverProtocol) -> Void)
}
