//
//  GameScene.swift
//  space-invaders
//
//  Created by Arturo Carretero Calvo on 16/2/24.
//

import SpriteKit

enum BulletType {
    case shipFired
    case invaderFired
}

enum InvaderMovementDirection {
    case right
    case left
    case downThenRight
    case downThenLeft
}

enum InvaderType: String {
    case invaderA
    case invaderB
    case invaderC
}

enum Nodes: String {
    case firePad
    case invaderFiredBullet
    case joystick
    case joystickBase
    case scoreHud
    case ship
    case shipFiredBullet
}

class GameScene: SKScene {
    // MARK: - Properties

    var invaderMovementDirection: InvaderMovementDirection = .right
    var timeOfLastMove: CFTimeInterval = 0
    var timePerMove: CFTimeInterval = 1
    var score: Int = 0
    var selectedNodes: [UITouch: SKSpriteNode] = [:]
    var joystickIsActive = false
    var playerVelocityX: CGFloat = 0

    let joystickBase = SKSpriteNode(imageNamed: Constants.Images.joystickBase)
    let joystick = SKSpriteNode(imageNamed: Constants.Images.joystick)
    let firePad = SKSpriteNode(imageNamed: Constants.Images.firePad)
    let ship = SKSpriteNode(imageNamed: Constants.Images.ship)

    // MARK: - Life's cycle

    override func didMove(to view: SKView) {
        backgroundColor = .black

        physicsWorld.contactDelegate = self

        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody!.categoryBitMask = Constants.Physics.sceneEdgeCategory

        createScoreboard()
        createPlayerControls()
        createInvaders()
        createShip()
    }

    override func update(_ currentTime: TimeInterval) {
        let isGameOver = isGameOver()

        if isGameOver.endGame {
            routeToGameOverScene(isGameOver.isWin)
        } else {
            moveInvaders(forUpdate: currentTime)
            fireInvaderBullets(forUpdate: currentTime)

            if joystickIsActive {
                ship.position = CGPointMake(ship.position.x - (playerVelocityX * 3), ship.position.y)
            }
        }
    }

    // MARK: - Private

    private func createScoreboard() {
        let scoreLabel = SKLabelNode(fontNamed: Constants.Fonts.courier)
        scoreLabel.name = Nodes.scoreHud.rawValue
        scoreLabel.fontSize = 25
        scoreLabel.fontColor = .red
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.text = String(format: NSLocalizedString("game.scene.score.text", comment: ""), 0)
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - (60 + scoreLabel.frame.size.height))

        addChild(scoreLabel)
    }

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

    private func createInvaders() {
        let baseOrigin = CGPoint(x: size.width / 3, y: size.height / 1.35)

        for row in 0..<Constants.General.invaderRowCount {
            var invaderType: InvaderType

            if row % 3 == 0 {
                invaderType = .invaderA
            } else if row % 3 == 1 {
                invaderType = .invaderB
            } else {
                invaderType = .invaderC
            }

            let invaderPositionY = CGFloat(row) * (Constants.General.invaderSize.height * 2) + baseOrigin.y

            var invaderPosition = CGPoint(x: baseOrigin.x, y: invaderPositionY)

            for _ in 1..<Constants.General.invaderColCount {
                let invader = makeInvader(ofType: invaderType)
                invader.position = invaderPosition

                addChild(invader)

                invaderPosition = CGPoint(
                    x: invaderPosition.x + Constants.General.invaderSize.width + Constants.General.invaderGridSpacing.width,
                    y: invaderPositionY
                )
            }
        }
    }

    private func makeInvader(ofType invaderType: InvaderType) -> SKNode {
        var prefix: String

        switch invaderType {
        case .invaderA:
            prefix = InvaderType.invaderA.rawValue
        case .invaderB:
            prefix = InvaderType.invaderB.rawValue
        case .invaderC:
            prefix = InvaderType.invaderC.rawValue
        }

        let invaderTextures = [SKTexture(imageNamed: String(format: "%@_00", prefix)),
                               SKTexture(imageNamed: String(format: "%@_01", prefix))]
        let invader = SKSpriteNode(texture: invaderTextures[0])
        invader.name = Constants.General.invaderName
        invader.run(SKAction.repeatForever(SKAction.animate(with: invaderTextures, timePerFrame: timePerMove)))
        invader.physicsBody = SKPhysicsBody(rectangleOf: invader.frame.size)
        invader.physicsBody!.isDynamic = false
        invader.physicsBody!.categoryBitMask = Constants.Physics.invaderCategory
        invader.physicsBody!.contactTestBitMask = 0x0
        invader.physicsBody!.collisionBitMask = 0x0

        return invader
    }

    func createShip() {
        ship.name = Nodes.ship.rawValue
        ship.physicsBody = SKPhysicsBody(rectangleOf: ship.frame.size)
        ship.physicsBody!.isDynamic = true
        ship.physicsBody!.affectedByGravity = false
        ship.physicsBody!.mass = 0.02
        ship.physicsBody!.categoryBitMask = Constants.Physics.shipCategory
        ship.physicsBody!.contactTestBitMask = 0x0
        ship.physicsBody!.collisionBitMask = Constants.Physics.sceneEdgeCategory
        ship.position = CGPoint(x: size.width / 2.0,
                                y: Constants.General.shipSize.height / 2.0 + joystickBase.position.y + joystick.frame.height)

        addChild(ship)
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
                        fireShipBullets()
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

// MARK: - SKPhysicsContactDelegate

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil {
            return
        }

        let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]

        if nodeNames.contains(Nodes.ship.rawValue) && nodeNames.contains(Nodes.invaderFiredBullet.rawValue) {
            run(SKAction.playSoundFileNamed(Constants.Sounds.ship, waitForCompletion: false))

            contact.bodyA.node!.removeFromParent()
            contact.bodyB.node!.removeFromParent()
        } else if nodeNames.contains(Constants.General.invaderName) && nodeNames.contains(Nodes.shipFiredBullet.rawValue) {
            run(SKAction.playSoundFileNamed(Constants.Sounds.invader, waitForCompletion: false))

            contact.bodyA.node!.removeFromParent()
            contact.bodyB.node!.removeFromParent()

            addPointsToScoreboard(by: 100)
        } else if nodeNames.contains(Constants.General.invaderName) && nodeNames.contains(Nodes.ship.rawValue) {
            run(SKAction.playSoundFileNamed(Constants.Sounds.ship, waitForCompletion: false))

            routeToGameOverScene(false)
        }
    }
}

// MARK: - Private

private extension GameScene {
    func addPointsToScoreboard(by points: Int) {
        score += points

        if let score = childNode(withName: Nodes.scoreHud.rawValue) as? SKLabelNode {
            score.text = String(format: NSLocalizedString("game.scene.score.text", comment: ""), self.score)
        }

        ScoreManager.saveScore(score)
    }
    
    func moveInvaders(forUpdate currentTime: CFTimeInterval) {
        if currentTime - timeOfLastMove < timePerMove {
            return
        }

        determineInvaderMovementDirection()

        enumerateChildNodes(withName: Constants.General.invaderName) { node, stop in
            switch self.invaderMovementDirection {
            case .right:
                node.position = CGPoint(x: node.position.x + 10, y: node.position.y)
            case .left:
                node.position = CGPoint(x: node.position.x - 10, y: node.position.y)
            case .downThenLeft, .downThenRight:
                node.position = CGPoint(x: node.position.x, y: node.position.y - 10)
            }

            self.timeOfLastMove = currentTime
        }
    }

    func determineInvaderMovementDirection() {
        var proposedMovementDirection: InvaderMovementDirection = invaderMovementDirection

        enumerateChildNodes(withName: Constants.General.invaderName) { node, stop in
            switch self.invaderMovementDirection {
            case .right:
                if node.frame.maxX >= node.scene!.size.width - 1.0 {
                    proposedMovementDirection = .downThenLeft

                    self.adjustInvaderMovement(to: self.timePerMove * 0.8)

                    stop.pointee = true
                }
            case .left:
                if node.frame.minX <= 1.0 {
                    proposedMovementDirection = .downThenRight

                    self.adjustInvaderMovement(to: self.timePerMove * 0.8)

                    stop.pointee = true
                }
            case .downThenLeft:
                proposedMovementDirection = .left

                stop.pointee = true
            case .downThenRight:
                proposedMovementDirection = .right

                stop.pointee = true
            }
        }

        if proposedMovementDirection != invaderMovementDirection {
            invaderMovementDirection = proposedMovementDirection
        }
    }

    func adjustInvaderMovement(to timePerMove: CFTimeInterval) {
        if self.timePerMove <= 0 {
            return
        }

        let ratio = CGFloat(self.timePerMove / timePerMove)

        self.timePerMove = timePerMove

        enumerateChildNodes(withName: Constants.General.invaderName) { node, stop in
            node.speed = node.speed * ratio
        }
    }

    func fireInvaderBullets(forUpdate currentTime: CFTimeInterval) {
        let existingBullet = childNode(withName: Nodes.invaderFiredBullet.rawValue)

        if existingBullet == nil {
            var allInvaders = [SKNode]()

            enumerateChildNodes(withName: Constants.General.invaderName) { node, stop in
                allInvaders.append(node)
            }

            if allInvaders.count > 0 {
                let allInvadersIndex = Int(arc4random_uniform(UInt32(allInvaders.count)))
                let invader = allInvaders[allInvadersIndex]

                let bullet = makeBullet(ofType: .invaderFired)
                bullet.position = CGPoint(
                    x: invader.position.x,
                    y: invader.position.y - invader.frame.size.height / 2 + bullet.frame.size.height / 2
                )

                let bulletDestination = CGPoint(x: invader.position.x, y: -(bullet.frame.size.height / 2))

                fireBullet(
                    bullet: bullet,
                    toDestination: bulletDestination,
                    withDuration: 2.0,
                    andSoundFileName: Constants.Sounds.invaderBullet
                )
            }
        }
    }

    func fireShipBullets() {
        let existingBullet = childNode(withName: Nodes.shipFiredBullet.rawValue)

        if existingBullet == nil {
            if let ship = childNode(withName: Nodes.ship.rawValue) {
                let bullet = makeBullet(ofType: .shipFired)
                bullet.position = CGPoint(
                    x: ship.position.x,
                    y: ship.position.y + ship.frame.size.height - bullet.frame.size.height / 2
                )

                let bulletDestination = CGPoint(
                    x: ship.position.x,
                    y: frame.size.height + bullet.frame.size.height / 2
                )

                fireBullet(
                    bullet: bullet,
                    toDestination: bulletDestination,
                    withDuration: 1.0,
                    andSoundFileName: Constants.Sounds.shipBullet
                )
            }
        }
    }

    func makeBullet(ofType bulletType: BulletType) -> SKNode {
        var bullet: SKNode

        switch bulletType {
        case .shipFired:
            bullet = SKSpriteNode(color: .green, size: Constants.General.bulletSize)
            bullet.name = Nodes.shipFiredBullet.rawValue
            bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
            bullet.physicsBody!.isDynamic = true
            bullet.physicsBody!.affectedByGravity = false
            bullet.physicsBody!.categoryBitMask = Constants.Physics.shipFiredBulletCategory
            bullet.physicsBody!.contactTestBitMask = Constants.Physics.invaderCategory
            bullet.physicsBody!.collisionBitMask = 0x0
        case .invaderFired:
            bullet = SKSpriteNode(color: .magenta, size: Constants.General.bulletSize)
            bullet.name = Nodes.invaderFiredBullet.rawValue
            bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
            bullet.physicsBody!.isDynamic = true
            bullet.physicsBody!.affectedByGravity = false
            bullet.physicsBody!.categoryBitMask = Constants.Physics.invaderFiredBulletCategory
            bullet.physicsBody!.contactTestBitMask = Constants.Physics.shipCategory
            bullet.physicsBody!.collisionBitMask = 0x0
        }

        return bullet
    }

    func fireBullet(bullet: SKNode,
                    toDestination destination: CGPoint,
                    withDuration duration: CFTimeInterval,
                    andSoundFileName soundName: String) {
        let bulletAction = SKAction.sequence([
            SKAction.move(to: destination, duration: duration),
            SKAction.wait(forDuration: 3.0 / 60.0),
            SKAction.removeFromParent()
        ])

        let soundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)

        bullet.run(SKAction.group([bulletAction, soundAction]))

        addChild(bullet)
    }

    func isGameOver() -> (endGame: Bool, isWin: Bool) {
        var invaderTooLow = false

        let invader = childNode(withName: Constants.General.invaderName)
        let ship = childNode(withName: Nodes.ship.rawValue)

        enumerateChildNodes(withName: Constants.General.invaderName) { node, stop in
            if Float(node.frame.minY) <= Constants.General.minInvaderBottomHeight {
                invaderTooLow = true
                stop.pointee = true
            }
        }

        let endGame = invader == nil || invaderTooLow || ship == nil
        let isWin = invader == nil

        return (endGame, isWin)
    }

    func routeToGameOverScene(_ isWin: Bool) {
        view?.presentScene(GameOverScene(size: size, isWin: isWin), transition: .crossFade(withDuration: 0.5))
    }
}
