//
//  TaskListViewModel.swift
//  VERO - BauBuddyApp
//
//  Created by Fatih on 16.03.2023.
//

import Foundation

protocol TaskListViewModelProtocol {
    var delegate : TaskListViewModelDelegate? {get set}
    func load()
    func taskSaveData(value: [Task])
    func deleteTaskData()
    func fetchTaskData()

}

enum TaskListViewModelOutPut {
    case Task([Task])
    case error(String)
}

enum UserDefaultsViewModelOutPut {
    case taskList([Task])

}

protocol TaskListViewModelDelegate {
    func handlerOutput(output: TaskListViewModelOutPut)
    func coreDataHandleOutPut(outPut: UserDefaultsViewModelOutPut)
}

class TaskListViewModel: TaskListViewModelProtocol {
    
    var delegate: TaskListViewModelDelegate?
    let service: TaskListServiceProtocol?
    var userDefaultsManager: UserDefaultsManagerProtocol?
    
    init(service: TaskListServiceProtocol, userDefaultsManager: UserDefaultsManagerProtocol){
        self.service = service
        self.userDefaultsManager = userDefaultsManager
    }
}

extension TaskListViewModel {
    
    func load() {
        
        service?.getFromAPI(completion: { [self] result in
            switch result {
            case.success(let success):
                service?.fetchTasks(with: success, completion: { [delegate] task in
                    delegate?.handlerOutput(output: .Task(task))
                    print(task)
                })
            case.failure(let error):
                print(error)
            }
        })
    }
    
    func taskSaveData(value: [Task]) {
        userDefaultsManager?.addTask(value: value)
    }
    
    func deleteTaskData() {
        userDefaultsManager?.deleteTask()
    }
    
    func fetchTaskData() {
        let model = userDefaultsManager?.fetchTask()
        if let modelData = model {
            delegate?.coreDataHandleOutPut(outPut: .taskList(modelData))
        }
       
    }

}
