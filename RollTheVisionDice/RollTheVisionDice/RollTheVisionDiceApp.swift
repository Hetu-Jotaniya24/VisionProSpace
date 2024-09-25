//
//  VisionProDemoApp.swift
//  RollTheVisionDice
//
//  Created by Hiral Jotaniya on 17/09/24.
//

import SwiftUI

class DiceData : ObservableObject {
    @Published var rolledNumber = 0
}

@main
struct VisionProDemoApp: App {
    @StateObject private var diceData = DiceData()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(diceData)
        }
        .defaultSize(width: 200, height: 200)
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environmentObject(diceData)
            
        }
    }
}
