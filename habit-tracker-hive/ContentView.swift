//
//  ContentView.swift
//  habit-tracker-hive
//
//  Created by Hanyi Ye on 2025-02-06.
//

import SwiftUI

struct ContentView: View {
    // State variables to track offset
    @State private var offset: CGSize = .zero
    @State private var lastDragPosition: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background color
                Color.gray.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                
                // Content container that moves opposite to drag direction
                // to create the illusion of viewport movement
                ZStack {
                    // Example fixed content - add your content here
                    ForEach(0..<5) { row in
                        ForEach(0..<5) { column in
                            Text("Item (\(row), \(column))")
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                                .position(
                                    x: CGFloat(column) * 200 + geometry.size.width/2,
                                    y: CGFloat(row) * 200 + geometry.size.height/2
                                )
                        }
                    }
                }
                .offset(offset)
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
        }
    }
}

// Preview provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
