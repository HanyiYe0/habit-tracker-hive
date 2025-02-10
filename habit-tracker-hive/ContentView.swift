//
//  ContentView.swift
//  habit-tracker-hive
//
//  Created by Hanyi Ye on 2025-02-06.
//

import SwiftUI

// Add GradientStyle enum for different color combinations
enum GradientStyle {
    case orange
    case blue
    case green
    case pink
    
    var gradient: LinearGradient {
        switch self {
        case .orange:
            return LinearGradient(
                colors: [Color.orange.opacity(0.3), Color.yellow.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .blue:
            return LinearGradient(
                colors: [Color.blue.opacity(0.2), Color.cyan.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .green:
            return LinearGradient(
                colors: [Color.green.opacity(0.2), Color.mint.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .pink:
            return LinearGradient(
                colors: [Color.pink.opacity(0.2), Color.orange.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// Habit structure to store habit data
struct Habit: Identifiable {
    let id = UUID()
    var position: CGPoint
    var title: String
    var frequency: Frequency
    var gradientStyle: GradientStyle
    var startDate: Date
    var description: String
    var priority: Priority
    var count: Int
    var target: Int
    var isAnimating: Bool
    
    // Computed property for hexagon size based on priority
    var size: CGFloat {
        let baseSize: CGFloat = switch priority {
        case .high: 140
        case .medium: 120
        case .low: 100
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
    let habit: Habit
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(spacing: 4) {
            if let checkmark = habit.count >= habit.target ? Image(systemName: "checkmark") : nil {
                HStack {
                    checkmark
                        .font(.system(size: habit.size * 0.15))
                    Text("\(habit.count)")
                        .font(.system(size: habit.size * 0.2, weight: .bold))
                }
                .foregroundColor(.black)
            } else {
                Text("\(habit.count)")
                    .font(.system(size: habit.size * 0.25, weight: .bold))
                    .foregroundColor(.black)
            }
            
            Text(habit.title)
                .font(.system(size: habit.size * 0.12))
                .foregroundColor(.black.opacity(0.6))
            
            Text(habit.frequency.rawValue.lowercased())
                .font(.system(size: habit.size * 0.1))
                .foregroundColor(.black.opacity(0.4))
            
            if habit.target > 0 {
                Text("\(habit.target)○")
                    .font(.system(size: habit.size * 0.12))
                    .foregroundColor(.black.opacity(0.4))
            }
        }
        .frame(width: habit.size, height: habit.size)
        .background(
            RegularPolygon(sides: 6)
                .fill(habit.gradientStyle.gradient)
        )
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                opacity = 1
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

// Form view for adding new habits
struct AddHabitForm: View {
    @Binding var isPresented: Bool
    @Binding var habits: [Habit]
    let position: CGPoint
    
    @State private var title = ""
    @State private var frequency: Frequency = .daily
    @State private var selectedColor: Color = .blue
    @State private var startDate = Date()
    @State private var description = ""
    @State private var priority: Priority = .medium
    @State private var count: Int = 0
    @State private var target: Int = 0
    @State private var gradientStyle: GradientStyle = .orange
    
    let colors: [Color] = [.blue, .purple, .green, .orange, .pink, .teal]
    
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
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                }
                
                Section(header: Text("Appearance")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == color ? Color.black : Color.clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                                    .padding(.horizontal, 5)
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                }
                
                Section(header: Text("Additional Details")) {
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section(header: Text("Progress")) {
                    Stepper("Current Count: \(count)", value: $count)
                    Stepper("Target: \(target)", value: $target)
                }
                
                Section(header: Text("Style")) {
                    Picker("Gradient Style", selection: $gradientStyle) {
                        Text("Orange").tag(GradientStyle.orange)
                        Text("Blue").tag(GradientStyle.blue)
                        Text("Green").tag(GradientStyle.green)
                        Text("Pink").tag(GradientStyle.pink)
                    }
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
                        startDate: startDate,
                        description: description,
                        priority: priority,
                        count: count,
                        target: target,
                        isAnimating: false // Start with no animation
                    )
                    
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        habits.append(newHabit)
                        // Trigger the animation after a brief delay
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
        let baseSize = CGFloat(120)
        let maxSize = CGFloat(140)
        
        // Calculate spacing based on maximum hexagon size
        let width = maxSize * sqrt(3)
        let height = maxSize * 2
        let horizontalSpacing = width * 0.52
        let verticalSpacing = height * 0.45
        
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
            let minDistance = maxSize * 0.9 // Minimum distance between hexagon centers
            return habits.contains { habit in
                distance(habit.position, pos) < minDistance
            }
        }
        
        // Calculate positions in expanding rings
        var ring = 1
        while ring < 100 { // Reasonable limit to prevent infinite loops
            // For each ring, calculate 6 * ring positions
            for i in 0..<(6 * ring) {
                let angle = Double(i) * (Double.pi / 3) / Double(ring)
                let ringRadius = Double(ring) * Double(horizontalSpacing)
                
                // Calculate position in current ring
                let x = position.x + CGFloat(cos(angle) * ringRadius)
                let y = position.y + CGFloat(sin(angle) * ringRadius)
                let newPosition = CGPoint(x: x, y: y)
                
                // If position is not occupied, use it
                if !isPositionOccupied(newPosition) {
                    return newPosition
                }
            }
            ring += 1
        }
        
        // Fallback position (shouldn't reach here)
        return position
    }
}

struct ContentView: View {
    @State private var offset: CGSize = .zero
    @State private var lastDragPosition: CGSize = .zero
    @State private var habits: [Habit] = []
    @State private var isAddingHabit = false
    @State private var newHabitPosition: CGPoint = .zero
    
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
                    ForEach(habits) { habit in
                        HexagonHabit(habit: habit)
                            .position(x: habit.position.x, y: habit.position.y)
                    }
                }
                .offset(offset)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            // Use the pre-calculated center position
                            newHabitPosition = centerPosition
                            isAddingHabit = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
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
                    position: centerPosition // Pass the center position
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