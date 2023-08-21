//
//  HelpPage.swift
//  ARcane-MiniChallenge3
//
//  Created by Achmad Rijalu on 15/08/23.
//

import SwiftUI

struct HelpPage: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        
        NavigationStack{
            VStack{
                HStack{
                    Spacer()
                    Text("Done").font(.system(.body).bold()).onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
                }.padding(.all)
                Spacer()
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct HelpPage_Previews: PreviewProvider {
    static var previews: some View {
        HelpPage()
    }
}