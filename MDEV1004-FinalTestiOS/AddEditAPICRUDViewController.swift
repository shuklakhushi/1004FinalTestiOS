//
//  AddEditAPICRUDViewController.swift
//  MDEV1004-FinalTestiOS
//
//  Created by Khushi Shukla on 2023-08-18.
//


import UIKit


class AddEditAPICRUDViewController: UIViewController {

    // UI References
    @IBOutlet weak var AddEditTitleLabel: UILabel!
    
    @IBOutlet weak var UpdateButton: UIButton!
    
    // Movie Fields
    
    @IBOutlet weak var songIDTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var genreTextField: UITextField!
    @IBOutlet weak var albumTextField: UITextField!
    @IBOutlet weak var labelTextField: UITextField!
    @IBOutlet weak var youtubeLinkTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var releaseDateTextField: UITextField!
    @IBOutlet weak var trackNumberTextField: UITextField!
    @IBOutlet weak var ratingTextField: UITextField!
    @IBOutlet weak var composerTextField: UITextField!

    
    
    var song: Songs?
    var songViewController: APICRUDViewController?
    var songUpdateCallback: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let song = song{
            // Editing existing movie
            songIDTextField.text = "\(song.songID)"
            titleTextField.text = song.title
            genreTextField.text = song.genre
            albumTextField.text = song.album
            artistTextField.text = song.artist
            composerTextField.text = song.composer
            durationTextField.text = song.duration
            labelTextField.text = song.label
            ratingTextField.text = "\(song.rating)"
            releaseDateTextField.text = song.releaseDate
            trackNumberTextField.text = "\(song.trackNumber)"
            youtubeLinkTextField.text = "\(song.youtubeLink)"
            AddEditTitleLabel.text = "Edit Song"
            UpdateButton.setTitle("Update", for: .normal)
        } else {
            AddEditTitleLabel.text = "Add Song"
            UpdateButton.setTitle("Add", for: .normal)
        }
    }
    
    @IBAction func CancelButton_Pressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func UpdateButton_Pressed(_ sender: UIButton)
        {
            // Retrieve AuthToken
            guard let authToken = UserDefaults.standard.string(forKey: "AuthToken") else
            {
                print("AuthToken not available.")
                return
            }
            
            // Configure Request
            let urlString: String
            let requestType: String
            
            if let song = song {
                requestType = "PUT"
                urlString = "https://livesite1004-j1i8.onrender.com/api/\(song.documentID)"
            } else {
                requestType = "POST"
                urlString = "https://livesite1004-j1i8.onrender.com/api/add"
            }
            
            guard let url = URL(string: urlString) else {
                print("Invalid URL.")
                return
            }

            // Explicitly mention the types of the data
            let documentID: String = song?.documentID ?? UUID().uuidString
                   let songID: String = songIDTextField.text ?? ""
                   let title: String = titleTextField.text ?? ""
                   let genre: String = genreTextField.text ?? ""
                   let album: String = albumTextField.text ?? ""
                   let artist: String = artistTextField.text ?? ""
                   let composer: String = composerTextField.text ?? ""
                   let duration: String = durationTextField.text ?? ""
                   let label: String = labelTextField.text ?? ""
                   let rating: String = ratingTextField.text ?? ""
                   let releaseDate: String = releaseDateTextField.text ?? ""
                   let trackNumber: Int = Int(trackNumberTextField.text ?? "") ?? 0
                   let youtubeLink: String = youtubeLinkTextField.text ?? ""

                   // Create the movie with the parsed data
                   let song = Songs(
                       documentID: documentID,
                       songID: Int(songID) ?? 0,
                       title: title,
                       album: genre,
                       artist: album,
                       composer: artist,
                       duration: composer,
                       genre: duration,
                       label: label,
                       rating: Double(rating) ?? 0.0,
                       releaseDate: releaseDate,
                       trackNumber: trackNumber,
                       youtubeLink: youtubeLink
                   )
                   
                   var request = URLRequest(url: url)
                   request.httpMethod = requestType
                   request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                   // Add the AuthToken to the request headers
                   request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
                   
                   // Request
                   do {
                       request.httpBody = try JSONEncoder().encode(song)
                   } catch {
                       print("Failed to encode song: \(error)")
                       return
                   }
                   
                   // Response
                   let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                       if let error = error
                       {
                           print("Failed to send request: \(error)")
                           return
                       }
                       
                       DispatchQueue.main.async
                       {
                           self?.dismiss(animated: true)
                           {
                               self?.songUpdateCallback?()
                           }
                       }
                   }
                   
                   task.resume()
               }
           }
