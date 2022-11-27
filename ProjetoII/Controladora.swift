//
//  Controladora.swift
//  ProjetoII
//
//  Created by João Victor Ipirajá de Alencar on 22/11/22.
//

import Foundation
import Combine

class Controladora: ObservableObject{
 
    
    //Recebe tanto quem espera, quanto finaliza
    
    var n1:Notify
    
    var cancellables = Set<AnyCancellable>()
    
    @Published var processes_finalizados = Array<Process>()

 
    func addProcess(process: Process){
        
        NotificationCenter.default.post(name: n1.name, object: process)
    }
    
    
    
    init(){
     
        self.n1 = Notify(name: "espera")
        self.n1.register()
        
        
            Notify.Tipo.Espera.It
           // .receive(on: DispatchQueue.global(qos: .userInteractive))
            .merge(with: Notify.Tipo.Finalizou.It)
            .sink { [unowned self] notification in
            if let process = notification.object as? Process{
                
                //processo chega
                
                if(process.isFinished){
                    // foi finalizado
                    processes_finalizados.append(process)
                    
                }else{
                    let ram = MemoriaRAMModel(tipo: .processo(processo: process))
                    NotificationCenter.default.post(name:Notification.Name("rodando"), object: ram)

                }
               

            }
        }.store(in: &cancellables)
        
       

    }
}
