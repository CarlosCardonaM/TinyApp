//
//  AddViewController.swift
//  TinyApp
//
//  Created by Carlos Cardona on 21/04/21.
//

import UIKit
import RxSwift
import RxRelay

class AddViewController: UIViewController {
    
    static let instance = AddViewController()
    
    let home = HomeViewController()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var nameTextfield: UITextField!
    
    @IBOutlet weak var gastoTextfield: UITextField!
    
    
    var addGastoObservable: Observable<Double> {
        return addGastoSubject.asObserver()
    }
    var addGastoSubject = PublishSubject<Double>()
    
    
    var modify: Observable<String> {
        return modifySubject.asObserver()
    }
    var modifySubject = PublishSubject<String>()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gastoTextfield.keyboardType = .decimalPad
        
        nameTextfield.becomeFirstResponder()
    }
    
    
    @IBAction func listoClicked(_ sender: Any) {
        
        guard let name = nameTextfield, let gasto = gastoTextfield, !name.text!.isEmpty, !gasto.text!.isEmpty else { return }
        
        let newItem = Item(context: self.context)
        
        newItem.nombre = name.text
        newItem.gasto = Double(gasto.text!)!
        newItem.ahorro = Double(gasto.text!)! * 0.03
        
        addGastoSubject.onNext(Double(gasto.text!)! * 0.03)
        modifySubject.onNext(name.text!)
        
        addGastoSubject.onCompleted()
        
    }
    
}
