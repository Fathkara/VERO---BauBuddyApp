//
//  TaskListBuilder.swift
//  VERO - BauBuddyApp
//
//  Created by Fatih on 16.03.2023.
//

import Foundation
class TaskListBuilder {
    static func make() -> TaskListVC {
        let vc = TaskListVC()
        let viewModel = TaskListViewModel(service: APIHandler(), coredataManager: UserDefaultsManager())
        vc.viewModel = viewModel
        return vc
    }
}
