//
//  Notify.swift
//  ProjetoII
//
//  Created by João Victor Ipirajá de Alencar on 22/11/22.
//

import Foundation


//static var Rodando = Publisher(Name: Notification.Name("rodando"))
//static var Finalizou = Publisher(Name: Notification.Name("finalizou"))
//static var Espera = Publisher(Name: Notification.Name("espera"))


struct Notify{
    
    

    
    //Cria uma notificação
    
    let center = NotificationCenter.default
    
    private var nameString: String
    var name: NSNotification.Name
    private var token: NSObjectProtocol?
    
    var queue = OperationQueue.current
    
    var publisher: NotificationCenter.Publisher{
        get{
            return NotificationCenter.default.publisher(for: self.name)
        }
    }

    
    init(name: String){
        self.nameString = name
        self.name = Notification.Name(name)
    }
    
    func unregister(){
        if let notificationToken = token{
            NotificationCenter.default.removeObserver(notificationToken)
        }
    }
    
    mutating func register(){
        unregister()
        if(token == nil){
            
            self.token = center.addObserver(forName: name, object: nil, queue: queue) { (note) in
                
            }
            
        }
    }
    
}
