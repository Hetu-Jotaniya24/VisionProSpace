//
//  ImmersiveView.swift
//  RollTheVisionDice
//
//  Created by Hiral Jotaniya on 17/09/24.
//

import SwiftUI
import RealityKit

let diceMap = [
    // + | -
    [1, 6], //x
    [4, 3], //y
    [2, 5] //z
]

struct ImmersiveView: View {
    @State var droppedDice = false
    @EnvironmentObject var diceData: DiceData
    var body: some View {
        RealityView { content in
                /// to create more collusion shape
            let floor = ModelEntity(mesh: .generatePlane(width: 100, depth: 100), materials: [OcclusionMaterial()])
            floor.generateCollisionShapes(recursive: false)
            floor.components[PhysicsBodyComponent.self] = .init(PhysicsBodyComponent(
                massProperties: .default,
                mode: .static /* object to fall to the ground*/)
            )
            content.add(floor)
            
            if let diceModel = try? await Entity(named: "dice"),
               let dice = diceModel.children.first?.children.first,
               let environment = try? await EnvironmentResource(named: "studio") {
                dice.scale = [0.1, 0.1, 0.1]
                dice.position.y = 0.5
                dice.position.z = -1
                
                    ///When dice touches the ground it will have the dice box  be collidable
                dice.generateCollisionShapes(recursive: false)
                
                    ///To make it draggable
                dice.components.set(InputTargetComponent())
                
                    ///To make dice brighter
                dice.components.set(ImageBasedLightComponent(source: .single(environment)))
                dice.components.set(ImageBasedLightReceiverComponent(imageBasedLight: dice))
                    ///To add shadow below dice object
                dice.components.set(GroundingShadowComponent(castsShadow: true))
                    //
                
                    ///To make an object like it is falling on the ground
                dice.components[PhysicsBodyComponent.self] =  .init(PhysicsBodyComponent(
                    massProperties: .default,
                    material: .generate(staticFriction: 0.8,
                                        dynamicFriction: 0.5,
                                        restitution: 0.1 /*How bouncy it would be*/),
                    mode: .dynamic /* object to fall to the ground*/)
                )
                
                dice.components[PhysicsMotionComponent.self] = .init()
                content.add(dice)
                
                    ///Subscribe to a scene - so it will constantly provide an updates regarding changes
                let _ = content.subscribe(to: SceneEvents.Update.self) { event in
                    guard droppedDice else { return }
                    guard let diceMotion = dice.components[PhysicsMotionComponent.self] else { return }
                    
                    if simd_length(diceMotion.linearVelocity) < 0.1 && simd_length(diceMotion.angularVelocity) < 0.1 {
                        let xDirection = dice.convert(direction:SIMD3(x: 1, y: 0, z: 0), to: nil)
                        let yDirection = dice.convert(direction:SIMD3(x: 0, y: 1, z: 0), to: nil)
                        let zDirection = dice.convert(direction:SIMD3(x: 0, y: 0, z: 1), to: nil)
                        
                        let greatestDirection = [
                            0: xDirection.y,
                            1: yDirection.y,
                            2: zDirection.y
                        ]
                            //Take absolute positive number of first value and compare it with next
                            .sorted(by: { abs($0.1) > abs($1.1) }).first
                        if let direction = greatestDirection {
                            diceData.rolledNumber = diceMap[direction.key][direction.value > 0 ? 0 : 1]
                            print("rolled number data", diceData.rolledNumber)
                        }
                    }
                }
            }
        }
        .gesture(dragGesture)
    }
    
        ///For Pick and drop
    var dragGesture: some Gesture {
        DragGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                value.entity.position = value.convert(value.location3D, from: .local, to: value.entity.parent!)
                value.entity.components[PhysicsBodyComponent.self]?.mode = .kinematic
            }
            .onEnded { value in
                value.entity.components[PhysicsBodyComponent.self]?.mode = .dynamic
                if !droppedDice {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                        droppedDice = true
                    }
                }
            }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}
