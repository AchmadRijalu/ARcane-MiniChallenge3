//
//  ARObjectViewModel.swift
//  ARcane-MiniChallenge3
//
//  Created by Achmad Rijalu on 14/08/23.
//

import Foundation
import SwiftUI
import ARKit

class ARObjectModel: ObservableObject {
    @Published var isObjectPlaced = false
    @Published var objectAnchor: ARAnchor?
    @Published var objectPosition: SIMD3<Float>?
}
