//
//  Controladora.swift
//  ProjetoII
//
//  Created by João Victor Ipirajá de Alencar on 22/11/22.
//

import Foundation
import Combine
import SwiftUI




class Controladora: ObservableObject{
 
    class ViewModel: ObservableObject{
        @Published var processesFinalizados = Array<Process>()
        @Published var processesEntrou = Array<Process>()
        
        var isFinished: Bool{
            get{
                return self.processesFinalizados.count == self.processesEntrou.count
            }
        }
        var processesNotExec: Array<Process> {
            get{
                return self.processesEntrou.filter{$0.tempoCriacao == nil}
            }
        }
        
        
        
        func calculateTempoMedio() -> Double{
            let soma = self.processesFinalizados.filter{ $0.isFinished}.reduce(0.0) { $0 + ($1.tempoAtual! - $1.tempoCriacao!)}
            return soma/Double(self.processesFinalizados.count)
        }
    }
    
    //Recebe tanto quem espera, quanto finaliza
    
    var notificationEspera:Notify
    var notificationFinalizou:Notify
    var notificationRodando:Notify
    
    var cancellables = Set<AnyCancellable>()
    
    @Published var viewModel: ViewModel = .init()
    

    func calculateWatingTime(process: Process) -> DispatchTimeInterval{
        let secondsSum = self.viewModel.processesEntrou.map { p in
            if(p.id != process.id){
                return p.tempoCriacaoSeconds
            }else{
                return 0
            }
        }.reduce(0) {$0 + $1}
        
        return DispatchTimeInterval.seconds(process.tempoCriacaoSeconds + secondsSum)
    }
    func addProcess(process: Process){
        
        self.viewModel.processesEntrou.append(process)
        
        DispatchQueue.main.asyncAfter(deadline: .now() +  calculateWatingTime(process: process)) {
            
            process.tempoCriacao = Date()
            NotificationCenter.default.post(name: self.notificationEspera.name, object: process)

        }
  
    }
    
    
    
    init(nf: Notify, ne: Notify, nr:Notify){

            self.notificationEspera = ne
            self.notificationFinalizou = nf
            self.notificationRodando = nr
        
            self.notificationEspera.publisher
            .merge(with: self.notificationFinalizou.publisher)
            .sink { [unowned self] notification in
            if let process = notification.object as? Process{
                
                //processo chega
                
                if(process.isFinished){
                    // foi finalizado
                    
                    self.viewModel.processesFinalizados.append(process)
                    
                }else{
                    let ram = MemoriaRAMModel(tipo: .processo(processo: process))
                    NotificationCenter.default.post(name: nr.name, object: ram)
                    
                    //self.queue.enqueue(process)

                }

             
              
               

            }
        }.store(in: &cancellables)
        
       

    }
}
