//
//  Group.swift
//  Alarmation
//
//  Created by Stanly Shiyanovskiy on 06.10.2020.
//

import Foundation

public final class Group: NSObject, Codable {
    
    public var id: String
    public var name: String
    public var playSound: Bool
    public var enabled: Bool
    public var alarms: [Alarm]

    public init(name: String, playSound: Bool, enabled: Bool, alarms: [Alarm]) {
        self.id = UUID().uuidString
        self.name = name
        self.playSound = playSound
        self.enabled = enabled
        self.alarms = alarms
    }

    public required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as! String
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.playSound = aDecoder.decodeBool(forKey: "playSound")
        self.enabled = aDecoder.decodeBool(forKey: "enabled")
        self.alarms = aDecoder.decodeObject(forKey: "alarms") as! [Alarm]
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(playSound, forKey: "playSound")
        aCoder.encode(enabled, forKey: "enabled")
        aCoder.encode(alarms, forKey: "alarms")
    }
}
