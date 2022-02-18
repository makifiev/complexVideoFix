//
//  ComplexReportsTableCell.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 01.07.2021.
//

import Foundation
import UIKit
import CoreData

class ComplexReportsTableCell: UITableViewCell
{
    @IBOutlet var arr: UIImageView!
    @IBOutlet var content: UIView!
    @IBOutlet var title: UILabel!
    @IBOutlet var value: UILabel!
    @IBOutlet var separator: UIView!
    
    
    func setCell()
    {
        self.contentView.backgroundColor = .white
    }
    

}
