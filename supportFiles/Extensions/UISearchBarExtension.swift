//
//  UISearchBarExtension.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 05.08.2021.
//

import Foundation
import UIKit

extension UISearchBar
{
    func setSearchBarWithFrame(searchBar: UISearchBar,frame: CGRect, textColor: UIColor, placeHolder: String) -> UISearchBar
    {
        searchBar.frame = frame
        searchBar.searchBarStyle = .minimal
        searchBar.autocorrectionType = .no
        searchBar.enablesReturnKeyAutomatically = true
        searchBar.returnKeyType = .done
        searchBar.placeholder = placeHolder
        
        return searchBar
    }
}
