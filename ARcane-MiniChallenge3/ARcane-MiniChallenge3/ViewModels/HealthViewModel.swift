import Foundation
import SwiftUI
import ARKit

class HealthViewModel: ObservableObject {
    @Published var playerOneHealth:Int = 100
    @Published var playerTwoHealth:Int = 100
}
