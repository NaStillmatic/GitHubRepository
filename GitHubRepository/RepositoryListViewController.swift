//
//  RepositoryListViewController.swift
//  GitHubRepository
//
//  Created by HwangByungJo  on 2022/07/11.
//

import UIKit
import RxSwift
import RxCocoa


class RepositoryListViewController: UIViewController {
  
  private let organization = "Apple"
  private let repositories = BehaviorSubject<[Repository]>(value: [])
  private let disposeBag = DisposeBag()
  
  private lazy var tableView : UITableView = {
    let tableView = UITableView()
    tableView.rowHeight = 140
    tableView.register(RepositoryListCell.self, forCellReuseIdentifier: "RepositoryListCell")
    return tableView
  }()
  
  private lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.backgroundColor = .white
    refreshControl.tintColor = .darkGray
    refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
    return refreshControl
  }()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemBackground
    
    setupUI()
    setupRX()
  }
  
  
  func fetchRepositories(of organization: String) {
    Observable.from([organization])
      .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
      .map { organization -> URL in
        return URL(string: "https://api.github.com/orgs/\(organization)/repos")!
      }
      .map { url -> URLRequest in
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
      }
      .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
        return URLSession.shared.rx.response(request: request)
      }
      .filter { responds, _ in
        return 200..<300 ~= responds.statusCode
      }
      .map { _, data -> [[String : Any]] in
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
              let result = json as? [[String : Any]] else {
          return []
        }
        return result
      }
      .filter { result in
        result.count > 0
      }
      .map { objects in
        
        return objects.compactMap { dic -> Repository? in
          
          guard let id = dic["id"] as? Int,
                let name = dic["name"] as? String,
                let description = dic["description"] as? String,
                let stargazersCount = dic["stargazers_count"] as? Int,
                let language = dic["language"] as? String else {
            return nil
          }
          return Repository(id: id, name: name, description: description, stargazersCount: stargazersCount, language: language)
        }
      }
      .observe(on: MainScheduler.instance)
      .subscribe(onNext:{ [weak self] newRepositories in
        self?.repositories.onNext(newRepositories)
        self?.tableView.refreshControl?.endRefreshing()
      })
      .disposed(by: disposeBag)
  }
}


extension RepositoryListViewController {
  
  private func setupUI() {
    
    title =  organization + "Repositories"
    
    view.addSubview(tableView)
    tableView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    tableView.refreshControl = refreshControl
  }
  
  func setupRX() {
    
    refreshControl.rx
      .controlEvent(.valueChanged)
      .subscribe{ [weak self] _ in
                  guard let self = self else { return }
                  self.fetchRepositories(of: self.organization)
      }
      .disposed(by: disposeBag)
    
    repositories
      .bind(to: tableView.rx.items(cellIdentifier: "RepositoryListCell", cellType: RepositoryListCell.self)) { _, item, cell in
        cell.repository = item
    }
      .disposed(by: disposeBag)
  }
}
