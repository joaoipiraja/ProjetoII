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
    let name = Notification.Name("finalizou")
    let nameEspera = Notification.Name("espera")
    
    var queue = Queue<Process>()
    @Published var processes = Array<Process>()
    
    
    
    let memoria = 40
    var memoriaAlocada = 0
    
    
    
    func updateProcess(processo: Process){
        DispatchQueue.main.async {
            if let index = try? self.processes.firstIndex(where: {$0.id == processo.id}) {
                self.processes[index] = processo
            }
        }
    }
    func addProcess(){
        let p1 = Process(duracaoProcesso: 10, tamanhoProcesso: 20)
        
        DispatchQueue.main.async {
            self.processes.append(p1)
        }
        NotificationCenter.default.post(name: n1.name, object: p1)
    }
    
    
    
    init(){
     
        self.n1 = Notify(name: "espera")
        self.n1.register()
        
        
        NotificationCenter.default
            
            .publisher(for: nameEspera)
            .merge(with:  NotificationCenter.default
                .publisher(for: name))
        
            .sink { [unowned self] notification in
            if let process = notification.object as? Process{
                
                
                //Aqui que decide qual algoritmo usar?
                
                //First Fit
                
                
                if(process.isFinished){
                    self.memoriaAlocada -= process.tamanhoProcesso
                    updateProcess(processo: process)
                    
                }else{
                   // DispatchQueue.main.async {
                        self.queue.enqueue(process)
                    //}
                    
                }
                
                print("\(memoriaAlocada)/\(memoria)")
                
                    if(self.memoriaAlocada + process.tamanhoProcesso <= self.memoria){
                        if let process = self.queue.dequeue(){
                            let ram = MemoriaRAMModel(processo: process)
                            NotificationCenter.default.post(name:Notification.Name("rodando"), object: ram)
                            self.memoriaAlocada += process.tamanhoProcesso
                        }
                       
                    }
                
               

            }
        }.store(in: &cancellables)
        
       

    }
}
