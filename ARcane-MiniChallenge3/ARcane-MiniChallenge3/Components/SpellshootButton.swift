//
//  SpellshootButton.swift
//  ARcane-MiniChallenge3
//
//  Created by Achmad Rijalu on 28/07/23.
//

import SwiftUI

struct SpellshootButton: View {
    
    var body: some View {
        VStack{
            Image("MagicWandIcon").resizable().scaledToFit()
        }.frame(width: UIScreen.main.bounds.size.width / 6 , height: UIScreen.main.bounds.size.width / 6).background(.red).clipShape(Circle()).padding(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 12))
    }
}

struct SpellshootButton_Previews: PreviewProvider {
    static var previews: some View {
        SpellshootButton()
    }
}
