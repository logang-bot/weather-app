//
//  HistoryViewController.swift
//  P5_weather_app
//
//  Created by Alvaro Choque on 22/6/22.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var WEntries: [WeatherEntry]?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.title = "History"
        let sysImg = UIImage(systemName: "clock.arrow.circlepath")
        self.tabBarItem.image = sysImg
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    func loadData() {
        self.WEntries = CoreDataManager.shared.getData()
        self.tableView.reloadData()
    }
    
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.WEntries?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell2")
        ?? UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell2")
        
        let WItem = WEntries?[WEntries!.count - indexPath.row - 1]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY/MM/dd/hh:mm:ss"
        
        cell.textLabel?.text = WItem?.place
        cell.detailTextLabel?.text = dateFormatter.string(from: WItem!.searchDate!)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let detailsScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WeatherDetailsViewController")
                as? WeatherDetailsViewController else {return}
        
        let WItem = WEntries?[WEntries!.count - indexPath.row - 1]
        detailsScreen.urlSearch = WItem?.urlSearch
        detailsScreen.index = Int(WItem!.index)
        
        show(detailsScreen, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let WItem = WEntries?[indexPath.row]
        
        let actions = [
            UIContextualAction(style: .destructive, title: "Delete", handler: { _, _, _ in
                self.deleteElement(element: WItem!)
            })
        ]
        
        return UISwipeActionsConfiguration(actions: actions)
    }
}

// Delete an element
extension HistoryViewController{
    func deleteElement(element: WeatherEntry) {
        DispatchQueue.main.async {
            let sheet = UIAlertController(title: "Are you sure you want to delete this entry?", message: nil, preferredStyle: .alert)
            
            sheet.addAction(UIAlertAction(title: "Yes", style: .default) {_ in
                CoreDataManager.shared.deleteElement(element: element)
                
                if let index = self.WEntries?.firstIndex(where: {element.id == $0.id}) {
                    self.WEntries?.remove(at: index)
                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                }
            })
            
            sheet.addAction(UIAlertAction(title: "No", style: .cancel))
            
            self.navigationController?.present(sheet, animated: true, completion: nil)
        }
    }
}
