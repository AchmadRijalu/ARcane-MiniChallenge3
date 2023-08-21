//
//  HelpPage.swift
//  ARcane-MiniChallenge3
//
//  Created by Achmad Rijalu on 15/08/23.
//

import SwiftUI

struct ResultPage: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        
        NavigationStack{
            VStack{
//                HStack{
//                    Spacer()
//                    Text("Done").font(.system(.body).bold()).onTapGesture {
//                        presentationMode.wrappedValue.dismiss()
//                    }
//                }.padding(.all)
                Spacer()
                VStack{
                    HStack{
                        Text("You Win!!").font(.system(.title))
                    }.padding(.bottom, 12)
                    
                    Button(action: {
                        
                    }){
                        Text("Back to Main Menu")
                    }
                }
                Spacer()
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct ResultPage_Previews: PreviewProvider {
    static var previews: some View {
        ResultPage()
    }
}
