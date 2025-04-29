import SwiftUI

// MARK: - Logo View
struct BeReadyLogo: View {
    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.blue.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // Shield Shape
            ShieldShape()
                .fill(Color.white)
                .frame(width: 50, height: 50)
            
            // Checkmark
            Image(systemName: "checkmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .foregroundColor(.blue)
        }
    }
}

// MARK: - Shield Shape
struct ShieldShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width * 0.5, y: 0))
        path.addLine(to: CGPoint(x: width, y: height * 0.3))
        path.addLine(to: CGPoint(x: width, y: height * 0.7))
        path.addLine(to: CGPoint(x: width * 0.5, y: height))
        path.addLine(to: CGPoint(x: 0, y: height * 0.7))
        path.addLine(to: CGPoint(x: 0, y: height * 0.3))
        path.closeSubpath()
        
        return path
    }
}

public struct HomeView: View {
    @Binding var tabSelection: Int
    @State private var showingMedicalInfo = false
    
    public init(tabSelection: Binding<Int>) {
        self._tabSelection = tabSelection
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header Section with Logo
                    VStack(spacing: 16) {
                        BeReadyLogo()
                            .padding(.top, 20)
                        
                        VStack(spacing: 8) {
                            Text("Be Ready")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Your Emergency Companion")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 10)
                    
                    // SOS Button with enhanced design
                    Button(action: {
                        // Handle SOS action
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 160, height: 160)
                                .shadow(color: Color.red.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            Circle()
                                .stroke(Color.white.opacity(0.9), lineWidth: 4)
                                .frame(width: 144, height: 144)
                            
                            VStack(spacing: 4) {
                                Text("SOS")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Emergency")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                    }
                    .padding(.vertical, 10)
                    
                    // Quick Access Section
                    VStack(alignment: .leading, spacing: 16) {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            QuickTile(
                                icon: "phone.fill",
                                label: "Emergency\nContacts",
                                color: Color.blue.opacity(0.9)
                            ) {
                                tabSelection = 1
                            }
                            
                            QuickTile(
                                icon: "mappin.circle.fill",
                                label: "Emergency\nLocations",
                                color: Color.green.opacity(0.9)
                            ) {
                                tabSelection = 2
                            }
                            
                            QuickTile(
                                icon: "house.fill",
                                label: "Evacuation\nPoints",
                                color: Color.orange.opacity(0.9)
                            ) {
                                tabSelection = 3
                            }
                            
                            QuickTile(
                                icon: "heart.fill",
                                label: "Medical\nInfo",
                                color: Color.purple.opacity(0.9)
                            ) {
                                showingMedicalInfo = true
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .sheet(isPresented: $showingMedicalInfo) {
                MedicalView()
            }
        }
    }
}

// MARK: - QuickTile Component
public struct QuickTile: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    public init(icon: String, label: String, color: Color, action: @escaping () -> Void) {
        self.icon = icon
        self.label = label
        self.color = color
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [color, color.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                }
                
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    HomeView(tabSelection: .constant(0))
} 
