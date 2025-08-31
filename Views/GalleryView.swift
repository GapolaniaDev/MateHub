import SwiftUI

struct GalleryView: View {
    let eventTitle: String
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImageIndex: Int?
    @State private var showingFullScreen = false
    
    // Mock photos data - in a real app these would be fetched from the Google Photos API
    private let photos = [
        GalleryPhoto(
            id: "1",
            thumbnailURL: "https://lh3.googleusercontent.com/pw/AP1GczM1234567890abcdefghijklmnopqrstuvwxyz",
            fullURL: "https://lh3.googleusercontent.com/pw/AP1GczM1234567890abcdefghijklmnopqrstuvwxyz",
            caption: "Opening ceremony with diverse community leaders",
            timestamp: "2024-11-15 10:30 AM"
        ),
        GalleryPhoto(
            id: "2",
            thumbnailURL: "https://lh3.googleusercontent.com/pw/AP1GczN987654321zyxwvutsrqponmlkjihgfedcba",
            fullURL: "https://lh3.googleusercontent.com/pw/AP1GczN987654321zyxwvutsrqponmlkjihgfedcba",
            caption: "Cultural food sharing - bridging communities through cuisine",
            timestamp: "2024-11-15 12:00 PM"
        ),
        GalleryPhoto(
            id: "3",
            thumbnailURL: "https://lh3.googleusercontent.com/pw/AP1GczO456789012mnopqrstuvwxyzabcdefghijkl",
            fullURL: "https://lh3.googleusercontent.com/pw/AP1GczO456789012mnopqrstuvwxyzabcdefghijkl",
            caption: "International friendship group celebrating diversity",
            timestamp: "2024-11-15 2:30 PM"
        ),
        GalleryPhoto(
            id: "4",
            thumbnailURL: "https://lh3.googleusercontent.com/pw/AP1GczP678901234qrstuvwxyzabcdefghijklmnop",
            fullURL: "https://lh3.googleusercontent.com/pw/AP1GczP678901234qrstuvwxyzabcdefghijklmnop",
            caption: "Traditional dance performance from multiple cultures",
            timestamp: "2024-11-15 4:00 PM"
        ),
        GalleryPhoto(
            id: "5",
            thumbnailURL: "https://lh3.googleusercontent.com/pw/AP1GczQ890123456uvwxyzabcdefghijklmnopqrst",
            fullURL: "https://lh3.googleusercontent.com/pw/AP1GczQ890123456uvwxyzabcdefghijklmnopqrst",
            caption: "Group photo with 25% diversity discount celebration",
            timestamp: "2024-11-15 6:00 PM"
        ),
        GalleryPhoto(
            id: "6",
            thumbnailURL: "https://lh3.googleusercontent.com/pw/AP1GczR012345678yzabcdefghijklmnopqrstuvwx",
            fullURL: "https://lh3.googleusercontent.com/pw/AP1GczR012345678yzabcdefghijklmnopqrstuvwx",
            caption: "Sunset networking session with new bridge builders",
            timestamp: "2024-11-15 7:30 PM"
        )
    ]
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Event Gallery")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(eventTitle)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("Close") {
                                dismiss()
                            }
                            .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Image(systemName: "photo.stack")
                                .foregroundColor(.blue)
                            Text("\(photos.count) photos")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "link")
                                    .font(.caption)
                                Text("Google Photos")
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Photo grid
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                            PhotoThumbnail(
                                photo: photo,
                                onTap: {
                                    selectedImageIndex = index
                                    showingFullScreen = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Info section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About these photos")
                            .font(.headline)
                        
                        Text("These photos were taken during the event and showcase the beautiful diversity of our community. Each image represents the bridge-building connections made between people from different cultural backgrounds.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("Photos are stored securely in Google Photos and shared with event participants only.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showingFullScreen) {
            if let selectedIndex = selectedImageIndex {
                PhotoDetailView(
                    photos: photos,
                    selectedIndex: selectedIndex,
                    onDismiss: {
                        showingFullScreen = false
                        selectedImageIndex = nil
                    }
                )
            }
        }
    }
}

struct PhotoThumbnail: View {
    let photo: GalleryPhoto
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Placeholder with gradient
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(8)
                
                // Mock image representation
                VStack {
                    Image(systemName: "photo")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("📸")
                        .font(.title)
                }
                
                // Overlay with photo info
                VStack {
                    Spacer()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(formatTime(photo.timestamp))
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            if !photo.caption.isEmpty {
                                Text(photo.caption)
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineLimit(2)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(8)
                    .background(
                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .cornerRadius(8)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatTime(_ timestamp: String) -> String {
        // Simple time formatting - in real app would use proper date parsing
        if let time = timestamp.split(separator: " ").last {
            return String(time)
        }
        return timestamp
    }
}

struct PhotoDetailView: View {
    let photos: [GalleryPhoto]
    @State var selectedIndex: Int
    let onDismiss: () -> Void
    
    var currentPhoto: GalleryPhoto {
        photos[selectedIndex]
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Button("Close") {
                        onDismiss()
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(selectedIndex + 1) of \(photos.count)")
                        .foregroundColor(.white)
                        .font(.subheadline)
                }
                .padding()
                
                Spacer()
                
                // Main photo area
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .aspectRatio(4/3, contentMode: .fit)
                        .cornerRadius(12)
                    
                    VStack(spacing: 16) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("📸")
                            .font(.system(size: 80))
                        
                        Text("Tap left/right to navigate")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .onTapGesture(count: 1) { location in
                    // Navigate based on tap location
                    let width = UIScreen.main.bounds.width
                    if location.x < width / 2 && selectedIndex > 0 {
                        selectedIndex -= 1
                    } else if location.x > width / 2 && selectedIndex < photos.count - 1 {
                        selectedIndex += 1
                    }
                }
                
                Spacer()
                
                // Photo info
                VStack(alignment: .leading, spacing: 8) {
                    Text(currentPhoto.caption)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(currentPhoto.timestamp)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Navigation dots
                HStack(spacing: 8) {
                    ForEach(0..<photos.count, id: \.self) { index in
                        Circle()
                            .fill(index == selectedIndex ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .onTapGesture {
                                selectedIndex = index
                            }
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }
}

struct GalleryPhoto: Identifiable {
    let id: String
    let thumbnailURL: String
    let fullURL: String
    let caption: String
    let timestamp: String
}