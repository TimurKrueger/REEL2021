//
//  Schedule.swift
//  REEL2021
//
//  Created by Louis Hakim on 11.12.20.
//
/*
import Foundation
import UIKit


class Schedule: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var scheduleView: UITextView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var days = ["---","Jeudi", "Vendredi", "Samedi", "Dimanche"]
    
    override func viewWillAppear(_ animated: Bool) {
        scheduleView.text = "Choose a day"
        label.text = "Programme"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      pickerView.delegate = self
        pickerView.dataSource = self
    }
        
        // Customizing the textview
    /*
        scheduleView.backgroundColor = UIColor(red: 28, green: 37, blue: 67, alpha: 1)
        //scheduleView.backgroundColor = .secondarySystemBackground
        scheduleView.textColor = .secondaryLabel
        scheduleView.layer.cornerRadius = 20
        scheduleView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        // Give the textview a shadow
        scheduleView.layer.shadowColor = UIColor.gray.cgColor
        scheduleView.layer.shadowOffset = CGSize(width: 0.75, height: 0.75)
        scheduleView.layer.shadowOpacity = 0.4
        scheduleView.layer.shadowRadius = 20
        scheduleView.layer.masksToBounds = false
      */
    }


extension Schedule: UIPickerViewDelegate, UIPickerViewDataSource {
        
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
            switch days[row] {
            
            case "---":
                DispatchQueue.main.async {
                self.label.text = "Programme"
                self.scheduleView.text = "Choose a day" }
            case "Jeudi":
                DispatchQueue.main.async {
                    self.label.text = "Jeudi: Journ??e de Rencontre"
                    self.scheduleView.text = "10:00 ACEL Workshops \n13:00 D??jeuner \n15:00 Pr??sentation de nos partenaires et Foire \n19:00 Soir??e avec nos partenaires" }
            case "Vendredi":
                DispatchQueue.main.async {
                    self.label.text = "\(self.days[row]): Journ??e de Decouverte"
                    self.scheduleView.text = "8:00 Visites culturelles \n12:00 D??jeuner \n14:00 Rallye \n20:00 D??ner et Soir??e publique" }
            case "Samedi":
                DispatchQueue.main.async {
                    self.label.text = "\(self.days[row]): Journ??e officielle"
                    self.scheduleView.text = "10:00 Monologue et discussion avec un ministre \n12:00 D??jeuner \n14:00 Table Ronde \n20:00 Soir??e chique avec d??ner" }
            case "Dimanche":
                DispatchQueue.main.async {
                    self.label.text = "\(self.days[row]): Journ??e d??tente"
                    self.scheduleView.text = "9:00 Activit??s de D??tente \n13:00 D??jeuner \n16:00 D??part vers Luxembourg" }
            default:
                self.label.text = ""
                self.scheduleView.text = ""
            }
        }
        
        
    }

*/
