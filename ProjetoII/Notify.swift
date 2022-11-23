//
//  Notify.swift
//  ProjetoII
//
//  Created by João Victor Ipirajá de Alencar on 22/11/22.
//

import Foundation

struct Notify{
    
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
