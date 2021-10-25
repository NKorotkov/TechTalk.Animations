//
//  TransitionsViewController.swift
//  TechTalk.Animations
//
//  Created by KOROTKOV Nikolay on 25.10.2021.
//

import UIKit

class TransitionsViewController: UIViewController {
    
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
    
    private let transitions: [String : UIView.AnimationOptions] = [
        "transitionCurlUp" : .transitionCurlUp,
        "transitionCurlDown" : .transitionCurlDown,
        "transitionCrossDissolve" : .transitionCrossDissolve,
        "transitionFlipFromTop" : .transitionFlipFromTop,
        "transitionFlipFromLeft" : .transitionFlipFromLeft,
        "transitionFlipFromRight" : .transitionFlipFromRight,
        "transitionFlipFromBottom" : .transitionFlipFromBottom
    ]
    
    private lazy var transitionsKeys = transitions.map { $0.key }
    
    private lazy var picker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    
    lazy var currentTransition: UIView.AnimationOptions = transitions[transitionsKeys.first!]!
    
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(animate))
    }
    
    @objc
    func animate() {
        /// Animates only **animatable** UI changes
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.repeat, .autoreverse]
        ) {
            self.label.transform = .init(scaleX: 1.5, y: 1.5)
        }
        
        /// Animates **non-animatable** UI changes
//        UIView.transition(with: label, duration: 1, options: [.repeat, .autoreverse]) {
//            self.label.text = self.nextText
////            self.label.backgroundColor = self.label.backgroundColor == .red ? .green : .red
//        }
    }
}

extension TransitionsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
