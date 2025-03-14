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
                    Color(hex: "ff6b6b"),
                    Color(hex: "ffa5a5")
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
                    Color.gray.opacity(0.6),
                    Color.gray.opacity(0.3)
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
    var customFrequency: String = ""  // Add this property
    var gradientStyle: GradientStyle
    var description: String
    var priority: Priority
    var count: Int
    var isAnimating: Bool
    var comments: [Comment] = []  // Add comments array
    
    // Add computed property for display frequency
    var displayFrequency: String {
        if frequency == .custom {
            return customFrequency
        }
        return frequency.displayText
    }
    
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
    
    // Add custom text property
    var displayText: String {
        if case .custom = self {
            return "" // Will be replaced by customFrequency
        }
        return self.rawValue.lowercased()
    }
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
    var editAction: () -> Void
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0
    @State private var showingComments = false
    @State private var showingEditSheet = false
    @State private var isLongPressing = false
    @State private var progressValue: CGFloat = 0
    @State private var editButtonOpacity: Double = 0
    @State private var dragLocation: CGPoint = .zero
    @State private var isOverEditButton: Bool = false
    @State private var lastEditSheetState: Bool = false
    @State private var debugTapLocation: CGPoint? = nil
    @State private var debugButtonCenter: CGPoint? = nil
    @State private var currentLocation: CGPoint = .zero
    @State private var longPressStartTime: Date? = nil
    
    private let editButtonSize: CGFloat = 44
    private let longPressThreshold: TimeInterval = 1.0
    
    // Update the outline gradient based on the habit's gradient style
    private var outlineGradient: LinearGradient {
        switch habit.gradientStyle {
        case .blue:
            return LinearGradient(
                colors: [
                    Color(hex: "1e3c72").opacity(0.5),
                    Color(hex: "a1c4fd").opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .red:
            return LinearGradient(
                colors: [
                    Color(hex: "ff4040").opacity(0.8),
                    Color(hex: "ff8080").opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .green:
            return LinearGradient(
                colors: [
                    Color(hex: "56ab2f").opacity(0.5),
                    Color(hex: "a8e063").opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .light_pink:
            return LinearGradient(
                colors: [
                    Color(hex: "e0c3fc").opacity(0.8),
                    Color(hex: "dd5e89").opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .orange:
            return LinearGradient(
                colors: [
                    Color(hex: "ff8008").opacity(0.8),
                    Color(hex: "ffc837").opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .yellow:
            return LinearGradient(
                colors: [
                    Color(hex: "f7971e").opacity(0.8),
                    Color(hex: "ffd200").opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .pink:
            return LinearGradient(
                colors: [
                    Color(hex: "dd5e89").opacity(0.8),
                    Color(hex: "f7bb97").opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .teal:
            return LinearGradient(
                colors: [
                    Color(hex: "11998e").opacity(0.8),
                    Color(hex: "38ef7d").opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .grey:
            return LinearGradient(
                colors: [
                    Color.gray.opacity(0.6),
                    Color.gray.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var body: some View {
        ZStack {
            // Background hexagon
            RegularPolygon(sides: 6)
                .fill(habit.gradientStyle.gradient)
                .frame(width: habit.size, height: habit.size)
                .shadow(color: .black.opacity(0.2), radius: 5)
            
            // Content
            VStack(spacing: 2) {
                Text("\(habit.count)")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(.black)
                
                Text(habit.title)
                    .font(.system(size: 17))
                    .foregroundColor(.black.opacity(0.6))
                    .lineLimit(1)
                
                Text(habit.displayFrequency)
                    .font(.system(size: 15))
                    .foregroundColor(.black.opacity(0.4))
                    .lineLimit(1)
                
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
            .padding(.horizontal)
            .frame(width: habit.size, height: habit.size)
            
            // Progress outline (when long pressing)
            if isLongPressing {
                RegularPolygon(sides: 6)
                    .trim(from: 0, to: progressValue)
                    .stroke(outlineGradient, lineWidth: 5)
                    .rotationEffect(.degrees(120))
                    .frame(width: habit.size, height: habit.size)
            }
            
            // Edit button with correct positioning (top-right corner)
            if isLongPressing {
                ZStack(alignment: .topTrailing) {
                    Color.clear
                        .frame(width: habit.size, height: habit.size)
                    
                    // Edit button with adjusted position
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                        .background(Circle().fill(Color.white))
                        .clipShape(Circle())
                        .opacity(editButtonOpacity)
                        .background(
                            Circle()
                                .fill(Color.red.opacity(0.3))
                                .frame(width: 40, height: 40)
                        )
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)) // Adjust to move more to the right
                        .offset(x: 10, y: -10) // Move more up and to the right
                }
            }
            
            // Debug tap location
            if isLongPressing, let tap = debugTapLocation {
                Circle()
                    .fill(Color.green.opacity(0.5))
                    .frame(width: 20, height: 20)
                    .position(tap)
            }
        }
        .frame(width: habit.size, height: habit.size)
        .scaleEffect(scale)
        .rotationEffect(.degrees(rotation))
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                opacity = 1
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .simultaneously(with: LongPressGesture(minimumDuration: 0))
                .onChanged { value in
                    let drag = value.first!
                    handleGestureChange(location: drag.location)
                }
                .onEnded { _ in
                    handleGestureEnd()
                }
        )
        .sheet(isPresented: $showingComments) {
            CommentSheet(habit: $habit)
                .onAppear { print("Comment sheet appeared") }
                .onDisappear { print("Comment sheet disappeared") }
        }
    }
    
    private func handleGestureChange(location: CGPoint) {
        if !isLongPressing {
            isLongPressing = true
            
            // Store the original start position of the gesture and time
            dragLocation = location
            longPressStartTime = Date() // Record when the long press started
            print("GESTURE START: Location: \(location), Habit size: \(habit.size), Time: \(longPressStartTime!)")
            
            withAnimation(.linear(duration: longPressThreshold)) {
                progressValue = 1.0
            }
            
            withAnimation(.easeIn(duration: 0.2)) {
                editButtonOpacity = 1.0
            }
        }
        
        // Update current location
        currentLocation = location
        
        // Update debug tap location
        debugTapLocation = location
        
        // Check if tap is inside the hexagon
        let hexagonCenter = CGPoint(x: habit.size/2, y: habit.size/2)
        let distanceFromCenter = sqrt(
            pow(location.x - hexagonCenter.x, 2) +
            pow(location.y - hexagonCenter.y, 2)
        )
        
        // Simple check for inside hexagon (approximate as circle for now)
        let isInsideHexagon = distanceFromCenter <= habit.size/2
        
        // UPDATED: Edit button position calculation with offset
        let buttonPosition = CGPoint(
            x: habit.size - 15, // Move further to the right
            y: 15 // Move further up
        )
        
        // Calculate distance from current location to button
        let distance = sqrt(
            pow(location.x - buttonPosition.x, 2) +
            pow(location.y - buttonPosition.y, 2)
        )
        
        let editButtonRadius: CGFloat = 20
        let isOver = distance < editButtonRadius
        
        print("GESTURE MOVE: Location: \(location), Button: \(buttonPosition), Distance: \(distance), Inside Hexagon: \(isInsideHexagon), Is over button: \(isOver)")
        
        // Update isOverEditButton only if we're over the button
        if isOver != isOverEditButton {
            withAnimation(.easeInOut(duration: 0.2)) {
                isOverEditButton = isOver
                scale = isOver ? 1.1 : 1.0
                rotation = isOver ? -5 : 0
            }
        }
    }
    
    private func handleGestureEnd() {
        print("GESTURE END: Final isOverEditButton: \(isOverEditButton), Progress: \(progressValue)")
        
        // Calculate how long the user has been pressing
        let elapsedTime: TimeInterval
        if let startTime = longPressStartTime {
            elapsedTime = Date().timeIntervalSince(startTime)
        } else {
            elapsedTime = 0
        }
        
        print("GESTURE END: Elapsed time: \(elapsedTime) seconds (threshold: \(longPressThreshold))")
        
        // Check if final position is inside the hexagon
        let hexagonCenter = CGPoint(x: habit.size/2, y: habit.size/2)
        let distanceFromCenter = sqrt(
            pow(currentLocation.x - hexagonCenter.x, 2) +
            pow(currentLocation.y - hexagonCenter.y, 2)
        )
        
        // Simple check for inside hexagon (approximate as circle for now)
        let isInsideHexagon = distanceFromCenter <= habit.size/2
        
        if isOverEditButton {
            print("GESTURE END: Triggering edit action")
            // Delay resetting state until after edit action
            DispatchQueue.main.async {
                editAction()
            }
        } else if elapsedTime >= longPressThreshold && isInsideHexagon {
            // Only increment count if:
            // 1. User has held for the required duration (longPressThreshold)
            // 2. User's finger is inside hexagon at the END of the gesture
            print("GESTURE END: Held for required time and finger ended inside hexagon, incrementing count")
            incrementCount()
        } else {
            print("GESTURE END: Not incrementing count - Elapsed time: \(elapsedTime), Required: \(longPressThreshold), Inside: \(isInsideHexagon)")
        }
        
        // Reset the start time
        longPressStartTime = nil
        
        print("GESTURE END: Resetting UI state")
        withAnimation {
            isLongPressing = false
            progressValue = 0
            editButtonOpacity = 0
            scale = 1.0
            rotation = 0
            isOverEditButton = false
        }
    }
    
    private func incrementCount() {
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator.impactOccurred()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            scale = 1.2
            habit.count += 1
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.1)) {
            scale = 1.0
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
    @State private var customFrequency: String = ""
    private let titleLimit = 20
    private let customFrequencyLimit = 15
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Habit Name", text: Binding(
                            get: { title },
                            set: { title = String($0.prefix(titleLimit)) }
                        ))
                        
                        Text("\(title.count)/\(titleLimit)")
                            .font(.caption)
                            .foregroundColor(title.count >= titleLimit ? .red : .gray)
                    }
                    
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
                    
                    if frequency == .custom {
                        VStack(alignment: .leading, spacing: 4) {
                            TextField("Custom Frequency", text: Binding(
                                get: { customFrequency },
                                set: { customFrequency = String($0.prefix(customFrequencyLimit)) }
                            ))
                            
                            Text("\(customFrequency.count)/\(customFrequencyLimit)")
                                .font(.caption)
                                .foregroundColor(customFrequency.count >= customFrequencyLimit ? .red : .gray)
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
                    Stepper("Current Count: \(count)", value: $count, in: 0...Int.max)
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
                        customFrequency: customFrequency,
                        gradientStyle: gradientStyle,
                        description: description,
                        priority: priority,
                        count: count,
                        isAnimating: true  // Set this to true initially
                    )
                    
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        habits.append(newHabit)
                    }
                    isPresented = false
                }
                .disabled(title.isEmpty || (frequency == .custom && customFrequency.isEmpty))
            )
        }
    }
    
    // Update the calculateNextPosition function in AddHabitForm
    private func calculateNextPosition() -> CGPoint {
        let maxSize = CGFloat(180)
        
        // Calculate spacing based on maximum hexagon size
        let width = maxSize * sqrt(3)
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
            VStack(spacing: 0) {
                // Header with habit info
                VStack(spacing: 8) {
                    Text(habit.title)
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text("\(habit.comments.count) comments")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                
                // Comments list
                if habit.comments.isEmpty {
                    Spacer()
                    Text("No comments yet")
                        .foregroundColor(.gray)
                        .italic()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(habit.comments) { comment in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(comment.text)
                                        .foregroundColor(.black)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    Text(comment.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                    }
                }
                
                // Comment input area
                VStack(spacing: 0) {
                    Divider()
                    HStack(spacing: 12) {
                        TextField("Add a comment...", text: $newComment)
                            .textFieldStyle(.plain)
                            .padding(.vertical, 12)
                        
                        Button(action: {
                            if !newComment.isEmpty {
                                habit.comments.append(Comment(text: newComment, date: Date()))
                                newComment = ""
                            }
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(newComment.isEmpty ? .gray : .black)
                                .font(.system(size: 24))
                        }
                        .disabled(newComment.isEmpty)
                    }
                    .padding(.horizontal)
                    .background(Color.white)
                }
            }
            .background(Color.gray.opacity(0.05))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.black)
                            .font(.system(size: 24))
                    }
                }
            }
        }
    }
}

// Add EditHabitForm for editing existing habits
struct EditHabitForm: View {
    @Binding var habit: Habit
    @Binding var isPresented: Bool
    @State private var title: String
    @State private var frequency: Frequency
    @State private var customFrequency: String
    @State private var priority: Priority
    @State private var count: Int
    @State private var gradientStyle: GradientStyle
    @State private var showDeleteConfirmation = false
    var onDelete: (() -> Void)? = nil
    
    private let titleLimit = 20
    private let customFrequencyLimit = 15
    
    init(habit: Binding<Habit>, isPresented: Binding<Bool>, onDelete: (() -> Void)? = nil) {
        self._habit = habit
        self._isPresented = isPresented
        self._title = State(initialValue: habit.wrappedValue.title)
        self._frequency = State(initialValue: habit.wrappedValue.frequency)
        self._customFrequency = State(initialValue: habit.wrappedValue.customFrequency)
        self._priority = State(initialValue: habit.wrappedValue.priority)
        self._count = State(initialValue: habit.wrappedValue.count)
        self._gradientStyle = State(initialValue: habit.wrappedValue.gradientStyle)
        self.onDelete = onDelete
        
        print("EditHabitForm initialized with: \(habit.wrappedValue.title)")
    }
    
    // Function to save changes back to the habit
    private func saveChanges() {
        habit.title = title
        habit.frequency = frequency
        habit.customFrequency = customFrequency
        habit.priority = priority
        habit.count = count
        habit.gradientStyle = gradientStyle
        
        isPresented = false
    }
    
    var body: some View {
        Form {
            Section(header: Text("Basic Information")) {
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Habit Name", text: Binding(
                        get: { title },
                        set: { title = String($0.prefix(titleLimit)) }
                    ))
                    
                    Text("\(title.count)/\(titleLimit)")
                        .font(.caption)
                        .foregroundColor(title.count >= titleLimit ? .red : .gray)
                }
                
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
                
                if frequency == .custom {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Custom Frequency", text: Binding(
                            get: { customFrequency },
                            set: { customFrequency = String($0.prefix(customFrequencyLimit)) }
                        ))
                        
                        Text("\(customFrequency.count)/\(customFrequencyLimit)")
                            .font(.caption)
                            .foregroundColor(customFrequency.count >= customFrequencyLimit ? .red : .gray)
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
                Stepper("Current Count: \(count)", value: $count, in: 0...Int.max)
            }
            
            Section {
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Habit")
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    isPresented = false
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    saveChanges()
                }
            }
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Habit"),
                message: Text("Are you sure you want to delete this habit? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    if let onDelete = onDelete {
                        onDelete()
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct ContentView: View {
    @State private var offset: CGSize = .zero
    @State private var lastDragPosition: CGSize = .zero
    @State private var habits: [Habit] = []
    @State private var isAddingHabit = false
    @State private var newHabitPosition: CGPoint = .zero
    @State private var habitToEdit: Habit.ID? = nil
    
    // Add computed property to check if view is moved
    private var isViewMoved: Bool {
        abs(offset.width) > 1 || abs(offset.height) > 1
    }
    
    // Add function to calculate center of all habits
    private func calculateCenterOffset(in geometry: GeometryProxy) -> CGSize {
        guard !habits.isEmpty else { return .zero }
        
        // Calculate the bounds of all habits
        let positions = habits.map { $0.position }
        let minX = positions.min { $0.x < $1.x }?.x ?? 0
        let maxX = positions.max { $0.x < $1.x }?.x ?? 0
        let minY = positions.min { $0.y < $1.y }?.y ?? 0
        let maxY = positions.max { $0.y < $1.y }?.y ?? 0
        
        // Calculate center of habits
        let centerX = (minX + maxX) / 2
        let centerY = (minY + maxY) / 2
        
        // Calculate required offset to center habits in viewport
        let screenCenterX = geometry.size.width / 2
        let screenCenterY = geometry.size.height / 2
        
        return CGSize(
            width: screenCenterX - centerX,
            height: screenCenterY - centerY
        )
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
                        HexagonHabit(
                            habit: $habit,
                            editAction: { habitToEdit = habit.id }
                        )
                        .position(x: habit.position.x, y: habit.position.y)
                    }
                }
                .offset(offset)
                
                // Updated reset position button
                if isViewMoved {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                let newOffset = calculateCenterOffset(in: geometry)
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                    offset = newOffset
                                    lastDragPosition = newOffset
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
                            .transition(.opacity)
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
            .fullScreenCover(item: $habitToEdit) { habitId in
                if let habitIndex = habits.firstIndex(where: { $0.id == habitId }) {
                    let _ = print("Showing edit form for habit: \(habits[habitIndex].title) (ID: \(habits[habitIndex].id))")
                    
                    NavigationView {
                        EditHabitForm(
                            habit: $habits[habitIndex],
                            isPresented: Binding(
                                get: { habitToEdit != nil },
                                set: { if !$0 { habitToEdit = nil }}
                            ),
                            onDelete: {
                                // Remove the habit from the array
                                habits.remove(at: habitIndex)
                                // Close the edit form
                                habitToEdit = nil
                            }
                        )
                    }
                } else {
                    Text("Could not find habit to edit")
                        .onAppear {
                            print("ERROR: Could not find habit with ID \(habitId)")
                            habitToEdit = nil
                        }
                }
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

// Add this extension after your other extensions
extension UUID: Identifiable {
    public var id: UUID {
        self
    }
}