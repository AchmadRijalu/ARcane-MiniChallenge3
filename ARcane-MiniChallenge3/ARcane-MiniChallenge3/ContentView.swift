//
//  ContentView.swift
//  ARcane-MiniChallenge3
//
//  Created by Achmad Rijalu on 28/07/23.
//

import SwiftUI
import RealityKit
import MultipeerConnectivity
import AVFoundation

struct ContentView : View {
    @State var isHit = false
    @State var isSummonedBlock = false
    //    @StateObject var startViewModel = StartViewModel()
    @State var isAnimating:Bool = false
    @State var isStarted:Bool = false
	@State var playerHealth: Int = 0
    
    //PASS THE VALUE INTO UIKIT FOR THE SCORE
    @StateObject var playerMapModel = PlayerMapModel()
    @State private var showModalResult = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var audioPlayer: AVAudioPlayer!
	
    init() {
            if let path = Bundle.main.path(forResource: "spellsound", ofType:"wav") {
                let url = URL(fileURLWithPath: path)
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer.prepareToPlay()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    
    
    var body: some View {
        ZStack(alignment: .bottomTrailing){
			ARViewController(isHit: $isHit, isStarted: $isStarted, isSummonedBlock: $isSummonedBlock, playerHealth: $playerHealth, playerMapModel: playerMapModel).edgesIgnoringSafeArea(.all)
            if isStarted {
                SpellshootButton().onTapGesture {
                    if audioPlayer.isPlaying {
                            // If playing, stop and rewind the player
                            audioPlayer.stop()
                            audioPlayer.currentTime = 0
                        }
                        // Play the sound
                        audioPlayer.play()
                    isHit = true
                    
                }
                VStack{
                    ShieldSummonButton().onTapGesture {
                        isSummonedBlock = true
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 150, trailing: 6))
				
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
	@Binding var playerHealth: Int
	
	func showPlayerHealth(currentPeerID: MCPeerID) -> Int {
		for player in playerMapModel.playerHealthMapping {
			if currentPeerID != player.peerId {
				return player.health
			}
		}
		
		return 0
	}
	
    
    //PASS THE VALUE INTO HERE
    @ObservedObject var playerMapModel : PlayerMapModel
	
    func makeUIViewController(context: Context) -> ViewController {
        let controller = ViewController()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        
		uiViewController.playerMapModel = playerMapModel
		let currentPeerID = uiViewController.devicePeerID ?? MCPeerID(displayName: "X")
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			playerHealth = showPlayerHealth(currentPeerID: currentPeerID)
		}

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
    
}



#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView().previewInterfaceOrientation(.landscapeLeft)
    }
}
#endif

