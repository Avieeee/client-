//
//  ViewController.swift
//  TwitterFeeder
//
//  Created by SACHIN AVISHKA DE SILVA DE SILVA on 20/05/2018.
//  Copyright © 2018 Deakin. All rights reserved.
//

import UIKit
import Social

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //importing objects 
    
    
    @IBOutlet weak var myTextField: UITextField!
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var myTableView: UITableView!
    
    @IBAction func webBrowser(_ sender: Any)
    {
        performSegue(withIdentifier: "browser", sender: self)
    }
    
    
    
    
    
    @IBAction func buttonAction(_ sender: Any)
    {
        let alert = UIAlertController(title: "Share", message: "Share the page", preferredStyle: .actionSheet)
        
        let actionOne = UIAlertAction(title: "Share on Facebook", style: .default) { (action) in
            
            //Checking user is connected to Facebook
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook)
            {
                let post = SLComposeViewController(forServiceType: SLServiceTypeFacebook)!
                
                post.setInitialText("Share this on Facebook")
                post.add(UIImage(named: "img.png"))
                
                self.present(post, animated: true, completion: nil)
                
                
                
                
            }
            
            else
            {
                self.showAlert(service: "Facebook")
            }
            
            
            
            
        }
        
        
        //twitter functionality
        let actionTwo = UIAlertAction(title: "Share on Twitter", style: .default) { (action) in
            
            //Checking user is connected to Twitter
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter)
            {
                let post = SLComposeViewController(forServiceType: SLServiceTypeTwitter)!
                
                post.setInitialText("Share this on Twitter")
                post.add(UIImage(named: "img1.jpeg"))
                
                
                self.present(post, animated: true, completion: nil)
                
                
                
                
            }
                
            else
            {
                self.showAlert(service: "Twitter")
            }
            
            
            
            
        }
        
        let actionThree = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        
        
        
        
        
        
        //add to action sheet
        alert.addAction(actionOne)
        alert.addAction(actionTwo)
        alert.addAction(actionThree)
        
        //present alert 
        self.present(alert, animated: true, completion: nil)
        
        
        
    }
    
    func showAlert(service:String)
    {
        let alert = UIAlertController(title: "Error", message: "You are not connected to \(service)", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    var tweets:[String] = []
    
    //Activity Indicator 
    var activityIndicator = UIActivityIndicatorView()
    
    func startA()
    {
        UIApplication.shared.beginIgnoringInteractionEvents()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    
    
    //setting up table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    
    {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! myTableViewCell
        cell.myTextView.text = tweets[indexPath.row]
        return cell
    }
    
    
    
    @IBAction func search(_ sender: UIButton)
    {
        if myTextField.text != ""
        {
            startA()
            
            
            let user = myTextField.text?.replacingOccurrences(of: " ", with: "")
            getStuff(user: user!)
            
        }
    }
    
    //creating functions that gets all the stuff
    func getStuff(user:String)
    {
        let url = URL(string: "https://twitter.com/" + user)
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil
            {
                DispatchQueue.main.async
                {
                    if let errorMessage = error?.localizedDescription
                    {
                        self.myLabel.text = errorMessage
                    }
                    else
                    {
                        self.myLabel.text = "There has been an error. Try again"
                    }
                }
                
          
            }
            else
            {
                let webContent:String = String(data: data!, encoding:String.Encoding.utf8)!
                
                
                if webContent.contains("<title>") && webContent.contains("data-resolved-url-large=\"")
                
                {
                    
                    
                    //get name
                    var array:[String] = webContent.components(separatedBy: "<title>")
                    array = array[1].components(separatedBy: " |")
                    let name = array[0]
                    array.removeAll()
                    
                    //profile picture
                    array = webContent.components(separatedBy: "data-resolved-url-large=\"")
                    array = array[1].components(separatedBy: "\"")
                    let profilePicture = array[0]
                    print(profilePicture)
                    
                    
                    //get tweets
                    array = webContent.components(separatedBy: "data-aria-label-part=\"0\">")
                    array.remove(at: 0)
                    
                    for i in 0...array.count-1
                    {
                        let newTweet = array[i].components(separatedBy: "<")
                        array [i] = newTweet[0]
                    }
                    
                    self.tweets = array
                    
                    
                    
                    DispatchQueue.main.async
                    {
                        self.myLabel.text = name
                        self.updateImage(url: profilePicture)
                        self.myTableView.reloadData()
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                            
                    }

                    
                }
                else
                {
                    DispatchQueue.main.async {
                        self.myLabel.text = "Sorry we couldn't find that user"
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        


                    }
                }
                
                
            }
        }
        task.resume()
    }
    
    
    //fucntion that gets profile pic data
    func updateImage(url:String)
    {
        let url = URL(string: url)
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            DispatchQueue.main.async
            {
                self.myImageView.image = UIImage(data: data!)
            }
        }
        task.resume()
    }
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

