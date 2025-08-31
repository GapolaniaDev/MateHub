import SwiftUI

struct AttendeeManagementView: View {
    @ObservedObject var store: EventStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "person.2")
                Text("Tu grupo")
                    .font(.headline)
                Spacer()
                Text("\(store.attendees.count) asistentes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Attendee list
            ForEach(Array(store.attendees.enumerated()), id: \.element.id) { index, attendee in
                AttendeeRow(
                    attendee: attendee,
                    onUpdate: { updatedAttendee in
                        store.updateAttendee(at: index, with: updatedAttendee)
                    },
                    onDelete: {
                        store.removeAttendee(at: index)
                    }
                )
            }
            
            // Add attendee button
            Button(action: store.addAttendee) {
                HStack {
                    Image(systemName: "plus")
                    Text("Añadir asistente")
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Diversity meter
            DiversityMeterView(score: store.diversityScore)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct AttendeeRow: View {
    @State private var attendee: Attendee
    let onUpdate: (Attendee) -> Void
    let onDelete: () -> Void
    
    init(attendee: Attendee, onUpdate: @escaping (Attendee) -> Void, onDelete: @escaping () -> Void) {
        self._attendee = State(initialValue: attendee)
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                // Name
                TextField("Nombre", text: $attendee.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minWidth: 80, maxWidth: .infinity)
                
                // Age
                TextField("Edad", value: $attendee.age, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
                    .keyboardType(.numberPad)
                
                // Delete button
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .disabled(attendee.name.isEmpty && attendee.age == 0)
            }
            
            HStack(spacing: 8) {
                // Gender picker
                Menu {
                    ForEach(DataConstants.genders, id: \.self) { gender in
                        Button(gender) {
                            attendee.gender = gender
                        }
                    }
                } label: {
                    HStack {
                        Text(attendee.gender.isEmpty ? "Género" : attendee.gender)
                            .foregroundColor(attendee.gender.isEmpty ? .secondary : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .cornerRadius(6)
                }
                
                // Country picker
                Menu {
                    ForEach(DataConstants.countries, id: \.self) { country in
                        Button(country) {
                            attendee.countryOfBirth = country
                        }
                    }
                } label: {
                    HStack {
                        Text(attendee.countryOfBirth.isEmpty ? "País" : attendee.countryOfBirth)
                            .foregroundColor(attendee.countryOfBirth.isEmpty ? .secondary : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .cornerRadius(6)
                }
                
                // Language picker
                Menu {
                    ForEach(DataConstants.languages, id: \.self) { language in
                        Button(language) {
                            attendee.languageAtHome = language
                        }
                    }
                } label: {
                    HStack {
                        Text(attendee.languageAtHome.isEmpty ? "Idioma" : attendee.languageAtHome)
                            .foregroundColor(attendee.languageAtHome.isEmpty ? .secondary : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .cornerRadius(6)
                }
            }
        }
        .padding(.vertical, 4)
        .onChange(of: attendee) { oldValue, newValue in
            onUpdate(newValue)
        }
    }
}

struct DiversityMeterView: View {
    let score: Int
    
    var meterColor: Color {
        switch score {
        case 85...100: return .green
        case 70...84: return Color(red: 0.8, green: 0.9, blue: 0.2) // lime
        case 50...69: return .orange
        case 30...49: return .red
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Índice de Diversidad Multicultural (IDM)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(score)/100")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 12)
                        .opacity(0.3)
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(score) / 100.0 * geometry.size.width, geometry.size.width), height: 12)
                        .foregroundColor(meterColor)
                        .animation(.easeInOut(duration: 0.6), value: score)
                }
            }
            .frame(height: 12)
            .cornerRadius(6)
            
            Text("El IDM promedia la diversidad por país de nacimiento, idioma en casa, género y rango etario. A mayor diversidad, mayor descuento.")
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    AttendeeManagementView(store: EventStore())
        .padding()
}
