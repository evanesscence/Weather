import UIKit
import CoreData

final class MyCitiesTableViewController: UITableViewController, MyCitiesViewProtocol {
    
    var presenter: MyCitiesPresenterProtocol = MyCitiesPresenter()
    var searchController: UISearchController = UISearchController()
    var isFirstAppear = true
    
    private let resultController = AllCitiesTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Погода"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .white
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = editButtonItem
        
        setupSearchController()
        
        let nib = UINib(nibName: "MyCityTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "MyCityTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self

        tableView.showsVerticalScrollIndicator = false
        presenter.didLoad(view: self)
        presenter.fetchedResultController.delegate = self

        let editImage = UIImage(systemName: "square.and.pencil") // Используем SF Symbol (или своё изображение)
           
           navigationItem.rightBarButtonItem = UIBarButtonItem(
               image: editImage,
               style: .plain,
               target: self,
               action: #selector(toggleEditingMode)
           )
    }
    
    @objc func toggleEditingMode() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        // Можно менять иконку в зависимости от режима
        let newImage = tableView.isEditing ? UIImage(systemName: "checkmark") : UIImage(systemName: "square.and.pencil")
        navigationItem.rightBarButtonItem?.image = newImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.sizeToFit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.shouldShowWeatherOfMainCity()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.getNumberOfRowsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "MyCityTableViewCell",
            for: indexPath
        ) as! MyCityTableViewCell
        if let weatherModel = presenter.getCity(at: indexPath) {
            cell.configure(with: weatherModel)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowWeatherViewController", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowWeatherViewController",
           let destinationVC = segue.destination as? WeatherViewController,
           let indexPath = sender as? IndexPath,
           let cityName = presenter.getCity(at: indexPath)?.cityName
        {  // Получаем indexPath из sender
            destinationVC.presenter.selectedCity = cityName
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true // Разрешаем перемещение всех ячеек
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        presenter.moveCity(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return tableView.isEditing ? .none : .delete
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let isDefaultCitiesContainsCity = presenter.isDefaultCitiesContainsCity(at: indexPath)
        if isDefaultCitiesContainsCity {
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completion) in
                guard let self else { return }
                presenter.trailingSwipeActionsConfigurationForRowAt(indexPath: indexPath)
                completion(true)
            }
            
            deleteAction.backgroundColor = UIColor.wGray
            deleteAction.image = createRoundedButtonWithIcon(
                backgroundColor: .red,
                icon: UIImage(systemName: "trash")!.withTintColor(.white, renderingMode: .alwaysOriginal),
                size: CGSize(width: 40, height: 40),
                cornerRadius: 20
            )
            
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        return nil
    }
    
    func createRoundedButtonWithIcon(backgroundColor: UIColor, icon: UIImage, size: CGSize, cornerRadius: CGFloat) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            
            // Рисуем закругленный фон
            let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            backgroundColor.setFill()
            path.fill()
            
            // Рисуем иконку по центру
            let iconSize = CGSize(width: size.height * 0.6, height: size.height * 0.6) // Примерный размер иконки
            let iconOrigin = CGPoint(
                x: (size.width - iconSize.width) / 2,
                y: (size.height - iconSize.height) / 2
            )
            icon.draw(in: CGRect(origin: iconOrigin, size: iconSize))
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        132
    }
    
    func showWeatherOfMainCity() {
        self.performSegue(withIdentifier: "ShowWeatherViewController", sender: nil)
    }
    
    func showWeatherViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "ViewController"
        ) as? WeatherViewController else {
            return
        }
        
        presenter.configure(for: vc)
        vc.modalPresentationStyle = .popover
        present(vc, animated: true)
    }
    
    func updateSearchController() {
        searchController.searchBar.text = .none
        searchController.isActive = false
        searchController.searchBar.resignFirstResponder()
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: resultController)
        resultController.presenter = AllCitiesPresenter(view: resultController)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Найти город"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
}

extension MyCitiesTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased(),
              !searchText.isEmpty else { return }
        
        if let resultController = searchController.searchResultsController as? AllCitiesTableViewController,
           let resultPresenter = resultController.presenter {
            presenter.updateSearchResults(for: resultPresenter, with: searchText)
            resultController.tableView.reloadData()
            
        }
    }
}

extension MyCitiesTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
                var cell = tableView.cellForRow(at: newIndexPath)
                cell?.layer.cornerRadius = 20
                cell?.layer.masksToBounds = true
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.moveRow(at: indexPath, to: newIndexPath)
            }
        default:
            break
        }
    }
}
