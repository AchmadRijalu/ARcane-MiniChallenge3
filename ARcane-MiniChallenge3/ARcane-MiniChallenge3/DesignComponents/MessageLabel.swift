//
//  MessageLabel.swift
//  ARcane-MiniChallenge3
//
//  Created by Achmad Rijalu on 10/08/23.
//

import Foundation
import UIKit

class MessageLabel: UILabel {
    var ignoreMessages = false
    
    let padding: UIEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0) // Adjust padding values as needed
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLabel()
    }
    
    private func setupLabel() {
        backgroundColor = .white
        layer.cornerRadius = 10 // Set the corner radius value as needed
                clipsToBounds = true
        lineBreakMode = .byTruncatingMiddle
        font = UIFont.systemFont(ofSize: 16)
    }
    
    override func drawText(in rect: CGRect) {
//        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        super.drawText(in: rect.inset(by: padding))
    }
    
    
    func displayMessage(_ text: String, duration: TimeInterval = 3.0) {
        guard !ignoreMessages else { return }
        guard !text.isEmpty else {
            DispatchQueue.main.async {
                self.isHidden = true
                self.text = ""
            }
            return
        }
        DispatchQueue.main.async {
            self.isHidden = false
            self.text = text
            
            // Use a tag to tell if the label has been updated.
            let tag = self.tag + 1
            self.tag = tag
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                // Do not hide if this method is called again before this block kicks in.
                if self.tag == tag {
                    self.isHidden = true
                }
            }
        }
    }
}
