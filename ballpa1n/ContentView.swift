//
//  ContentView.swift
//  ballpa1n
//
//  Created by Lakhan Lothiyi on 13/10/2022.
//

import SwiftUI

struct ContentView: View {
    
    @Binding var triggerRespring: Bool
    
    @State var currentStage: Int = 0
    
    @ObservedObject var c = Console.shared
    
    var body: some View {
        VStack {
            title
            
            statusbar
            
            controls
            
            disclaimer
        }
    }
    
    @ViewBuilder
    var title: some View {
        VStack {
            HStack {
                Text("ballpa1n")
                    .font(.system(size: 40, weight: .black, design: .monospaced))
                Spacer()
            }
            HStack {
                Text("\(UIDevice.current.systemName) 1.0 - \(UIDevice.current.systemVersion) Jailbreak")
                    .font(.body.monospaced())
                Spacer()
            }
        }
        .padding(4)
    }
    
    @ViewBuilder
    var statusbar: some View {
        VStack {
            HStack {
                Text("Status\n(\(currentStage)/\(jbSteps.count)) \(jbSteps[currentStage].status)")
                    .font(.callout.monospaced())
                Spacer()
            }
            
            ProgressView(value: Float(currentStage), total: Float(jbSteps.count))
                .frame(height: currentStage != 0 ? 4 : 0)
                .opacity(currentStage != 0 ? 1 : 0)
                .animation(.spring(), value: currentStage)
        }
        .padding(4)
    }
    
    @ViewBuilder
    var console: some View {
        let deviceHeight = UIScreen.main.bounds.height
        VStack {
            
        }
        .frame(height: currentStage != 0 ? (deviceHeight / 4) * 2.5 : 0)
        .opacity(currentStage != 0 ? 1 : 0)
    }
    
    @ViewBuilder
    var controls: some View {
        VStack {
            Button {
//                currentStage = 1
                respring()
            } label: {
                Text("Jailbreak")
                    .font(.title3)
                    .monospaced()
                    .foregroundColor(.white)
                    .padding()
                    .background {
                        Capsule()
                            .foregroundColor(.blue)
                    }
            }
            .buttonStyle(.plain)
            .padding()
        }
    }
    
    @ViewBuilder
    var disclaimer: some View {
        Text("Made by llsc12\nThis is a fake jailbreak, it's made for fun and because I was bored.")
            .foregroundColor(.secondary)
            .font(.system(size: 9))
            .multilineTextAlignment(.center)
    }
    
    
    func respring() {
        withAnimation(.easeInOut) {
            triggerRespring = true
        }
    }
}

class Console: ObservableObject {
    
    static let shared = Console()
    
    @Published var lines = [String]()
    
    init() {
        lines.append("wseifgorejgoir")
    }
}

let jbSteps: [StageStep] = [
    StageStep(status: "Ready to jailbreak", avgInterval: 0, consoleLogs: []),
//    StageStep(status: <#T##String#>, avgInterval: <#T##Float#>, consoleLogs: <#T##[ConsoleStep]#>)
]

struct StageStep {
    let status: String
    let avgInterval: Float
    
    let consoleLogs: [ConsoleStep]
}

struct ConsoleStep {
    let delay: Float
    let line: String
}

struct PreviewIos: PreviewProvider {
    static var previews: some View {
        ContentView(triggerRespring: .constant(false))
            .preferredColorScheme(.dark)
    }
}
