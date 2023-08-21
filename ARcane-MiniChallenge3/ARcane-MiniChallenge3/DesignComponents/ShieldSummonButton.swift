//
//  ShieldSummonButton.swift
//  ARcane-MiniChallenge3
//
//  Created by Achmad Rijalu on 20/08/23.
//

import SwiftUI


struct ShieldSummonButton: View {
    var body: some View {
        VStack{
            Image("shield").resizable()
        }.frame(width: UIScreen.main.bounds.size.width / 8 , height: UIScreen.main.bounds.size.width / 8).background(Color("StartButtonColor")).clipShape(Capsule())
    }
}
struct ShieldSummonButton_Previews: PreviewProvider {
    static var previews: some View {
        ShieldSummonButton()
    }
}
