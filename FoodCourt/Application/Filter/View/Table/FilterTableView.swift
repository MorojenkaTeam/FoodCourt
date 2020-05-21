//
//  FilterTableView.swift
//  FoodCourt_Filter
//
//  Created by Anton Chumakov on 19.05.2020.
//  Copyright © 2020 FoodCourt. All rights reserved.
//

import UIKit

class FilterTableView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBAction func searchButton(_ sender: Any) {
        
    }
    
    @IBOutlet weak var filterTableView: UITableView!
    private let cellIdentifierTemplate = "TableViewCell"
    private let settings : [String] = ["MyFood", "NeedToBuy", "DifficultySet", "AmountInFavorites"]
    private var settingsCellIdentifiers : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for identifier in settings {
            settingsCellIdentifiers.append(identifier + cellIdentifierTemplate)
        }
        
        filterTableView?.dataSource = self
        filterTableView?.delegate = self
        for cellIdentifier in settingsCellIdentifiers {
        filterTableView?.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: settingsCellIdentifiers[indexPath.row], for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = 0;
        switch indexPath.row{
        case 0:
            height = 405
        case 1, 2:
            height = 67
        case 3:
            height = 120
        default:
            height = 67
        }
        return CGFloat(height)
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
