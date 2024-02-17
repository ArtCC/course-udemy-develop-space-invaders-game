//
//  GameScene.swift
//  space-invaders
//
//  Created by Arturo Carretero Calvo on 16/2/24.
//

import SpriteKit
import GameplayKit

enum Nodes: String {
    case firePad
    case joystick
    case joystickBase
}

class GameScene: SKScene {
    // MARK: - Properties

    var selectedNodes: [UITouch: SKSpriteNode] = [:]
    var joystickIsActive = false
    var playerVelocityX: CGFloat = 0

    let joystickBase = SKSpriteNode(imageNamed: Constants.Images.joystickBase)
    let joystick = SKSpriteNode(imageNamed: Constants.Images.joystick)
    let firePad = SKSpriteNode(imageNamed: Constants.Images.firePad)

    // MARK: - Life's cycle

    override func didMove(to view: SKView) {
        backgroundColor = .black

        createPlayerControls()
    }

    override func update(_ currentTime: TimeInterval) {
    }

    // MARK: - Private

    private func createPlayerControls() {
        joystickBase.name = Nodes.joystickBase.rawValue
        joystickBase.position = CGPoint(x: 80, y: 80)
        joystickBase.zPosition = 5.0
        joystickBase.alpha = 0.2
        joystickBase.setScale(0.3)

        joystick.name = Nodes.joystick.rawValue
        joystick.position = joystickBase.position
        joystick.zPosition = 6.0
        joystick.alpha = 0.5
        joystick.setScale(0.20)

        firePad.name = Nodes.firePad.rawValue
        firePad.anchorPoint = CGPoint(x: 1.0, y: 0.0)
        firePad.position = CGPoint(x: frame.size.width - 50, y: joystick.position.y - joystick.frame.size.height / 2)
        firePad.zPosition = 6.0
        firePad.alpha = 0.5
        firePad.setScale(0.20)

        addChild(joystickBase)
        addChild(joystick)
        addChild(firePad)
    }
}

// MARK: - UITouch

extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)

            if let node = atPoint(touchLocation) as? SKSpriteNode {
                if node.name == Nodes.joystick.rawValue {
                    if CGRectContainsPoint(joystick.frame, touchLocation) {
                        joystickIsActive = true
                    } else {
                        joystickIsActive = false
                    }
                    selectedNodes[touch] = node
                } else if node.name == Nodes.firePad.rawValue {
                    if let touch = touches.first, touch.tapCount == 1 {
                        print("Disparo del jugador")
                    }
                }
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)

            if let node = selectedNodes[touch], node.name == Nodes.joystick.rawValue, joystickIsActive {
                let vector = CGVector(dx: touchLocation.x - joystickBase.position.x,
                                      dy: touchLocation.y - joystickBase.position.y)
                let angle = atan2(vector.dy, vector.dx)
                let radio: CGFloat = joystickBase.frame.size.height / 2

                let distance = min(sqrt(vector.dx * vector.dx + vector.dy * vector.dy), radio)
                let xDist: CGFloat = distance * cos(angle)

                joystick.position = CGPoint(x: joystickBase.position.x + xDist, y: joystickBase.position.y)

                let xDistPlayer: CGFloat = sin(angle - 1.57079633) * radio

                playerVelocityX = xDistPlayer / radio
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if selectedNodes[touch] != nil {
                if joystickIsActive {
                    let defaultPosition = SKAction.move(to: joystickBase.position, duration: 0.05)
                    defaultPosition.timingMode = SKActionTimingMode.easeOut

                    joystick.run(defaultPosition)

                    joystickIsActive = false

                    playerVelocityX = 0
                }

                selectedNodes[touch] = nil
            }
        }
    }
}
