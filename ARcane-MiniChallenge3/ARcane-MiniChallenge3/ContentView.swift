//
//  ContentView.swift
//  ARcane-MiniChallenge3
//
//  Created by Achmad Rijalu on 28/07/23.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    var body: some View {
        ARViewContainer()
			.ignoresSafeArea()
    }
}

struct ARViewController : UIViewControllerRepresentable{
    typealias UIViewControllerType = ViewController
    @Binding var isHit:Bool
    
    func makeUIViewController(context: Context) -> ViewController {
        let controller = ViewController()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        if isHit == true {
            uiViewController.spellShoot()
            DispatchQueue.main.async {
                isHit = false
            }
        }
    }

}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
