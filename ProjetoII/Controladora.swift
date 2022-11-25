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
    let callFinalizou = Notification.Name("finalizou")
    let callEspera = Notification.Name("espera")
    
    var queue = Queue<Process>()
    @Published var processes = Array<Process>()

    
    let memoria = 40
    var memoriaAlocada = 0
    
    
    func firstFit(completion: (Process) -> ()){
        if let process = self.queue.dequeue(){
            completion(process)
        }
    }
    
    func bestFit(completion: (Process) -> ()){
        if let process = self.queue.dequeue(){
            completion(process)
        }
    }
    
    func worstFit(completion: (Process) -> ()){
        if let process = self.queue.dequeue(){
            completion(process)
        }
    }
    
    
    
    func updateProcess(processo: Process){
        DispatchQueue.main.async {
            if let index = try? self.processes.firstIndex(where: {$0.id == processo.id}) {
                self.processes[index] = processo
            }
        }
    }
    func addProcess(process: Process){
        
        DispatchQueue.main.async {
            self.processes.append(process)
        }
        NotificationCenter.default.post(name: n1.name, object: process)
    }
    
    
    
    init(){
     
        self.n1 = Notify(name: "espera")
        self.n1.register()
        
        
        NotificationCenter.default
            
            .publisher(for: callEspera)
            .merge(with:  NotificationCenter.default
            .publisher(for: callFinalizou))
        
            .sink { [unowned self] notification in
            if let process = notification.object as? Process{
                
                //processo chega
                
                if(process.isFinished){
                    // foi finalizado
                    
                    self.memoriaAlocada -= process.tamanhoProcesso
                    updateProcess(processo: process)
                    
                }else{
                    // vai para fila de espera
                    self.queue.enqueue(process)
                }
                    //Verifica se há espaço
                    if(self.memoriaAlocada + process.tamanhoProcesso <= self.memoria){
                        
                        //executa o algoritmo
                        self.firstFit { process in
                            let ram = MemoriaRAMModel(tipo: .processo(processo: process))
                            NotificationCenter.default.post(name:Notification.Name("rodando"), object: ram)
                            self.memoriaAlocada += process.tamanhoProcesso
                        }
                       
                    }
                
               

            }
        }.store(in: &cancellables)
        
       

    }
}
