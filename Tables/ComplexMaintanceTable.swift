//
//  ComplexMaintanceTable.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 05.07.2021.
//

import Foundation
import UIKit
extension ComplexStatusReportController
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "complexMaintance", for: indexPath) as! ComplexMaintanceTableCell
//        cell.setCell()
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.array.count
    }
    
     func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
            return array[section]
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 45))
        view.backgroundColor = UIColor(red: 218/255.0, green: 218/255.0, blue: 218/255.0, alpha: 1)
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: 45))
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor(red: 83/255.0, green: 83/255.0, blue: 83/255.0, alpha: 1)
        if section == 0
        {
        label.text = "Количество работающих комплексов"
            view.addSubview(label)
            return view
        }
        else if section == 1
        {
        label.text = "Количество фиксаций"
            
        }
        view.addSubview(label)
        return view
       
       
      }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
}
