//
//  Marker.swift
//  KitsuRoad-Source-iOS
//
//  Created by l0n3f0x on 18/03/25.
//

import Foundation

struct Marker: Identifiable, Codable {
    var id: UUID
    var latitude: Double
    var longitude: Double
    var title: String
    
    init(latitude: Double, longitude: Double, title: String) {
        self.id = UUID()
        self.latitude = latitude
        self.longitude = longitude
        self.title = title
    }
}

