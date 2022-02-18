//
//  ComplexReportsTable.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 01.07.2021.
//

import Foundation
import CoreData
import Alamofire

extension DisabledComplexReportController
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "complexReports", for: indexPath) as! ComplexReportsTableCell
        cell.setCell()
        return cell
    }
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return array.count
    }
    
     func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section <= array.count
        {
            return array[section]
        }
        else
        {
            return nil
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 45))
        view.backgroundColor = UIColor(red: 218/255.0, green: 218/255.0, blue: 218/255.0, alpha: 1)
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: 45))
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor(red: 83/255.0, green: 83/255.0, blue: 83/255.0, alpha: 1)
        label.text = "Стационарные"
        view.addSubview(label)
        return view
      }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
}
