//
//  ContentView.swift
//  habit-tracker-hive
//
//  Created by Hanyi Ye on 2025-02-06.
//

import SwiftUI

// Habit structure to store habit data
struct Habit: Identifiable {
    let id = UUID()
    var position: CGPoint
    var title: String
    var frequency: Frequency
    var color: Color
    var startDate: Date
    var description: String
}

// Frequency options for habits
enum Frequency: String, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case custom = "Custom"
}

// Hexagon habit view
struct HexagonHabit: View {
    let habit: Habit
    
    var body: some View {
        VStack {
            Text(habit.title)
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
            Text(habit.frequency.rawValue)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .padding(20)
        .background(
            RegularPolygon(sides: 6)
                .fill(habit.color.opacity(0.2))
                .frame(width: 100, height: 100)
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
    
    let colors: [Color] = [.blue, .purple, .green, .orange, .pink, .teal]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Habit Name", text: $title)
                    
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
            }
            .navigationTitle("New Habit")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Add") {
                    let newHabit = Habit(
                        position: position,
                        title: title.isEmpty ? "New Habit" : title,
                        frequency: frequency,
                        color: selectedColor,
                        startDate: startDate,
                        description: description
                    )
                    habits.append(newHabit)
                    isPresented = false
                }
                .disabled(title.isEmpty)
            )
        }
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
