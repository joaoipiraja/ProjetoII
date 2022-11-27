//
//  Notify.swift
//  ProjetoII
//
//  Created by João Victor Ipirajá de Alencar on 22/11/22.
//

import Foundation

struct Publisher{
    
    var Name: Notification.Name
    var It: NotificationCenter.Publisher{
        get{
            return NotificationCenter.default.publisher(for: Name)
        }
    }
    
    
    
}

struct Notify{
    
    
    struct Tipo{
        
        static var Rodando = Publisher(Name: Notification.Name("rodando"))
        static var Finalizou = Publisher(Name: Notification.Name("finalizou"))
        static var Espera = Publisher(Name: Notification.Name("espera"))
        
    }
    
    //Cria uma notificação
    
    let center = NotificationCenter.default
    var name: NSNotification.Name
    private var token: NSObjectProtocol?
    var queue = OperationQueue.current

    
    init(name: String){
        self.name = Notification.Name(name)
    }
    
    func unregister(){
        if let notificationToken = token{
            NotificationCenter.default.removeObserver(notificationToken)
        }
    }
    
    mutating func register(){
        if(token == nil){
            
            self.token = center.addObserver(forName: name, object: nil, queue: queue) { (note) in
                
            }
            
        }
    }
    
}
