//
//  StringExtension.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 21.08.2021.
//

import Foundation
import UIKit

extension String
{
    func stringWithoutDoubleSpaces()
    {
        var string = self
        while (string.range(of: "  ",options: .caseInsensitive) != nil) {
            string = string.replacingOccurrences(of: "  ", with: " ")
        }
    }
    func attributedStringWithLineSpacing(lineSpacing: Float) -> NSAttributedString
    {
        let attributedString = NSMutableAttributedString(string: self)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = CGFloat(lineSpacing)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: self.count))
        return attributedString
    }
    func stringFromNumber(number: Int) -> String
    {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = " "
        formatter.groupingSize = 3
        
        return formatter.string(from: NSNumber(value: number))!
    }
}
