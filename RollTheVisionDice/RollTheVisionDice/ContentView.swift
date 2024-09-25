//
//  ContentView.swift
//  RollTheVisionDice
//
//  Created by Hiral Jotaniya on 17/09/24.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @EnvironmentObject var diceData: DiceData
    
    var body: some View {
        VStack {
            Text(diceData.rolledNumber == 0 ? "🎲" : "\(diceData.rolledNumber)")
                .foregroundColor(.yellow)
                .font(.custom("Menlo", size: 80))
                .bold()
        }
        .task {
            await openImmersiveSpace(id: "ImmersiveSpace")
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
