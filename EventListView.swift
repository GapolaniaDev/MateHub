import SwiftUI

struct EventListView: View {
    @ObservedObject var store: EventStore
    
    var body: some View {
        VStack(spacing: 16) {
            // Search and filters
            VStack(spacing: 12) {
                SearchBar(text: $store.searchText)
                
                HStack(spacing: 12) {
                    // State filter
                    Menu {
                        ForEach(AustralianState.allCases, id: \.self) { state in
                            Button(state.rawValue) {
                                store.selectedState = state
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "location")
                            Text(store.selectedState.rawValue)
                            Image(systemName: "chevron.down")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    // Category filter
                    Menu {
                        ForEach(EventCategory.allCases, id: \.self) { category in
                            Button(category.rawValue) {
                                store.selectedCategory = category
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "tag")
                            Text(store.selectedCategory.rawValue)
                            Image(systemName: "chevron.down")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                }
            }
            
            // Event count
            HStack {
                Image(systemName: "mappin.and.ellipse")
                Text("Eventos disponibles (\(store.filteredEvents.count))")
                    .font(.headline)
                Spacer()
            }
            
            // Events grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(store.filteredEvents) { event in
                    EventCard(event: event, isSelected: store.selectedEventId == event.id) {
                        store.selectEvent(event.id)
                    }
                }
            }
        }
        .padding()
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Buscar eventos, ciudades, venues…", text: $text)
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct EventCard: View {
    let event: Event
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Category and sponsored badge
                HStack {
                    Text(event.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    if event.sponsored {
                        Text("Programa Estatal")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .cornerRadius(4)
                    }
                }
                
                // Event title
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                
                // Location
                Text("\(event.city) · \(event.venue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Date
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(formatDate(event.date))
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                
                // Price
                HStack {
                    Text(NumberFormatter.currency.string(from: NSNumber(value: event.price)) ?? "$0.00")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("/ persona")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding(12)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return dateString }
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

extension NumberFormatter {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_AU")
        return formatter
    }()
}

#Preview {
    EventListView(store: EventStore())
}