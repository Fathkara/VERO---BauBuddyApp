//
//  ViewController.swift
//  VERO - BauBuddyApp
//
//  Created by Fatih on 15.03.2023.
//

import UIKit
import Lottie


class TaskListVC: UIViewController {

    //MARK: UI

    private let animationView: LottieAnimationView = {
        let animationView = LottieAnimationView(name: "loading")
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.backgroundColor = .clear
        animationView.play()
        return animationView
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = TaskListConstant.taskListUIConstant.placeHolder.rawValue
        searchBar.barTintColor = .white
        searchBar.showsCancelButton = true
        return searchBar
    }()
    
    private let taskListTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.register(TaskListCell.self, forCellReuseIdentifier: TaskListCell.Identifier.path.rawValue)
        return tableView
    }()
    
    //MARK: Properties
    
    var viewModel: TaskListViewModelProtocol?
    private var taskList = [Task]()
    private var isSearch = false
    private var filteredData : [Task] = []
    private var refreshControl = UIRefreshControl()
    private var networkStatus: UIBarButtonItem!

    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDelegate()

    }
    override func viewWillAppear(_ animated: Bool) {
        networkConnected()
    }
    
    //MARK: Private func
    
    private func initDelegate() {
        viewModel?.delegate = self
        taskListTableView.delegate = self
        taskListTableView.dataSource = self
        searchBar.delegate = self
        configure()
    }
    
    private func configure() {
        taskListTableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        taskListTableView.rowHeight = UITableView.automaticDimension
        taskListTableView.estimatedRowHeight = 500
        
        view.backgroundColor = .white
        view.addSubview(searchBar)
        view.addSubview(taskListTableView)
        view.addSubview(animationView)
        self.taskListTableView.addSubview(refreshControl)
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "qrcode.viewfinder"), style: .plain, target: self, action: #selector(rightButtonTapped))
        networkStatus = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        navigationItem.leftBarButtonItem = networkStatus
        configureConstraints()
        createRefresh()
    }
    
    private func networkConnected() {
        if Connect.isConnected() {
            viewModel?.load()
            taskListTableView.reloadData()
            networkStatus.title = ""
        }else{
            viewModel?.fetchTaskData()
            taskListTableView.reloadData()
            networkStatus.title = "Offline!"
        }
    }
    
    private func createRefresh() {
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        taskListTableView.addSubview(refreshControl)
    }
    @objc func refresh(_ sender: AnyObject) {
        viewModel?.deleteTaskData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.viewModel?.fetchTaskData()
            self.taskListTableView.refreshControl?.endRefreshing()
        }
        viewModel?.taskSaveData(value: taskList)
        networkConnected()
    }
  
    
    @objc private func rightButtonTapped() {
        let vc = QRScannnerVC()
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: TaskListViewModelDelegate

extension TaskListVC: TaskListViewModelDelegate {
    func handlerOutput(output: TaskListViewModelOutPut) {
        switch output {
        case .Task(let task):
            viewModel?.deleteTaskData()
            viewModel?.taskSaveData(value: task)
            self.taskList = task
            DispatchQueue.main.async {
                self.animationView.isHidden = true
                self.taskListTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
            
        case .error(let error):
            print(error)
        }
    }
    
    func coreDataHandleOutPut(outPut: UserDefaultsViewModelOutPut) {
        switch outPut {
        case .taskList(let task):
            print(task)
            self.taskList = task
            DispatchQueue.main.async {
                self.animationView.isHidden = true
                self.taskListTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
}


extension TaskListVC: QRScannnerDelegate {
    func handleQROutPut(text: String) {
        searchBar.text = text
        filteredData = taskList.filter({ (sender:Task) -> Bool in
            return sender.title!.lowercased().contains(text.lowercased()) || sender.descriptionTask!.lowercased().contains(text.lowercased()) || sender.task!.lowercased().contains(text.lowercased()) || sender.colorCode!.lowercased().contains(text.lowercased())
        })
        
        DispatchQueue.main.async {
            self.isSearch = true
            self.taskListTableView.reloadData()
        }
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource

extension TaskListVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = Int()
        if isSearch {
            count = filteredData.count
        }else {
            count = taskList.count
        }
        return count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearch {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskListCell.Identifier.path.rawValue,for: indexPath) as? TaskListCell else {
                return UITableViewCell()
            }
            let getModel = filteredData[indexPath.row]
            cell.saveData(data: getModel)
            if let colorCode = getModel.colorCode {
                cell.contentView.backgroundColor = UIColor(hexString: colorCode)
            }
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskListCell.Identifier.path.rawValue,for: indexPath) as? TaskListCell else {
            return UITableViewCell()
        }
        let getModel = taskList[indexPath.row]
        cell.saveData(data: getModel)
        if let colorCode = getModel.colorCode {
            cell.contentView.backgroundColor = UIColor(hexString: colorCode)
        }
        return cell
    }
}

//MARK: UISearchBarDelegate

extension TaskListVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text != "" {
            isSearch = true
            filteredData = taskList.filter({ (sender:Task) -> Bool in
                return sender.title!.lowercased().contains(searchText.lowercased()) || sender.descriptionTask!.lowercased().contains(searchText.lowercased()) || sender.task!.lowercased().contains(searchText.lowercased()) || sender.colorCode!.lowercased().contains(searchText.lowercased())
            })
        }else{
            isSearch = false
        }
        taskListTableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text?.removeAll()
        isSearch = false
        self.searchBar.endEditing(true)
        DispatchQueue.main.async {
            self.taskListTableView.reloadData()
        }
    }
}
//MARK: Constraints
extension TaskListVC {
    func configureConstraints() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(screenWidth * 0.15)
        }
        taskListTableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        animationView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(200)
        }
        
    }
}

