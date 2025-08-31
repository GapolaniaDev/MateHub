import SwiftUI

struct InvoiceView: View {
    @ObservedObject var store: EventStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "receipt")
                Text("Resumen de compra")
                    .font(.headline)
                Spacer()
            }
            
            // Event info
            if let event = store.selectedEvent {
                Text("\(event.title) · \(event.city) · \(formatDate(event.date))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Pricing breakdown
            VStack(spacing: 8) {
                HStack {
                    Text("Precio base (\(store.attendees.count)×)")
                    Spacer()
                    Text(store.formatCurrency(store.basePrice()))
                }
                .font(.subheadline)
                
                HStack {
                    Text("Descuento por diversidad (\(DiversityCalculator.discountDescription(for: store.diversityScore)))")
                    Spacer()
                    Text("-\(store.formatCurrency(store.discountAmount()))")
                        .foregroundColor(.green)
                }
                .font(.subheadline)
                
                Divider()
                
                HStack {
                    Text("Total")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    Text(store.formatCurrency(store.totalPrice()))
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            
            // Payment button
            Button(action: {
                // Handle payment action
            }) {
                Text("Continuar al pago")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            
            // Disclaimer
            Text("* Descuento aplicado únicamente a compras grupales (mínimo 2 personas). Datos de diversidad opcionales y usados solo para calcular el descuento.")
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return dateString }
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct DiscountExplanationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("¿Cómo se calcula el descuento?")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 4) {
                DiscountTierView(range: "0–29", discount: "0%")
                DiscountTierView(range: "30–49", discount: "5%")
                DiscountTierView(range: "50–69", discount: "10%")
                DiscountTierView(range: "70–84", discount: "15%")
                DiscountTierView(range: "85–100", discount: "25%")
            }
            
            Text("Se incentiva la mezcla de país de nacimiento, idioma en casa, género y edad.")
                .font(.caption)
                .italic()
                .foregroundColor(.secondary)
            
            Text("La metodología se puede alinear con marcos como ABS \"Measuring What Matters\" y Scanlon \"Mapping Social Cohesion\".")
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct DiscountTierView: View {
    let range: String
    let discount: String
    
    var body: some View {
        HStack {
            Text(range)
                .fontWeight(.semibold)
                .frame(width: 60, alignment: .leading)
            Text("=")
                .foregroundColor(.secondary)
            Text(discount)
                .fontWeight(.semibold)
                .foregroundColor(.green)
            Spacer()
        }
        .font(.caption)
    }
}

#Preview {
    VStack {
        InvoiceView(store: EventStore())
        DiscountExplanationView()
    }
    .padding()
}