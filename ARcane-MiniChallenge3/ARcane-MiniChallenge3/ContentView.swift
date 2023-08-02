//
//  ContentView.swift
//  ARcane-MiniChallenge3
//
//  Created by Achmad Rijalu on 28/07/23.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    @State var isHit = false
    var body: some View {
        
        ZStack(alignment: .bottomTrailing){
            ARViewController(isHit: $isHit).edgesIgnoringSafeArea(.all)
            SpellshootButton().onTapGesture {
                print("tapped")
                isHit = true
            }
        }
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
        print("update")
        if isHit == true{
            uiViewController.testHit()
            DispatchQueue.main.async {
                isHit = false
            }
            
        }
    }

}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView().previewInterfaceOrientation(.landscapeLeft)
    }
}
#endif
