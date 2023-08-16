//
//  StartShowButton.swift
//  ARcane-MiniChallenge3
//
//  Created by Achmad Rijalu on 10/08/23.
//

import SwiftUI
struct StartShowButton: View {
    var body: some View {
        VStack{
            Text("Summon ").multilineTextAlignment(.center).foregroundColor(.white).font(.title2).fontWeight(.medium)
        }.frame(width: UIScreen.main.bounds.size.width / 8 , height: UIScreen.main.bounds.size.width / 8).background(.red).clipShape(Capsule())
    }
}
struct StartShowButton_Previews: PreviewProvider {
    static var previews: some View {
        StartShowButton()
    }
}
