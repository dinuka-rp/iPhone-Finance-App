import UIKit

let defaults = UserDefaults.standard

defaults.set(0.24, forKey: "Volume")
var volume = defaults.float(forKey: "Volume")
defaults.set(0.56, forKey: "Volume")
volume = defaults.float(forKey: "Volume")


defaults.set(true, forKey: "MusicOn")
defaults.set("Dinuka", forKey: "PlayerName")
defaults.set(Date(), forKey: "AppLastOpenedByUser")

let array = [1,2,3]
defaults.set(array, forKey: "myArray")

let dictionary = ["name": "Dinuka"]
let dictionaryKey = "myDictionary"
defaults.set(dictionary, forKey: dictionaryKey)

let musicOnStatus = defaults.bool(forKey: "MusicOn")
let playerName = defaults.string(forKey: "PlayerName")
let appLastOpened = defaults.object(forKey: "AppLastOpenedByUser")
let myArray = defaults.array(forKey: "myArray")
let myDictionary = defaults.dictionary(forKey: dictionaryKey)
