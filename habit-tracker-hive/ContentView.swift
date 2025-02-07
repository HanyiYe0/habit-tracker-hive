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
                // Background color or content
                Color.gray.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                
                // Content that will be draggable
                VStack {
                    Text("Drag anywhere to move")
                        .font(.headline)
                    // Add more content here as needed
                }
                .offset(offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Calculate new offset based on drag
                            let newOffset = CGSize(
                                width: lastDragPosition.width + value.translation.width,
                                height: lastDragPosition.height + value.translation.height
                            )
                            offset = newOffset
                        }
                        .onEnded { value in
                            // Store the final position
                            lastDragPosition = offset
                        }
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
