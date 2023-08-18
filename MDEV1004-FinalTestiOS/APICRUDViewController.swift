//
//  APICRUDViewController.swift
//  MDEV1004-FinalTestiOS
//
//  Created by Khushi Shukla on 2023-08-18.
//


import UIKit


class APICRUDViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var songs: [Songs] = []

    override func viewDidLoad()
        {
            super.viewDidLoad()
            
            fetchSongs { [weak self] songs, error in
                DispatchQueue.main.async
                {
                    if let songs = songs
                    {
                        if songs.isEmpty
                        {
                            // Display a message for no data
                            self?.displayErrorMessage("No songs available.")
                        } else {
                            self?.songs = songs
                            self?.tableView.reloadData()
                        }
                    } else if let error = error {
                        if let urlError = error as? URLError, urlError.code == .timedOut
                        {
                            // Handle timeout error
                            self?.displayErrorMessage("Request timed out.")
                        } else {
                            // Handle other errors
                            self?.displayErrorMessage(error.localizedDescription)
                        }
                    }
                }
            }
        }
        
        func displayErrorMessage(_ message: String)
        {
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        
        func fetchSongs(completion: @escaping ([Songs]?, Error?) -> Void)
        {
            // Retrieve AuthToken from UserDefaults
            guard let authToken = UserDefaults.standard.string(forKey: "AuthToken") else
            {
                print("AuthToken not available.")
                completion(nil, nil)
                return
            }
            
            // Configure Request
            guard let url = URL(string: "https://livesite1004-j1i8.onrender.com/api/list") else
            {
                print("URL Error")
                completion(nil, nil) // Handle URL error
                return
            }
            
            var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

            // Issue Request
            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    print("Network Error")
                    completion(nil, error) // Handle network error
                    return
                }

                guard let data = data else {
                    print("Empty Response")
                    completion(nil, nil) // Handle empty response
                    return
                }

                // Response
                do {
                    print("Decoding JSON Data...")
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

                    if let success = json?["success"] as? Bool, success == true
                    {
                        if let songsData = json?["data"] as? [[String: Any]]
                        {
                            let songs = try JSONSerialization.data(withJSONObject: songsData, options: [])
                            let decodedSongs = try JSONDecoder().decode([Songs].self, from: songs)
                            completion(decodedSongs, nil) // Success
                        } else {
                            print("Missing 'data' field in JSON response")
                            completion(nil, nil) // Handle missing data field
                        }
                    } else {
                        print("API request unsuccessful")
                        let errorMessage = json?["msg"] as? String ?? "Unknown error"
                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                        completion(nil, error) // Handle API request unsuccessful
                    }
                } catch {
                    print("Error Decoding JSON Data")
                    completion(nil, error) // Handle JSON decoding error
                }
            }.resume()
        }


        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
        {
            return songs.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongTableViewCell
                            
                    
            let song = songs[indexPath.row]

                    cell.titleLabel?.text = song.title
                    cell.labelLabel?.text = song.label
                    cell.ratingLabel?.text = "\(song.rating)"

                    let rating = song.rating

                    if rating > 4.5 {
                        cell.ratingLabel.backgroundColor = UIColor.green
                        cell.ratingLabel.textColor = UIColor.black
                    } else if rating > 2 {
                        cell.ratingLabel.backgroundColor = UIColor.yellow
                        cell.ratingLabel.textColor = UIColor.black
                    } else {
                        cell.ratingLabel.backgroundColor = UIColor.red
                        cell.ratingLabel.textColor = UIColor.white
                    }
                    return cell
                }
        
      
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
        {
            performSegue(withIdentifier: "AddEditSegue", sender: indexPath)
        }
            
        // Swipe Left Gesture
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
            {
                if editingStyle == .delete
                    {
                        let song = songs[indexPath.row]
                        ShowDeleteConfirmationAlert(for: song) { confirmed in
                            if confirmed
                            {
                                self.deleteSongs(at: indexPath)
                            }
                        }
                    }
            }
        
        @IBAction func AddButton_Pressed(_ sender: UIButton)
        {
            performSegue(withIdentifier: "AddEditSegue", sender: nil)
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?)
        {
            if segue.identifier == "AddEditSegue"
            {
                if let addEditVC = segue.destination as? AddEditAPICRUDViewController
                {
                   
                    if let indexPath = sender as? IndexPath
                    {
                       // Editing existing movie
                       let song = songs[indexPath.row]
                       addEditVC.song = song
                    } else {
                        // Adding new movie
                        addEditVC.song = nil
                    }
                    
                    // Set the callback closure to reload movies
                    addEditVC.songUpdateCallback = { [weak self] in
                        self?.fetchSongs { songs, error in
                            if let songs = songs
                            {
                                self?.songs = songs
                                DispatchQueue.main.async {
                                    self?.tableView.reloadData()
                                }
                            }
                            else if let error = error
                            {
                                print("Failed to fetch songs: \(error)")
                            }
                        }
                    }
                }
            }
        }
        
        func ShowDeleteConfirmationAlert(for song: Songs, completion: @escaping (Bool) -> Void)
        {
            let alert = UIAlertController(title: "Delete Song", message: "Are you sure you want to delete this Song?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completion(false)
            })
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                completion(true)
            })
            
            present(alert, animated: true, completion: nil)
        }
        
        func deleteSongs(at indexPath: IndexPath)
        {
            let song = songs[indexPath.row]
            
         
            guard let authToken = UserDefaults.standard.string(forKey: "AuthToken") else
            {
                        print("AuthToken not available.")
                        return
            }

            guard let url = URL(string: "https://livesite1004-j1i8.onrender.com/api/delete/\(song.documentID)") else {
                print("Invalid URL")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                if let error = error {
                    print("Failed to delete game: \(error)")
                    return
                }

                DispatchQueue.main.async {
                    self?.songs.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
                
            task.resume()
        }
        
        
        @IBAction func logoutButtonPressed(_ sender: UIButton)
        {
            // Remove the token from UserDefaults or local storage to indicate logout
            UserDefaults.standard.removeObject(forKey: "AuthToken")
            
            // Clear the username and password in the LoginViewController
            APILoginViewController.shared?.ClearLoginTextFields()
            
            // unwind
            performSegue(withIdentifier: "unwindToLogin", sender: self)
        }

    }
