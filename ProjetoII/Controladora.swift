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
    
    var notificationEspera:Notify
    var notificationFinalizou:Notify

    
    var cancellables = Set<AnyCancellable>()
    
    @Published var processesFinalizados = Array<Process>()
    @Published var processesEntrou = Array<Process>()

    

    
//
//    func updateProcess(processo: Process){
//            if let index = try? self.processes.firstIndex(where: {$0.id == processo.id}) {
//                self.processes[index] = processo
//            }
//
//    }
    func addProcess(process: Process){
        
        self.processesEntrou.append(process)
        

        DispatchQueue.main.asyncAfter(deadline: .now() +         DispatchTimeInterval.seconds(process.tempoCriacaoSeconds)) {
            
            process.tempoCriacao = Date()
            NotificationCenter.default.post(name: self.notificationEspera.name, object: process)

        }
        

        
        
    }
    
    func listenToNotications(){
            self.cancellables.removeAll()
        
            self.notificationEspera.publisher
            .merge(with: self.notificationFinalizou.publisher)
            .sink { [unowned self] notification in
            if let process = notification.object as? Process{
                
                //processo chega
                
                if(process.isFinished){
                    // foi finalizado
                    
                    processesFinalizados.append(process)
                    
                }else{
                    
                    let ram = MemoriaRAMModel(tipo: .processo(processo: process))
                    NotificationCenter.default.post(name:Notification.Name("rodando"), object: ram)
                    
                    //self.queue.enqueue(process)

                }

             
              
               

            }
        }.store(in: &cancellables)
    }
    
    init(nf: Notify, ne: Notify){

            self.notificationEspera = ne
            self.notificationFinalizou = nf
            listenToNotications()

    }
}
