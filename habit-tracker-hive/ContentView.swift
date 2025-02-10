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
        
        // Calculate spacing for tight hexagonal packing
        let horizontalSpacing = size * 1.1  // Adjusted for tighter horizontal packing
        let verticalSpacing = size * 0.95   // Adjusted for tighter vertical packing
        
        // Define the exact grid coordinates matching the image pattern
        let gridPositions: [(Double, Double)] = [
            (0, 0),        // 1 (center)
            (1, -1),       // 2
            (2, -1),       // 3
            (2, 0),        // 4
            (1, 1),        // 5
            (0, 1),        // 6
            (-1, 0),       // 7
            (-1, -1),      // 8
            (3, -1),       // 9
            (3, 0),        // 10
            (3, 1),        // 11
            (2, 2),        // 12
            (1, 2),        // 13
            (0, 2),        // 14
            (-1, 2),       // 15
            (-2, 1),       // 16
            (-2, 0),       // 17
            (-2, -1),      // 18
            (-1, -2)       // 19
        ]
        
        let index = habits.count
        let (q, r) = gridPositions[min(index, gridPositions.count - 1)]
        
        // For the first habit, return exactly the center position
        if index == 0 {
            return position
        }
        
        // For subsequent habits, calculate position relative to center
        let x = position.x + horizontalSpacing * CGFloat(q)
        let y = position.y + verticalSpacing * CGFloat(r)
        
        return CGPoint(x: x, y: y)
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