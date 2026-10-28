import SpriteKit
import SwiftUI

struct ContentView: View {
    private var scene: GameScene {
        let scene = GameScene(size: CGSize(width: 1280, height: 800))
        scene.scaleMode = .aspectFit
        scene.backgroundColor = .black
        return scene
    }

    var body: some View {
        SpriteView(scene: scene)
            .frame(width: 1280, height: 800)
            .ignoresSafeArea()
    }
}
