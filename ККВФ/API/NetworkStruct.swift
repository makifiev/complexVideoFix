//
//  NetworkStruct.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 22.06.2021.
//

import Foundation
import UIKit

struct authInfo:Decodable
{
    var warning: String?
    var sessionID: String?
    var authCookieGen: Int?
    var authCookie: String?
}

struct allComplex:Decodable
{
    var clId: Int?
    var clName: String?
    var id: Int?
    var model: String?
    var name: String?
    var sertifEndDate: String?
    var state: Int?
    var stateName: String?
    var typeId: Int?
    var typeName: String?
    var unworkReasons: String?

}
