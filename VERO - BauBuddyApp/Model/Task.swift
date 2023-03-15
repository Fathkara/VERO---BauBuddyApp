//
//  Task.swift
//  VERO - BauBuddyApp
//
//  Created by Fatih on 15.03.2023.
//

import Foundation
public class Task : Codable{
    
    var task : String?
    var title : String?
    var descriptionTask : String?
    var colorCode : String?

    
    enum CodingKeys: String, CodingKey {
        
        case task
        case title
        case descriptionTask = "description"
        case colorCode
        
    }
}
