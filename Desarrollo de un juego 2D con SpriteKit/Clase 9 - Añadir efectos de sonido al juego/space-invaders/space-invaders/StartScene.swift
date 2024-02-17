//
//  StartScene.swift
//  space-invaders
//
//  Created by Arturo Carretero Calvo on 16/2/24.
//

import SpriteKit

class StartScene: SKScene {
    // MARK: - Life's cycle

    override func didMove(to view: SKView) {
        backgroundColor = .black

        createHeader()
        createScoreboard()
    }

    // MARK: - UITouch

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)  {
        view?.presentScene(GameScene(size: size), transition: .crossFade(withDuration: 0.5))
    }

    // MARK: - Private

    private func createHeader() {
        let spriteLogo = SKSpriteNode(imageNamed: Constants.Images.logo)
        spriteLogo.size = CGSize(width: 390, height: 170)
        spriteLogo.position = CGPoint(x: size.width / 2, y: size.height / 2)

        addChild(spriteLogo)

        let waitAction = SKAction.wait(forDuration: 0.5)
        let moveTo = CGPoint(x: size.width / 2, y: size.height - spriteLogo.size.height / 2 - spriteLogo.size.height)
        let moveAction = SKAction.move(to: moveTo, duration: 0.5)

        spriteLogo.run(SKAction.sequence([waitAction, moveAction])) {
            self.createStartLabel()
        }
    }

    private func createStartLabel() {
        let label = SKLabelNode(fontNamed: Constants.Fonts.courier)
        label.fontSize = 50
        label.fontColor = .white
        label.text = NSLocalizedString("start.scene.play.text", comment: "")
        label.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)

        addChild(label)
    }

    private func createScoreboard() {
        let score = String(ScoreManager.getScore())
        let scoreLabel = SKLabelNode(fontNamed: Constants.Fonts.courier)
        scoreLabel.text = String(format: NSLocalizedString("start.scene.score.text", comment: ""), score)
        scoreLabel.fontSize = 25
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - (60 + scoreLabel.frame.size.height))

        addChild(scoreLabel)
    }
}
