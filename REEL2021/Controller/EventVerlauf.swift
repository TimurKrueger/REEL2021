//
//  File.swift
//  REEL2021
//
//  Created by Louis Hakim on 12.08.21.
//

import Foundation
import UIKit

class EventVerlauf: UIViewController {
    
    @IBOutlet weak var ScheduleDay: UITextField!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var ScheduleText: UITextView!
    
    
    let days = ["---","Jeudi", "Vendredi", "Samedi", "Dimanche"]
    
    var pickerView = UIPickerView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        ScheduleDay.inputView = pickerView
        
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        
    }
    
    
    
}

extension EventVerlauf: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return days.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return days[row]
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        ScheduleDay.text = days[row]
        ScheduleDay.resignFirstResponder()
        
        switch days[row] {
        
        case "Jeudi":
            DispatchQueue.main.async {
                self.label.text = "Jeudi: Journée de Rencontre"
                self.ScheduleText.text = "10:00 ACEL Workshops \n13:00 Déjeuner \n15:00 Présentation de nos partenaires et Foire \n19:00 Soirée avec nos partenaires" }
        case "Vendredi":
            DispatchQueue.main.async {
                self.label.text = "\(self.days[row]): Journée de Decouverte"
                self.ScheduleText.text = "8:00 Visites culturelles \n12:00 Déjeuner \n14:00 Rallye \n20:00 Dîner et Soirée publique" }
        case "Samedi":
            DispatchQueue.main.async {
                self.label.text = "\(self.days[row]): Journée officielle"
                self.ScheduleText.text = "10:00 Monologue et discussion avec un ministre \n12:00 Déjeuner \n14:00 Table Ronde \n20:00 Soirée chique avec dîner" }
        case "Dimanche":
            DispatchQueue.main.async {
                self.label.text = "\(self.days[row]): Journée détente"
                self.ScheduleText.text = "9:00 Activités de Détente \n13:00 Déjeuner \n16:00 Départ vers Luxembourg" }
        default:
            self.label.text = ""
            self.ScheduleText.text = ""
        }
    }
    }
    
    
    

