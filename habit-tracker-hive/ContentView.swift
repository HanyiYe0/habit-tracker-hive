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
    
    // Computed property for hexagon size based on priority
    var size: CGFloat {
        switch priority {
        case .high:
            return 140
        case .medium:
            return 120
        case .low:
            return 100
        }
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
            let angle = (Double(i) * (360.0 / Double(sides))) * Double.pi / 180
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
                    let newHabit = Habit(
                        position: calculateNextPosition(),
                        title: title.isEmpty ? "New Habit" : title,
                        frequency: frequency,
                        gradientStyle: gradientStyle,
                        startDate: startDate,
                        description: description,
                        priority: priority,
                        count: count,
                        target: target
                    )
                    habits.append(newHabit)
                    isPresented = false
                }
                .disabled(title.isEmpty)
            )
        }
    }
    
    // Helper function to calculate the next position in honeycomb layout
    private func calculateNextPosition() -> CGPoint {
        let size = CGFloat(120) // Base size for hexagon
        let width = size * sqrt(3)
        let height = size * 2
        
        // Spacing between hexagons (slightly smaller than full width/height for tight packing)
        let horizontalSpacing = width * 0.95
        let verticalSpacing = height * 0.75
        
        // First habit goes in center
        if habits.isEmpty {
            return position
        }
        
        // Define the hexagonal grid coordinates for the first two rings
        let gridPositions: [(Double, Double)] = [
            // Center
            (0, 0),
            
            // First ring (6 positions)
            (1, 0),    // Right
            (0.5, -1), // Top right
            (-0.5, -1),// Top left
            (-1, 0),   // Left
            (-0.5, 1), // Bottom left
            (0.5, 1),  // Bottom right
            
            // Second ring (12 positions)
            (2, 0),    // Far right
            (1.5, -1), // Right top right
            (1, -2),   // Right top
            (0, -2),   // Top
            (-1, -2),  // Left top
            (-1.5, -1),// Left top left
            (-2, 0),   // Far left
            (-1.5, 1), // Left bottom left
            (-1, 2),   // Left bottom
            (0, 2),    // Bottom
            (1, 2),    // Right bottom
            (1.5, 1)   // Right bottom right
        ]
        
        let index = min(habits.count, gridPositions.count - 1)
        let (q, r) = gridPositions[index]
        
        // Convert axial coordinates to pixel coordinates
        let x = position.x + horizontalSpacing * CGFloat(q)
        let y = position.y + verticalSpacing * CGFloat(r)
        
        return CGPoint(x: x, y: y)
    }
}

struct ContentView: View {
    // State variables to track offset
    @State private var offset: CGSize = .zero
    @State private var lastDragPosition: CGSize = .zero
    @State private var habits: [Habit] = []
    @State private var isAddingHabit = false
    @State private var newHabitPosition: CGPoint = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background color
                Color.gray.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                
                // Content container
                ZStack {
                    // Existing habits
                    ForEach(habits) { habit in
                        HexagonHabit(habit: habit)
                            .position(x: habit.position.x, y: habit.position.y)
                    }
                }
                .offset(offset)
                
                // Add button (FAB)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            // Calculate position for new habit
                            let centerX = geometry.size.width/2 - offset.width
                            let centerY = geometry.size.height/2 - offset.height
                            newHabitPosition = CGPoint(x: centerX, y: centerY)
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
            .contentShape(Rectangle()) // Makes entire area draggable
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Move viewport in the direction of drag
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
                    position: newHabitPosition
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