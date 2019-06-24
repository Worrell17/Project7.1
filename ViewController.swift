//
//  ViewController.swift
//  Project 7
//
//  Created by Richard Worrell on 21/06/2019.
//  Copyright © 2019 Richard Worrell. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    var petitionsFiltered = [[String]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filter = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(filterData))
        
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshData))
        
        navigationItem.leftBarButtonItems = [filter, refresh]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Info", style: .plain, target: self, action: #selector(viewDetail))


        let username = "username"
        let password = "password"
        let loginData = String(format: "%@:%@", username, password).data(using: String.Encoding.utf8)!
        let base64LoginData = loginData.base64EncodedString()
        
        let url = URL(string: "...")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginData)", forHTTPHeaderField: "Authorization")
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse {
                self.parse(json: data)
                print("status code = \(httpStatus.statusCode)")
            }
        }
        task.resume()
    }
    
    
    @objc func filterData() {
        let ac = UIAlertController(title: "Search", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let filteredBy = ac?.textFields?[0].text else { return }
            self?.submit(filteredBy)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ filteredBy: String) {
        petitionsFiltered.removeAll()
        for petition in petitions {
            let titleLower = petition.name.lowercased()
            let bodyLower = petition.description.lowercased()
            if titleLower.contains(filteredBy) || bodyLower.contains(filteredBy) {
                let title = petition.name
                let body = petition.description
                let group = [title, body]
                petitionsFiltered.append(group)
            }
        }
        tableView.reloadData()
    }

    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if petitionsFiltered.isEmpty {
            return petitions.count
        } else {
            return petitionsFiltered.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if petitionsFiltered.isEmpty {
            let petition = petitions[indexPath.row]
            cell.textLabel?.text = petition.name
            cell.detailTextLabel?.text = petition.description
        } else {
            let petition = petitionsFiltered[indexPath.row]
            cell.textLabel?.text = petition[0]
            cell.detailTextLabel?.text = petition[1]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func viewDetail(){
        
        let ac = UIAlertController(title: nil, message: "This data comes from the We The People API of the Whitehouse", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: nil))
        present(ac, animated: true)
}
    
    @objc func refreshData(){
        petitionsFiltered.removeAll()
        tableView.reloadData()
    }
    
    func showError(){
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

}
