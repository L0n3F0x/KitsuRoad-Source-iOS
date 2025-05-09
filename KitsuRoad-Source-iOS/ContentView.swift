//
//  ContentView.swift
//  KitsuRoad-Source-iOS
//
//  Created by a l0n3f0x on 28/02/25.
//

import SwiftUI
import MapKit

struct KitsuRoadMarker: Identifiable, Codable {
    var id = UUID()
    let latitude: Double
    let longitude: Double
    let title: String
}

class KRMarkerStorage: ObservableObject {
    @Published var markers: [KitsuRoadMarker] = []
    private let storageKey = "savedMarkers"
    
    init() {
        loadMarkers()
    }
    
    func addMarker(_ marker: KitsuRoadMarker) {
        markers.append(marker)
        saveMarkers()
    }
    
    func removeMarker(at offsets: IndexSet) {
        markers.remove(atOffsets: offsets)
        saveMarkers()
    }
    
    func saveMarkers() {
        if let encoded = try? JSONEncoder().encode(markers) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    func loadMarkers() {
        if let savedData = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([KitsuRoadMarker].self, from: savedData) {
            markers = decoded
        }
    }
}

struct ContentView: View {
    @StateObject private var markerStorage = KRMarkerStorage()
    
    var body: some View {
        TabView {
            FirstView(markerStorage: markerStorage)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            MapView(markerStorage: markerStorage)
                .tabItem {
                    Label("Map", systemImage: "map")
                }
        }
    }
}

struct FirstView: View {
    @ObservedObject var markerStorage: KRMarkerStorage
    @State private var showingAddMarker = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(markerStorage.markers) { marker in
                    NavigationLink(destination: MapView(markerStorage: markerStorage, focusMarker: marker)) {
                        Text(marker.title)
                            .padding()
                    }
                }
                .onDelete(perform: deleteMarkers)
            }
            .navigationTitle("Reports")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddMarker = true }) {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMarker) {
                AddMarkerView(markerStorage: markerStorage)
            }
        }
    }
    
    private func deleteMarkers(at offsets: IndexSet) {
        markerStorage.removeMarker(at: offsets)
    }
}

struct MapView: View {
    @ObservedObject var markerStorage: KRMarkerStorage
    var focusMarker: KitsuRoadMarker? = nil
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.610895, longitude: -100.276160),
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: markerStorage.markers) { marker in
            MapMarker(
                coordinate: CLLocationCoordinate2D(latitude: marker.latitude, longitude: marker.longitude),
                tint: .red
            )
        }
        .onAppear {
            if let marker = focusMarker {
                region.center = CLLocationCoordinate2D(latitude: marker.latitude, longitude: marker.longitude)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationTitle("Map View")
    }
}

struct AddMarkerView: View {
    @ObservedObject var markerStorage: KRMarkerStorage
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedAccidentType = "Option 1"
    let options = ["Option 1", "Option 2", "Option 3"]
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Accident Type", selection: $selectedAccidentType) {
                    ForEach(options, id: \.self) { option in
                        Text(option)
                    }
                }
                Button("Save Marker") {
                    let newMarker = KitsuRoadMarker(
                        latitude: Double.random(in: (25.610895 - 0.001)...(25.610895 + 0.001)),
                        longitude: Double.random(in: (-100.276160 - 0.001)...(-100.276160 + 0.001)),
                        title: "📍 \(selectedAccidentType)"
                    )
                    markerStorage.addMarker(newMarker)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationTitle("Add Report")
            .toolbar {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

