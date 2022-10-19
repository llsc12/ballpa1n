//
//  ContentView.swift
//  ballpa1n
//
//  Created by Lakhan Lothiyi on 13/10/2022.
//

import SwiftUI

struct ContentView: View {
    
    @Binding var triggerRespring: Bool
    
    var body: some View {
        ScrollView {
            Text("Wow a jb happened you should respring")
            previewView()
                .frame(height: 40)
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    triggerRespring = true
                }
            } label: {
                Text("respring")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
