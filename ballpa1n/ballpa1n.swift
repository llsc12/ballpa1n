//
//  ballpa1nApp.swift
//  ballpa1n
//
//  Created by Lakhan Lothiyi on 13/10/2022.
//

import SwiftUI
import Foundation

@main
struct ballpa1nApp: App {
    
    @State var triggerRespring = false
    
    var body: some Scene {
        WindowGroup {
            ContentView(triggerRespring: $triggerRespring)
                .preferredColorScheme(triggerRespring ? .dark : .none)
                .scaleEffect(triggerRespring ? 0.95 : 1)
                .brightness(triggerRespring ? -1 : 0)
                #if os(iOS) || os(iPadOS) || os(tvOS) || os(watchOS)
                    .statusBarHidden(triggerRespring)
                #endif
                .onChange(of: triggerRespring) { _ in
                    if triggerRespring == true {
                    #if os(iOS)
                        
                        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
                            
                            // TY amy for respring bug
                            guard let window = UIApplication.shared.windows.first else { return }
                            while true {
                               window.snapshotView(afterScreenUpdates: false)
                            }
                            
                        }
                    #endif
                    }
                }
        }
    }
}
