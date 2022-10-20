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
    @State var finished = false
    
    @ObservedObject var c = Console.shared
    
    var body: some View {
        VStack {
            title
            
            statusbar
            
            console
            
            controls
            
            disclaimer
        }
        .onAppear {
            HostManagerModelName(<#T##Int8#>)
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
                    .font(.system(.body, design: .monospaced))
                Spacer()
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    var statusbar: some View {
        VStack {
            HStack {
                Text("Status\n(\(currentStage)/\(jbSteps.count)) \(jbSteps[currentStage].status)")
                    .font(.system(.callout, design: .monospaced))
                Spacer()
            }
            
            ProgressView(value: Float(currentStage), total: Float(jbSteps.count))
                .frame(height: currentStage != 0 ? 4 : 0)
                .opacity(currentStage != 0 ? 1 : 0)
                .animation(.spring(), value: currentStage)
        }
        .padding(.vertical, 4)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    var console: some View {
        let deviceHeight = UIScreen.main.bounds.height
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(0..<c.lines.count, id: \.self) { i in
                    let item = c.lines[i]
                    
                    Line(item)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(4)
            .flipped()
        }
        .frame(height: currentStage != 0 ? deviceHeight / 4 : 0)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .foregroundColor(Color("ConsoleBG"))
        )
        .opacity(currentStage != 0 ? 1 : 0)
        .padding(.horizontal)
        .flipped()
    }
    
    @ViewBuilder func Line(_ str: String) -> some View { HStack { Text(str).font(.system(.body, design: .monospaced)); Spacer() } }
    
    @ViewBuilder
    var controls: some View {
        VStack {
            Button {
                if finished {
                    respring()
                } else {
                    beginJB()
                }
            } label: {
                Text(currentStage == 0 ? "Jailbreak" : finished ? "Respring" : "Jailbreaking")
                    .font(.system(.title3, design: .monospaced))
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Capsule()
                            .foregroundColor(.blue)
                    )
            }
            .buttonStyle(.plain)
            .disabled(finished ? false : currentStage != 0)
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
    
    func beginJB() {
        // cool system to iterate through jbSteps array
        DispatchQueue.global().async {
            withAnimation(.spring()) { currentStage+=1 }
            let max = (jbSteps.count - 1)
            
            var canIncrement = false
            
            for step in jbSteps {
                var waitTime: Double = Double(step.avgInterval) + Double.random(in: -0.2...1)
                if waitTime < 0 { waitTime = 0 }
                
                for logItem in step.consoleLogs {
                    var logWait: Double = Double(logItem.delay) + Double.random(in: -0.1...0.8)
                    if logWait < 0 { logWait = 0 }
                    usleep(UInt32(logWait * 1000000))
                    
                    Console.shared.lines.append(logItem.line)
                    
                    if logItem == step.consoleLogs.last! {
                        canIncrement = true
                    }
                }
                
                if step.consoleLogs.isEmpty { canIncrement = true }
                
                usleep(UInt32(waitTime * 1000000))
                
                withAnimation(.spring()) {
                    if currentStage != max {
                        while !canIncrement {
                            Thread.sleep(forTimeInterval: 0.02)
                        }
                        canIncrement = false
                        currentStage+=1
                    } else {
                        finished = true
                    }
                }
            }
        }
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

func wait(_ time: Double) async {
    await withCheckedContinuation { continuation in
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
            continuation.resume()
        })
    }
}

let jbSteps: [StageStep] = [
    StageStep(status: "Ready to jailbreak", avgInterval: 0, consoleLogs: []),
    StageStep(status: "Ensuring resources", avgInterval: 0.8, consoleLogs: [
        ConsoleStep(delay: 0.2, line: "[*] Ensuring resources"),
        ConsoleStep(delay: 0.7, line: "[+] Ensured resources"),
    ]),
    StageStep(status: "Ensuring resources2", avgInterval: 1, consoleLogs: [
        ConsoleStep(delay: 0.2, line: "[*] Ensuring resources"),
        ConsoleStep(delay: 0.7, line: "[+] Ensured resources"),
    ]),
    StageStep(status: "Ensuring resources3", avgInterval: 1, consoleLogs: [
        ConsoleStep(delay: 0.2, line: "[*] Ensuring resources"),
        ConsoleStep(delay: 0.7, line: "[+] Ensured resources"),
    ]),
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

extension ConsoleStep: Equatable {
    static func == (lhs: ConsoleStep, rhs: ConsoleStep) -> Bool {
        return lhs.delay == rhs.delay && lhs.line == rhs.line
    }
}

struct PreviewIos: PreviewProvider {
    static var previews: some View {
        ContentView(triggerRespring: .constant(false))
            .preferredColorScheme(.dark)
    }
}


struct FlipView: ViewModifier {
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(180))
    }
}

extension View {
    func flipped() -> some View {
        modifier(FlipView())
    }
}
