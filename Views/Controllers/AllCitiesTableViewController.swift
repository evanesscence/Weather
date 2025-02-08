import UIKit

final class AllCitiesTableViewController: UITableViewController, AllCitiesViewProtocol {
    var presenter: AllCitiesPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "resultCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.getAllCities().count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
        if let allCities = presenter?.getAllCities() {
            cell.textLabel?.text = allCities[indexPath.row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelectCity(at: indexPath)
    }
}
