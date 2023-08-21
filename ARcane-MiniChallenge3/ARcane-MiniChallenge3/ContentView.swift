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
    @State var isSummonedBlock = false
    //    @StateObject var startViewModel = StartViewModel()
    @State var isAnimating:Bool = false
    @State var isStarted:Bool = false
    
    //PASS THE VALUE INTO UIKIT FOR THE SCORE
    @StateObject var healthviewModel = HealthViewModel()
    @State private var showModalResult = false
    
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            ARViewController(isHit: $isHit, isStarted: $isStarted, isSummonedBlock: $isSummonedBlock, healthviewModel: healthviewModel, Health: healthviewModel.playerOneHealth ).edgesIgnoringSafeArea(.all)
            if isStarted {
                SpellshootButton().onTapGesture {
                    isHit = true
//                    healthviewModel.playerOneHealth -= 1
                    
                }
                VStack{
                    ShieldSummonButton().onTapGesture {
                        isSummonedBlock = true
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 150, trailing: 6))
                VStack {
                    HStack {
                        Text("Your Health: \(healthviewModel.playerOneHealth)")
                            .foregroundColor(.black)
                            .background(.white)
                            .font(.title2)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 0))
            } else {
                // Create a transparent background with a blur effect
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        VisualEffectView(effect: UIBlurEffect(style: .light))
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    ).edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isStarted = true
                    }
                VStack(alignment: .center) {
                    HStack {
                        Spacer()
                        Text("Tap Anywhere to Start Finding Player")
                            .foregroundColor(.white)
                            .font(.system(size: 24).bold())
                            .scaleEffect(isAnimating ? 1.2 : 1.0)
                            .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true))
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear() {
                    isAnimating = true
                }
            }
        }
        .onChange(of: healthviewModel.playerOneHealth) { newHealth in
                    if newHealth <= 0 {
                        withAnimation {
                            showModalResult = true
                        }
                    }
                }
        .sheet(isPresented: $showModalResult) {
            ResultPage()
        }
    }
}

struct VisualEffectView: UIViewRepresentable {
    
    var effect: UIVisualEffect?
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView()
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}


struct ARViewController : UIViewControllerRepresentable{
    typealias UIViewControllerType = ViewController
    @Binding var isHit:Bool
    @Binding var isStarted:Bool
    @Binding var isSummonedBlock:Bool
    
    //PASS THE VALUE INTO HERE
    var healthviewModel : HealthViewModel
    var Health: Int
    func makeUIViewController(context: Context) -> ViewController {
        let controller = ViewController()
        //        if controller.countdownIsOn == true{
        //            controller.startCountdown()
        //        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        
        uiViewController.healthviewModel = healthviewModel
        uiViewController.healthLabel.text = String(Health)
        if isHit == true{
            uiViewController.spellShoot()
            DispatchQueue.main.async {
                isHit = false
            }
        }
        if isSummonedBlock == true{
            uiViewController.blockDeploy()
            DispatchQueue.main.async {
                isSummonedBlock = false
            }
        }
    }
    // this is very important, this coordinator will be used in `makeUIViewController`
    
}



#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView().previewInterfaceOrientation(.landscapeLeft)
    }
}
#endif

