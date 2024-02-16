//
//  ViewController.swift
//  basics
//
//  Created by Arturo Carretero Calvo on 16/2/24.
//

import UIKit

// MARK: - Protocols

protocol Movement {
    func move()
}

extension Movement {
    func move() {
        print("Moviendo")
    }
}

// MARK: - Structs

struct Player: Movement {
    let life: Int
    let name: String

    func move() {
        print("Moviendo jugador")
    }
}

struct Enemy: Movement {
    let name: String
}

// MARK: - UIViewController

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Properties
        let name = "Arturo"

        var lastname = "Carretero"

        print(lastname)

        lastname = "Carretero Calvo"

        print(name)
        print(lastname)

        let number: Int = 6

        print(number)

        let value: Bool = true // or false

        if value {
            print("Es verdadero")
        } else {
            print("Es falso")
        }

        // Array
        var levels: [Int] = [54,41,22,33,64,45]

        levels.append(1200)

        print(levels)

        // Dictionary
        var dict: [String: Any] = ["age": 40,
                                   "name": "Arturo",
                                   "selected": false]

        print(dict["age"]!)
        print(dict)

        sum()
        sum(one: 27, two: 13)

        let suma = sumReturn(one: 54, two: 76)

        print(suma)

        // Instances

        let player = Player(life: 100, name: "Arturo")
        player.move()

        let enemy = Enemy(name: "Moriarti")
        enemy.move()
    }

    func sum() {
        let numberOne = 5
        let numberTwo = 10

        let sum = numberOne + numberTwo

        print(sum)
    }

    func sum(one: Int, two: Int) {
        let sum = one + two

        print(one + two)
    }

    func sumReturn(one: Int, two: Int) -> Int {
        one + two
    }
}
