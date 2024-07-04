//
//  TopAlignedLabel.swift
//  MediaX
//
//  Created by Moataz Mohamed on 04/07/2024.
//

import Foundation
import UIKit

class TopAlignedLabel: UILabel {
    override func drawText(in rect: CGRect) {
        guard let text = text else {
            super.drawText(in: rect)
            return
        }

        let textRect = text.boundingRect(
            with: CGSize(width: rect.width, height: CGFloat.greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font ?? UIFont.systemFont(ofSize: 13)],
            context: nil
        )

        var newRect = rect
        newRect.size.height = ceil(textRect.size.height)
        super.drawText(in: newRect)
    }
}
