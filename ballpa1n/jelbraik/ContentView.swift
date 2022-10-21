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
        
        let stage = currentStage == 0 ? 0 : currentStage - 1
        let max = jbSteps.count
        VStack {
            HStack {
                Text("Status\n(\(finished ? max : stage)/\(max)) \(finished ? "Finished." : jbSteps[stage].status)")
                    .font(.system(.callout, design: .monospaced))
                Spacer()
            }
            
            ProgressView(value: finished ? Float(max) : Float(stage), total: Float(max))
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
    
    @ViewBuilder func Line(_ str: String) -> some View { HStack { Text(str).font(.system(.caption2, design: .monospaced)); Spacer() } }
    
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
        Text("Made by llsc12\nThis is a fake jailbreak, it's made for fun and because I was bored.\nTY capt inc for device info code")
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
                if step.avgInterval == 0 { waitTime = 0}
                if waitTime < 0 { waitTime = 0 }
                
                for logItem in step.consoleLogs {
                    var logWait: Double = Double(logItem.delay) + Double.random(in: -0.1...0.8)
                    if logWait < 0 { logWait = 0 }
                    usleep(UInt32(logWait * 1000000))
                    
                    Console.shared.log(logItem.line)
                    
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
                    }
                }
            }
            
            withAnimation(.spring()) {
                finished = true
            }
            Console.shared.log("[*] Finished! Please respring.")
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
        let d = HostManager.self
        let machinename = d.getModelName() ?? "Unknown"
        let modelname = d.getModelBoard() ?? "Unknown"
        let modelchip = d.getModelChip() ?? "Unknown"
        let modelarch = d.getModelArchitecture() ?? "Unknown"
        let kernname = d.getKernelName() ?? "Unknown"
        let kernver = d.getKernelVersion() ?? "Unknown"
        let kernid = d.getKernelIdentifier() ?? "Unknown"
        let platformname = d.getPlatformName() ?? "Unknown"
        let platformver = d.getPlatformVersion() ?? "Unknown"
        d.getModelChip()
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.version)
        let unamestr = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
                
        log("[*] Machine Name: \(machinename)")
        log("[*] Model Name: \(modelname)")
        log("[*] \(unamestr)")
        log("[*] System Version: \(platformname) \(platformver)")
    }
    
    public func log(_ str: String) {
        self.lines.append(str)
    }
}

let jbSteps: [StageStep] = [
    StageStep(status: "Ready to jailbreak", avgInterval: 0, consoleLogs: []),
    StageStep(status: "Ensuring resources", avgInterval: 0.8, consoleLogs: [
        ConsoleStep(delay: 0.2, line: "[*] Stage (1): Ensuring resources"),
        ConsoleStep(delay: 0.7, line: "[+] Ensured resources"),
    ]),
    StageStep(status: "Exploiting kernel", avgInterval: 0.5, consoleLogs: [
        ConsoleStep(delay: 0.2, line: "[*] Stage (2): Exploiting kernel"),
        ConsoleStep(delay: 9, line: "[+] Exploited kernel"),
    ]),
    StageStep(status: "Initializing", avgInterval: 0.1, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (3): Initializing"),
    ]),
    StageStep(status: "Finding kernel slide", avgInterval: 0.1, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (4): Finding kernel slide"),
        ConsoleStep(delay: 0, line: "[+] Found kernel slide: 0x8d8c000"),
    ]),
    StageStep(status: "Finding kernel offsets", avgInterval: 0.1, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (5): Finding kernel offsets"),
        ConsoleStep(delay: 0, line: "[+] Found kernel offsets"),
    ]),
    StageStep(status: "Finding data structures", avgInterval: 0.1, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (6): Finding data structures"),
        ConsoleStep(delay: 0, line: "[+] Found data structures"),
    ]),
    StageStep(status: "Finding kernel offsets", avgInterval: 0.1, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (7): Finding kernel offsets"),
        ConsoleStep(delay: 0, line: "[+] Found kernel offsets"),
    ]),
    StageStep(status: "Obtaining root privileges", avgInterval: 0.1, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (8): Obtaining root privileges"),
        ConsoleStep(delay: 0, line: "[+] Obtained root privileges"),
    ]),
    StageStep(status: "Disabling sandbox", avgInterval: 0.1, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (9): Disabling sandbox"),
        ConsoleStep(delay: 0, line: "[+] Disabled sandbox"),
    ]),
    StageStep(status: "Updating host port", avgInterval: 0.1, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (10): Updating host port"),
        ConsoleStep(delay: 0, line: "[+] Updated host port"),
    ]),
    StageStep(status: "Finding kernel offsets", avgInterval: 0.1, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (11): Finding kernel offsets"),
        ConsoleStep(delay: 0, line: "[+] Found kernel offsets"),
    ]),
    StageStep(status: "Enabling dynamic codesign", avgInterval: 0.1, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (12): Enabling dynamic codesign"),
        ConsoleStep(delay: 0, line: "[+] Enabled dynamic codesign"),
    ]),
    StageStep(status: "", avgInterval: 0, consoleLogs: []),
    StageStep(status: "", avgInterval: 0, consoleLogs: []),
    StageStep(status: "", avgInterval: 0, consoleLogs: []),
    StageStep(status: "Saving kernel primitives", avgInterval: 0.1, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (16): Saving kernel primitives"),
        ConsoleStep(delay: 0, line: "[+] Saved kernel primitives"),
    ]),
    StageStep(status: "", avgInterval: 0, consoleLogs: []),
    StageStep(status: "Disabling codesigning", avgInterval: 0.1, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (18): Disabling codesigning"),
        ConsoleStep(delay: 0, line: "[+] Disabled codesigning"),
    ]),
    StageStep(status: "Obtaining entitlements", avgInterval: 0.1, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (19): Obtaining entitlements"),
        ConsoleStep(delay: 0, line: "[+] Obtained entitlements"),
    ]),
    StageStep(status: "Purging software updates", avgInterval: 0.1, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (20): Purging software updates"),
        ConsoleStep(delay: 0, line: "[+] Purged software updates"),
    ]),
    StageStep(status: "Setting boot-nonce generator", avgInterval: 0.1, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (21): Setting boot-nonce generator"),
        ConsoleStep(delay: 0, line: "[+] Set boot-nonce generator"),
    ]),
    StageStep(status: "Remounting root filesystem", avgInterval: 0.1, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (22): Remounting root filesystem"),
        ConsoleStep(delay: 0, line: "[+] Remounted root filesystem"),
    ]),
    StageStep(status: "Preparing filesystem", avgInterval: 0.1, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (23): Preparing filesystem"),
        ConsoleStep(delay: 0.1, line: "[+] Enabled code substitution"),
        ConsoleStep(delay: 0, line: "[+] Prepared filesystem"),
    ]),
    StageStep(status: "Resolving dependencies", avgInterval: 0.1, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (24): Resolving dependencies"),
        ConsoleStep(delay: 0.2, line: """
[*] Resource Pkgs: "(
bzip2,
"coreutils-bin",
diffutils,
file,
sed,
findutils,
gzip,
libplist3,
firmware,
"ca-certificates",
"libssl1.1.1",
ldid,
lzma,
"ncurses5-libs"
"profile.d",
coreutils,
ncurses,
XZ,
tar,
dpkg,
grep,
readline,
bash,
launchctl,
"com.ex.substitute"
)
"""),
        ConsoleStep(delay: 0.1, line: "[+] Resolved dependencies")
    ]),
    StageStep(status: "Verifying dependencies", avgInterval: 0.1, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (25): Verifying dependencies"),
        ConsoleStep(delay: 1.5, line: "[+] File checksums verified"),
        ConsoleStep(delay: 0, line: "[*] No errors in verifying checksums"),
    ]),
    StageStep(status: "Unknown", avgInterval: 0.1, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (26): Unknown"),
    ]),
    StageStep(status: "Preparing resources", avgInterval: 0.5, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (27): Preparing resources"),
        ConsoleStep(delay: 0.2, line: "[+] Unpacking"),
    ]),
    StageStep(status: "Unknown", avgInterval: 0.1, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (28): Unknown"),
    ]),
    StageStep(status: "Bootstrapping resources", avgInterval: 1, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (29): Bootstrapping resources"),
        ConsoleStep(delay: 0.4, line: "[+] Copying resources"),
    ]),
    StageStep(status: "Running pen1ledefunc untether(er)", avgInterval: 0.1, consoleLogs: [
        ConsoleStep(delay: 2, line: "[*] Stage (30): Running pen1le3xplo1t"),
        ConsoleStep(delay: 0.5, line: "[*] Stage (31): Ensuring utethered boot")
    ]),
    StageStep(status: "Cleaning up", avgInterval: 1, consoleLogs: [
        ConsoleStep(delay: 0.1, line: "[*] Stage (31): Cleaning up"),
        ConsoleStep(delay: 0.2, line: "[+] Removing temporary files"),
    ]),
]

#warning("Unknown on 26")

#warning("Unknown on 28")

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
