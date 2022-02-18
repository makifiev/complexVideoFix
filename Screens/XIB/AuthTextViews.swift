//
//  AuthTextViews.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 05.04.2021.
//

import UIKit

class AuthTextViews: UIView {

  
    @IBOutlet var view: UIView!
    override init(frame: CGRect) {
          super.init(frame: frame)
          
          nibSetup()
      }
      
//      override func awakeFromNib() {
//          super.awakeFromNib()
//          
//          nibSetup()
//      }

      required init?(coder aDecoder: NSCoder) {
          super.init(coder: aDecoder)
          
          nibSetup()
      }

      private func nibSetup() {
          view = loadViewFromNib()
          view.frame = bounds
          view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
          view.translatesAutoresizingMaskIntoConstraints = true

          addSubview(view)
      }

      private func loadViewFromNib() -> UIView {
        let viewfronXIB = Bundle.main.loadNibNamed("AuthTextFields", owner: self, options: nil)![0] as! UIView
         

          return viewfronXIB
      }

}
