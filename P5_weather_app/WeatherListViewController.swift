//
//  WeatherListViewController.swift
//  P5_weather_app
//
//  Created by Alvaro Choque on 22/6/22.
//

import UIKit
import CoreData
import SVProgressHUD

class WeatherListViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    var weatherItems: [WeatherItem] = []
    var noFoundLabel: UILabel = UILabel()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.title = "Search"
        let sysImg = UIImage(systemName: "magnifyingglass")
        self.tabBarItem.image = sysImg
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.showsCancelButton = true
        
        let uiNib = UINib(nibName: "WeatherItemTableViewCell", bundle: nil)
        tableView.register(uiNib, forCellReuseIdentifier: "MyCell")
        
        setupNoFoundLabel()
    }
    
    func setupNoFoundLabel(){
        let margins = view.layoutMarginsGuide
        view.addSubview(noFoundLabel)
        
        noFoundLabel.translatesAutoresizingMaskIntoConstraints = false
        
        noFoundLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 120).isActive = true
        noFoundLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -120).isActive = true
        
        noFoundLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        noFoundLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        noFoundLabel.textAlignment = NSTextAlignment.center
        
        noFoundLabel.text = "No places matches the search!"
        
        noFoundLabel.isHidden = true
    }
    
    func goDetails(_ sender: Any) {
        guard let detailsScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WeatherDetailsViewController")
                as? WeatherDetailsViewController else {return}
        
        show(detailsScreen, sender: nil)
    }
    
}

// API requests
extension WeatherListViewController {
    func requestWeatherItems(url: String){
        guard let url = URL(string: url) else {return}
        
        SVProgressHUD.show()
        
        NetworkManager.shared.get(WeatherResponse.self, from: url){result in
    
            switch result {
            case .success(let responseData):
                self.weatherItems = responseData.list
                if self.weatherItems.count == 0 {
                    self.noFoundLabel.isHidden = false
                }
                else {
                    self.noFoundLabel.isHidden = true
                }
                self.tableView.reloadData()
                
            case .failure(let error):
                print(error)
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in print("OK")}))
                self.present(alert, animated: true, completion: nil)
            }
            SVProgressHUD.dismiss()
        }
        
    }
}

// Search Bar
extension WeatherListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else {return}
        
        let fixText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        requestWeatherItems(url: "https://openweathermap.org/data/2.5/find?q=\(fixText!)&appid=439d4b804bc8187953eb36d2a8c26a02&units=metric")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if self.searchBar.text == "" {
           resetData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resetData()
    }
    
    func resetData() {
        searchBar.text = ""
        view.endEditing(true)
        weatherItems.removeAll()
        noFoundLabel.isHidden = true
        self.tableView.reloadData()
    }
}

// Table View
extension WeatherListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weatherItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell") as? WeatherItemTableViewCell
        ?? WeatherItemTableViewCell(style: .subtitle, reuseIdentifier: "MyCell")

        let weather = weatherItems[indexPath.row]
        
        if let url = URL(string: "https://openweathermap.org/img/wn/\(weather.weather.first?.icon ?? "03n")@2x.png") {
            ImageManager.shared.loadImage(from: url){ result in
                switch result {
                case .success(let image):
                    cell.weatherImage.image = image
                case.failure(let error):
                    print(error)
                }
            }
        }

        cell.temperaturLabel.text = String(weather.main.temp)
        cell.minLabel.text = String(weather.main.tempMin)
        cell.maxLabel.text = String(weather.main.tempMax)
        
        cell.placeLabel.text = weather.name
        cell.countryLabel.text = weather.sys.country

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let detailsScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WeatherDetailsViewController")
                as? WeatherDetailsViewController else {return}
        
        let weather = weatherItems[indexPath.row]
        
        let fixText = searchBar.text!.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        
        detailsScreen.urlSearch = "https://openweathermap.org/data/2.5/find?q=\(fixText ?? "")&appid=439d4b804bc8187953eb36d2a8c26a02&units=metric"
        
        detailsScreen.index = indexPath.row
        
        saveEntryInHistory(urlSearch: "https://openweathermap.org/data/2.5/find?q=\(fixText ?? "")&appid=439d4b804bc8187953eb36d2a8c26a02&units=metric", index: indexPath.row, place: weather.name)
        
        show(detailsScreen, sender: nil)
    }
}

// Saving in DB
extension WeatherListViewController {
    func saveEntryInHistory(urlSearch: String, index: Int, place: String){
    
        let context = CoreDataManager.shared.getContext()
        
        let fetchRequest = NSFetchRequest<WeatherEntry>(entityName: "WeatherEntry")

        let placePredicate = NSPredicate(format: "place LIKE %@", place)
        let indexPredicate = NSPredicate(format: "index = %i", index)
        
        fetchRequest.predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [placePredicate, indexPredicate]
        )
        let results = try? context.fetch(fetchRequest)
        
        print("-------------------")
        
        if results?.count != 0 {
            // Delete item
            context.delete(results![0])
        }
        
        guard let entity = NSEntityDescription.entity(forEntityName: "WeatherEntry", in: context) else {return}
        guard let entry = NSManagedObject(entity: entity, insertInto: context) as? WeatherEntry else {return}
        
        entry.id = Int16.random(in: 1...10000)
        entry.urlSearch = urlSearch
        entry.index = Int32(index)
        entry.searchDate = Date()
        entry.place = place
        
        print(results?.count ?? 0)
        try? context.save()
       
    }
}
