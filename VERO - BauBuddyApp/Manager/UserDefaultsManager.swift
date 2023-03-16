//
//  UserDefaultsManager.swift
//  VERO - BauBuddyApp
//
//  Created by Fatih on 16.03.2023.
//

import UIKit
import CoreData
protocol CoreDataManagerProtocol {
    func addTask(value: [Task])
    func deleteTask()
    func fetchTask() -> [Task]
}

class UserDefaultsManager: CoreDataManagerProtocol {
    let userDefaults = UserDefaults.standard
    let taskKey = "taskList"

    func addTask(value: [Task]) {
        userDefaults.set(try? PropertyListEncoder().encode(value), forKey: taskKey)
    }

    func fetchTask() -> [Task] {
        guard let data = userDefaults.value(forKey: taskKey) as? Data else {
            return []
        }
        guard let savedTaskList = try? PropertyListDecoder().decode([Task].self, from: data) else {
            return []
        }
        return savedTaskList
    }

    func deleteTask() {
        userDefaults.removeObject(forKey: taskKey)
    }
}
