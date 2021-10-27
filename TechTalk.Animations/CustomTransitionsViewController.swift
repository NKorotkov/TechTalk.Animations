//
//  CustomTransitionsViewController.swift
//  TechTalk.Animations
//
//  Created by KOROTKOV Nikolay on 25.10.2021.
//

import UIKit

class CustomTransitionsViewController: UIViewController {
    
    private let text = "100,00 ₽"
    
    private let alternativeText = "537,20 ₽"
    
    private var nextText: String {
        label.text == text ? alternativeText : text
    }
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let transitions: [String : UIView.ExtraTransitions] = [
        "slideFromLeft" : .slideFromLeft,
        "slideFromTop" : .slideFromTop,
        "slideFromRight" : .slideFromRight,
        "slideFromBottom" : .slideFromBottom
    ]
    
    private lazy var transitionsKeys = transitions.map { $0.key }
    
    private lazy var picker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    
    lazy var currentTransition: UIView.ExtraTransitions = transitions[transitionsKeys.first!]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44)
        ])
        
        view.addSubview(picker)
        NSLayoutConstraint.activate([
            picker.leftAnchor.constraint(equalTo: view.leftAnchor),
            picker.rightAnchor.constraint(equalTo: view.rightAnchor),
            picker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Animate", style: .plain, target: self, action: #selector(animate))
    }
    
    @objc
    func animate() {
        /// Custom transition
        UIView.transition(
            with: label,
            duration: 0.3,
            transition: currentTransition
        ) {
            self.label.text = self.nextText
        }
    }
}

extension CustomTransitionsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        transitionsKeys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        transitionsKeys[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentTransition = transitions[transitionsKeys[row]]!
        animate()
    }
}
