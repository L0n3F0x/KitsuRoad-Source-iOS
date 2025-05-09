//
//  MarkerStorage.swift
//  KitsuRoad-Source-iOS
//
//  Created by l0n3f0x on 18/03/25.
//

import Foundation

class MarkerStorage {
    private static var fileURL: URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent("markers.json")
    }

    static func saveMarkers(_ markers: [Marker]) {
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(markers)
            try data.write(to: fileURL)
            print("Markers saved successfully.")
        } catch {
            print("Error saving markers: \(error)")
        }
    }

    static func loadMarkers() -> [Marker] {
        let decoder = JSONDecoder()
        
        do {
            let data = try Data(contentsOf: fileURL)
            let markers = try decoder.decode([Marker].self, from: data)
            return markers
        } catch {
            print("Error loading markers: \(error)")
            return []
        }
    }
}

