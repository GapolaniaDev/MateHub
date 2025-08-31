import SwiftUI
import MapKit
import Combine

@MainActor
class EnhancedMapViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -34.9285, longitude: 138.6007),
        span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
    )
    
    @Published var events: [EventModel] = []
    @Published var searchQuery: String = ""
    @Published var selectedState: String = "All"
    @Published var selectedCategory: String = "All"
    @Published var showingFilters: Bool = false
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    var filteredEvents: [EventModel] {
        events.filter { event in
            let matchesSearch = searchQuery.isEmpty ||
                event.title.localizedCaseInsensitiveContains(searchQuery) ||
                event.city.localizedCaseInsensitiveContains(searchQuery) ||
                (event.venue?.localizedCaseInsensitiveContains(searchQuery) ?? false)
            
            let matchesState = selectedState == "All" || event.state == selectedState
            let matchesCategory = selectedCategory == "All" || event.category == selectedCategory
            
            return matchesSearch && matchesState && matchesCategory
        }
    }
    
    init() {
        setupSearchDebouncing()
    }
    
    private func setupSearchDebouncing() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { _ in
                Task { @MainActor in
                    // Trigger filtering - objectWillChange is automatically called by @Published
                }
            }
            .store(in: &cancellables)
    }
    
    func loadEvents() {
        isLoading = true
        
        // Load from database
        events = MockDatabaseManager.shared.getAllEvents()
        
        isLoading = false
    }
    
    func centerOnUserLocation() {
        // In a real implementation, this would request location permission
        // and center on user's location
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -34.9285, longitude: 138.6007), // Adelaide
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
    }
    
    func focusOnEvent(_ event: EventModel) {
        guard let lat = event.lat, let lng = event.lng else { return }
        
        withAnimation(.easeInOut(duration: 1.0)) {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        }
    }
}

struct FilterSheet: View {
    @ObservedObject var viewModel: EnhancedMapViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationContainer {
            Form {
                Section("State/Territory") {
                    Picker("State", selection: $viewModel.selectedState) {
                        Text("All").tag("All")
                        ForEach(EnhancedDataConstants.australianStates, id: \.self) { state in
                            Text(state).tag(state)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                
                Section("Category") {
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        Text("All").tag("All")
                        ForEach(EnhancedDataConstants.eventCategories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                
                Section {
                    Button("Clear filters") {
                        viewModel.selectedState = "All"
                        viewModel.selectedCategory = "All"
                        viewModel.searchQuery = ""
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}