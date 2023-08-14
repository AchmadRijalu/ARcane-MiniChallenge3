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
    @State var isStart = false
    @StateObject var count = StartViewModel()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            ARViewController(isHit: $isHit).edgesIgnoringSafeArea(.all)
            
            
            
            StartShowButton().onTapGesture {
                isStart = true
            }
            isStart ? ARViewCounterController(countDown: count).edgesIgnoringSafeArea(.all).onReceive(timer) { time in
                if count.countDown == 0 {
                    timer.upstream.connect().cancel()
                    isStart = false
                    count.countDown = 5
                } else {
                    print("The time is now \(count.countDown)")
                }
                
                count.countDown -= 1
            } : nil
            //            SpellshootButton().onTapGesture {
            //                isHit = true
            //            }
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
        if isHit == true{
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
        ContentView(count: StartViewModel()).previewInterfaceOrientation(.landscapeLeft)
    }
}
#endif
