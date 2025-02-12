//
//  ContentView.swift
//  habit-tracker-hive
//
//  Created by Hanyi Ye on 2025-02-06.
//

import SwiftUI

// Add GradientStyle enum for different color combinations
enum GradientStyle {
    case blue
    case red
    case green
    case light_pink
    case orange
    case yellow
    case pink
    case teal
    case grey
    
    var gradient: LinearGradient {
        switch self {
        case .blue:
            return LinearGradient(
                colors: [
                    Color(hex: "a1c4fd"),
                    Color(hex: "c2e9fb")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .red:
            return LinearGradient(
                colors: [
                    Color(hex: "ff9a9e"),
                    Color(hex: "fecfef")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .green:
            return LinearGradient(
                colors: [
                    Color(hex: "dcedc8"),
                    Color(hex: "f1f8e9")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .light_pink:
            return LinearGradient(
                colors: [
                    Color(hex: "e0c3fc"),
                    Color(hex: "f9e6ff")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .orange:
            return LinearGradient(
                colors: [
                    Color(hex: "ffe0b2"),
                    Color(hex: "ffcc80")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .yellow:
            return LinearGradient(
                colors: [
                    Color(hex: "fffde7"),
                    Color(hex: "fff9c4")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .pink:
            return LinearGradient(
                colors: [
                    Color(hex: "ffc1e3"),
                    Color(hex: "ffe6f0")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .teal:
            return LinearGradient(
                colors: [
                    Color(hex: "b2dfdb"),
                    Color(hex: "e0f2f1")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .grey:
            return LinearGradient(
                colors: [
                    Color(hex: "f0f0f0"),
                    Color(hex: "d9d9d9")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }  
    }     
}

// Add Color extension to support hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Add Comment struct
struct Comment: Identifiable {
    let id = UUID()
    let text: String
    let date: Date
}

// Habit structure to store habit data
struct Habit: Identifiable {
    let id = UUID()
    var position: CGPoint
    var title: String
    var frequency: Frequency
    var gradientStyle: GradientStyle
    var description: String
    var priority: Priority
    var count: Int
    var isAnimating: Bool
    var comments: [Comment] = []  // Add comments array
    
    // Computed property for hexagon size based on priority
    var size: CGFloat {
        let baseSize: CGFloat = switch priority {
        case .high: 180
        case .medium: 160
        case .low: 140
        }
        return isAnimating ? baseSize : 0
    }
}

// Frequency options for habits
enum Frequency: String, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case custom = "Custom"
}

// Priority enum for habit importance
enum Priority: String, CaseIterable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
}

// Hexagon habit view
struct HexagonHabit: View {
    @Binding var habit: Habit
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0  // Add rotation state
    @State private var animationInProgress = false  // Track animation state
    @State private var showingComments = false
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(habit.count)")
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.black)
            
            Text(habit.title)
                .font(.system(size: 17))
                .foregroundColor(.black.opacity(0.6))
            
            Text(habit.frequency.rawValue.lowercased())
                .font(.system(size: 15))
                .foregroundColor(.black.opacity(0.4))
            
            // Add comment button
            Button(action: {
                showingComments = true
            }) {
                VStack(spacing: 2) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 14))
                    Text("\(habit.comments.count)")
                        .font(.system(size: 12))
                }
                .foregroundColor(.black.opacity(0.4))
            }
            .offset(y: 5)
        }
        .frame(width: habit.size, height: habit.size)
        .background(
            RegularPolygon(sides: 6)
                .fill(habit.gradientStyle.gradient)
                .shadow(color: .black.opacity(0.2), radius: 5)
        )
        .scaleEffect(scale)
        .rotationEffect(.degrees(rotation))  // Add rotation effect
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                opacity = 1
            }
        }
        .gesture(
            LongPressGesture(minimumDuration: 0.5)  // Reduce duration for faster response
                .onEnded { _ in
                    if !animationInProgress {  // Prevent multiple animations
                        incrementCount()
                    }
                }
        )
        .sheet(isPresented: $showingComments) {
            CommentSheet(habit: $habit)
        }
    }
    
    private func incrementCount() {
        animationInProgress = true
        
        // Haptic feedback
        let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactGenerator.impactOccurred()
        
        // First phase: Scale up and rotate
        withAnimation(.easeIn(duration: 0.15)) {
            scale = 1.4
            rotation = 15
        }
        
        // Second phase: Increment count and start settling
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            habit.count += 1
            
            // Scale down and rotate back
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                scale = 0.8
                rotation = -5
            }
            
            // Final phase: Return to normal
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    scale = 1.0
                    rotation = 0
                }
                
                // Reset animation flag
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    animationInProgress = false
                }
            }
        }
    }
}

// Helper shape for creating hexagon
struct RegularPolygon: Shape {
    let sides: Int
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2
        
        var path = Path()
        for i in 0..<sides {
            // Start at 30 degrees (π/6) to align flat edge on top
            let angle = (Double(i) * (360.0 / Double(sides)) + 30) * Double.pi / 180
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

// Add this helper struct for hex coordinates
struct HexCoord {
    let q: Int // x-axis
    let r: Int // y-axis
    
    // Get the 6 neighboring coordinates in clockwise order
    func neighbors() -> [HexCoord] {
        [
            HexCoord(q: q+1, r: r),     // right
            HexCoord(q: q+1, r: r-1),   // top right
            HexCoord(q: q, r: r-1),     // top left
            HexCoord(q: q-1, r: r),     // left
            HexCoord(q: q-1, r: r+1),   // bottom left
            HexCoord(q: q, r: r+1)      // bottom right
        ]
    }
}

// Add a preview view for gradient selection
struct GradientPreview: View {
    let gradientStyle: GradientStyle
    let isSelected: Bool
    
    var body: some View {
        RegularPolygon(sides: 6)
            .fill(gradientStyle.gradient)
            .frame(width: 50, height: 50)
            .overlay(
                RegularPolygon(sides: 6)
                    .stroke(isSelected ? Color.black : Color.clear, lineWidth: 2)
            )
            .shadow(radius: isSelected ? 3 : 1)
    }
}

// Form view for adding new habits
struct AddHabitForm: View {
    @Binding var isPresented: Bool
    @Binding var habits: [Habit]
    let position: CGPoint
    
    @State private var title = ""
    @State private var frequency: Frequency = .daily
    @State private var description = ""
    @State private var priority: Priority = .medium
    @State private var count: Int = 0
    @State private var gradientStyle: GradientStyle = .blue
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Habit Name", text: $title)
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue)
                        }
                    }
                    
                    Picker("Frequency", selection: $frequency) {
                        ForEach(Frequency.allCases, id: \.self) { frequency in
                            Text(frequency.rawValue)
                        }
                    }
                }
                
                Section(header: Text("Appearance")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach([
                                GradientStyle.blue,
                                GradientStyle.red,
                                GradientStyle.green,
                                GradientStyle.light_pink,
                                GradientStyle.orange,
                                GradientStyle.yellow,
                                GradientStyle.pink,
                                GradientStyle.teal,
                                GradientStyle.grey
                            ], id: \.self) { style in
                                GradientPreview(
                                    gradientStyle: style,
                                    isSelected: gradientStyle == style
                                )
                                .onTapGesture {
                                    gradientStyle = style
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                }
                
                Section(header: Text("Progress")) {
                    Stepper("Current Count: \(count)", value: $count)
                }
            }
            .navigationTitle("New Habit")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Add") {
                    let newPosition = calculateNextPosition()
                    let newHabit = Habit(
                        position: newPosition,
                        title: title.isEmpty ? "New Habit" : title,
                        frequency: frequency,
                        gradientStyle: gradientStyle,
                        description: description,
                        priority: priority,
                        count: count,
                        isAnimating: false
                    )
                    
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        habits.append(newHabit)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if let index = habits.firstIndex(where: { $0.id == newHabit.id }) {
                                habits[index].isAnimating = true
                            }
                        }
                    }
                    isPresented = false
                }
                .disabled(title.isEmpty)
            )
        }
    }
    
    // Update the calculateNextPosition function in AddHabitForm
    private func calculateNextPosition() -> CGPoint {
        let maxSize = CGFloat(180)
        
        // Calculate spacing based on maximum hexagon size
        let width = maxSize * sqrt(3)
        let height = maxSize * 2
        let horizontalSpacing = width * 0.58
        
        // First habit goes in center
        if habits.isEmpty {
            return position
        }
        
        // Function to calculate distance between two points
        func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
            let dx = p1.x - p2.x
            let dy = p1.y - p2.y
            return sqrt(dx * dx + dy * dy)
        }
        
        // Function to check if position is occupied
        func isPositionOccupied(_ pos: CGPoint) -> Bool {
            let minDistance = maxSize * 1.0
            return habits.contains { habit in
                distance(habit.position, pos) < minDistance
            }
        }
        
        // Calculate positions in expanding rings
        var ring = 1
        while ring < 100 {
            for i in 0..<(6 * ring) {
                let angle = Double(i) * (Double.pi / 3) / Double(ring)
                let ringRadius = Double(ring) * Double(horizontalSpacing)
                
                let x = position.x + CGFloat(cos(angle) * ringRadius)
                let y = position.y + CGFloat(sin(angle) * ringRadius)
                let newPosition = CGPoint(x: x, y: y)
                
                if !isPositionOccupied(newPosition) {
                    return newPosition
                }
            }
            ring += 1
        }
        
        return position
    }
}

// Add CommentSheet view for displaying and adding comments
struct CommentSheet: View {
    @Binding var habit: Habit
    @Environment(\.dismiss) var dismiss
    @State private var newComment: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(habit.comments) { comment in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(comment.text)
                                .foregroundColor(.black)
                            Text(comment.date.formatted())
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                HStack {
                    TextField("Add a comment", text: $newComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: {
                        if !newComment.isEmpty {
                            habit.comments.append(Comment(text: newComment, date: Date()))
                            newComment = ""
                        }
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.black)
                            .font(.title2)
                    }
                }
                .padding()
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    @State private var offset: CGSize = .zero
    @State private var lastDragPosition: CGSize = .zero
    @State private var habits: [Habit] = []
    @State private var isAddingHabit = false
    @State private var newHabitPosition: CGPoint = .zero
    
    // Add computed property to check if view is moved
    private var isViewMoved: Bool {
        abs(offset.width) > 1 || abs(offset.height) > 1
    }
    
    var body: some View {
        GeometryReader { geometry in
            let centerPosition = CGPoint(
                x: geometry.size.width/2,
                y: geometry.size.height/2
            )
            
            ZStack {
                Color.gray.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                
                ZStack {
                    ForEach($habits) { $habit in
                        HexagonHabit(habit: $habit)
                            .position(x: habit.position.x, y: habit.position.y)
                    }
                }
                .offset(offset)
                
                // Reset position button in top right
                if isViewMoved {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                    offset = .zero
                                    lastDragPosition = .zero
                                }
                            }) {
                                Image(systemName: "house.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.black)
                                    .frame(width: 44, height: 44)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                            .padding()
                            .transition(.opacity) // Add fade transition
                        }
                        Spacer()
                    }
                }
                
                // Add habit button at bottom center
                VStack {
                    Spacer()
                    Button(action: {
                        newHabitPosition = centerPosition
                        isAddingHabit = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.black)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.bottom, 30) // Add some padding from bottom
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newOffset = CGSize(
                            width: lastDragPosition.width + value.translation.width,
                            height: lastDragPosition.height + value.translation.height
                        )
                        offset = newOffset
                    }
                    .onEnded { value in
                        lastDragPosition = offset
                    }
            )
            .sheet(isPresented: $isAddingHabit) {
                AddHabitForm(
                    isPresented: $isAddingHabit,
                    habits: $habits,
                    position: centerPosition
                )
            }
        }
    }
}

// Preview provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}