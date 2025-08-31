import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var store: EventStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Mapa de eventos")
                    .font(.headline)
                Spacer()
                Button(action: {
                    // Handle location button tap
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "location")
                        Text("Usar mi ubicación")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            
            // Map
            Map(coordinateRegion: .constant(australiaRegion), annotationItems: store.filteredEvents) { event in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: event.coords.lat, longitude: event.coords.lng)) {
                    EventMapPin(
                        event: event,
                        isSelected: store.selectedEventId == event.id,
                        onTap: {
                            store.selectEvent(event.id)
                        }
                    )
                }
            }
            .frame(height: 300)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var australiaRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -27.0, longitude: 133.0),
            span: MKCoordinateSpan(latitudeDelta: 30.0, longitudeDelta: 25.0)
        )
    }
}

struct EventMapPin: View {
    let event: Event
    let isSelected: Bool
    let onTap: () -> Void
    @State private var showDetails = false
    
    var body: some View {
        Button(action: onTap) {
            VStack {
                Image(systemName: "mappin.circle.fill")
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .red)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 2)
                
                if showDetails {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.title)
                            .font(.caption)
                            .fontWeight(.medium)
                            .lineLimit(2)
                        
                        Text("\(event.city) · \(formatDate(event.date))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(event.category)
                                .font(.caption2)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color(.systemGray6))
                                .cornerRadius(4)
                            
                            Spacer()
                            
                            Text(NumberFormatter.currency.string(from: NSNumber(value: event.price)) ?? "$0.00")
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(8)
                    .background(Color(.systemBackground).opacity(0.95))
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    .frame(width: 180)
                }
            }
        }
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture {
            showDetails.toggle()
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return dateString }
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// Alternative simplified map view for when MapKit is not available
struct SimpleMapView: View {
    @ObservedObject var store: EventStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Mapa de eventos")
                    .font(.headline)
                Spacer()
                Button(action: {
                    // Handle location button tap
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "location")
                        Text("Usar mi ubicación")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            
            // Simplified map representation
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.blue.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Grid pattern
                VStack(spacing: 20) {
                    ForEach(0..<4) { row in
                        HStack(spacing: 20) {
                            ForEach(0..<5) { col in
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 2, height: 2)
                            }
                        }
                    }
                }
                
                // Event pins
                ForEach(store.filteredEvents.prefix(8)) { event in
                    Button(action: {
                        store.selectEvent(event.id)
                    }) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title3)
                            .foregroundColor(store.selectedEventId == event.id ? .blue : .red)
                    }
                    .position(
                        x: CGFloat.random(in: 50...250),
                        y: CGFloat.random(in: 50...200)
                    )
                }
            }
            .frame(height: 250)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    MapView(store: EventStore())
        .padding()
}