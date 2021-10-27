//
//  CustomLayerPropertiesViewController.swift
//  TechTalk.Animations
//
//  Created by KOROTKOV Nikolay on 27.10.2021.
//

import UIKit

class CustomLayerPropertiesViewController: UIViewController {
    
    private let progressValues: [CGFloat] = Array(0...10).map { CGFloat($0) / 10 }
    
    private lazy var picker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    
    private let progressView: ProgressBarView = {
        let view = ProgressBarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            progressView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24),
            view.rightAnchor.constraint(equalTo: progressView.rightAnchor, constant: 24),
            progressView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        view.addSubview(picker)
        NSLayoutConstraint.activate([
            picker.leftAnchor.constraint(equalTo: view.leftAnchor),
            picker.rightAnchor.constraint(equalTo: view.rightAnchor),
            picker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    
    }
    
    @objc
    func animateProgressBar(to percent: CGFloat) {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: []
        ) {
            self.progressView.percent = percent
        }
    }
}

extension CustomLayerPropertiesViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        progressValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        "\(Int(progressValues[row] * 100)) %"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        animateProgressBar(to: progressValues[row])
    }
}

class ProgressBarLayer: CALayer {
    @NSManaged var percent: CGFloat
    
    // MARK: - Init
    
    override init() {
        super.init()
    }
     
    override init(layer: Any) {
        super.init(layer: layer)
        if let layer = layer as? ProgressBarLayer {
            percent = layer.percent
        }
    }
     
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Animation
    /*
     Метод определяет, должен ли слой перерисовываться при изменении свойства с именем key.
     */
    override class func needsDisplay(forKey key: String) -> Bool {
        if self.animationIsCustom(for: key) {
            return true
        }
        
        return super.needsDisplay(forKey: key)
    }
     
    private class func animationIsCustom(for key: String) -> Bool {
        return key == "percent"
    }
    
    /*
     Метод определяет, будет ли анимация (в общем случае любой CAAction) при изменении свойства с именем event.
     Через него можно как добавить анимации новым свойствам, так и отключить нежелательные неявные анимации в слое.
     */
    override func action(forKey event: String) -> CAAction? {
        if ProgressBarLayer.animationIsCustom(for: event) {
            /*
             Нам нужно создать объект CABasicAnimation (удовлетворяет CAAction)
             c учетом всех параметров текущей транзакции. Проще всего взять готовую системную анимацию, например для backgroundColor
             и поменять в ней только нужные нам параметры, а именно keyPath и toValue.
             */
            if let animation = super.action(forKey: "backgroundColor") as? CABasicAnimation {
                animation.keyPath = event
                if let pLayer = presentation() {
                    animation.fromValue = pLayer.percent
                }
                animation.toValue = nil
                return animation
            }
            // Принудительная перерисовка
            setNeedsDisplay()
            return nil
        }
        return super.action(forKey: event)
    }
}


class ProgressBarView: UIView {
    // Прокси к свойству слоя
    var percent: CGFloat {
        set {
            if let layer = layer as? ProgressBarLayer {
                layer.percent = newValue
            }
        }
        get {
            if let layer = layer as? ProgressBarLayer {
                return layer.percent
            }
            return 0.0
        }
    }
    
    private let fillView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let progressLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
 
    // При инициализации вьюха создаст инстанс своего backing layer этого класса
    override class var layerClass: AnyClass { ProgressBarLayer.self }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(fillView)
        clipsToBounds = true
        backgroundColor = UIColor.white.withAlphaComponent(0.1)
        
        addSubview(progressLabel)
        NSLayoutConstraint.activate([
            progressLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            progressLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.height * 0.5
    }
    
    override func display(_ layer: CALayer) {
        /*
         Тут происходит "перерисовка" вьюхи. Может вызываться по разным причинам, но нас интересует два кейса:
         1) Когда мы сами вызываем setNeedsDisplay() у backing layer в методе action(forKey:), у слоя дальше вызывается метод display(), который в первую очередь обратиться к делегату, то есть view, и вызовет display(_:)
         2) Такие же обращения будут происходить во время анимации при отрисовке каждого кадра.
         */
        if let pLayer = layer.presentation() as? ProgressBarLayer {
            fillView.frame = CGRect(x: 0, y: 0, width: bounds.width * pLayer.percent, height: bounds.height)
            progressLabel.text = "\(Int(pLayer.percent * 100))"
        }
    }
}
