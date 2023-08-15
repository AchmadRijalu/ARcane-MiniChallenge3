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
    @State var isDeployed = false
    //    @StateObject var startViewModel = StartViewModel()
    @State var isAnimating:Bool = false
    @State var isStarted:Bool = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            ARViewController(isHit: $isHit, isStarted: $isStarted).edgesIgnoringSafeArea(.all)
            
            if isStarted {
                SpellshootButton().onTapGesture {
                    isHit = true
                }
            } else {
                Color.clear
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            VStack(alignment: .center) {
                                HStack {
                                    Spacer()
                                    Text("Press Anywhere to deploy the Start Button")
                                        .foregroundColor(.white)
                                        .font(.system(size: 24).bold())
                                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                                        .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true))
                                    Spacer()
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.clear)
                            .onTapGesture {
                                isStarted = true
                            }
                        )
                .onAppear() {
                    isAnimating = true
                }
            }
            
            
            //            StartShowButton().onTapGesture {
            //                isStart = true
            //            }
            //            isStart ?
            //            ARViewCounterController(countDown: startViewModel).edgesIgnoringSafeArea(.all).onReceive(timer) { time in
            //                if startViewModel.countDown == 0 {
            //                    timer.upstream.connect().cancel()
            //                    isStart = false
            //                    startViewModel.countDown = 5
            //                } else {
            //                    print("The time is now \(startViewModel.countDown)")
            //                }
            //
            //                startViewModel.countDown -= 1
            //            }
            
            
            //            ARViewStartController().edgesIgnoringSafeArea(.all)
            //            : nil
            
            //            }
        }
    }
    
    struct ARViewController : UIViewControllerRepresentable{
        typealias UIViewControllerType = ViewController
        @Binding var isHit:Bool
        @Binding var isStarted:Bool
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
            if isStarted == true{
                let anchor = AnchorEntity()
                uiViewController.arView.scene.anchors.append(anchor)
                //add the start object from reality file
                let startObject = try! ModelEntity.load(named: "MenuExperience")
               
                startObject.components[CollisionComponent.self] = CollisionComponent(shapes: [.generateBox(width: 1.08, height: 65.5, depth: 0.5)])
                anchor.addChild(startObject)
                uiViewController.arView.scene.anchors.removeAll()
                uiViewController.arView.scene.addAnchor(anchor)
              
                
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
}
