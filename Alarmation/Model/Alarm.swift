//
//  Alarm.swift
//  Alarmation
//
//  Created by Stanly Shiyanovskiy on 06.10.2020.
//

import UIKit

public final class Alarm: NSObject, Codable {

    public var id: String
    public var name: String
    public var caption: String
    public var time: Date
    public var image: String

    public init(name: String, caption: String, time: Date, image: String) {
        self.id = UUID().uuidString
        self.name = name
        self.caption = caption
        self.time = time
        self.image = image
    }

    public required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as! String
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.caption = aDecoder.decodeObject(forKey: "caption") as! String
        self.time = aDecoder.decodeObject(forKey: "time") as! Date
        self.image = aDecoder.decodeObject(forKey: "image") as! String
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.caption, forKey: "caption")
        aCoder.encode(self.time, forKey: "time")
        aCoder.encode(self.image, forKey: "image")
    }
}
