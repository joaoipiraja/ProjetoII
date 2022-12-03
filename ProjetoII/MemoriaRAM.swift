//
//  MemoriaRAM.swift
//  ProjetoII
//
//  Created by João Victor Ipirajá de Alencar on 22/11/22.
//

import Foundation
import Combine
import SwiftUI


enum EstrategiaAlocacao:String, CaseIterable{
    
  case bestFit = "Best Fit"
  case firstFit = "First Fit"
  case worstFit = "Worst Fit"
    
  var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }

}


class ViewModel: ObservableObject{
    @Published var rams: Array<MemoriaRAMModel> = []

}

class MemoriaRAM: ObservableObject{
    
    var cancellable: Cancellable?
    var timer = Timer.publish(every: 1, on: .current, in: .default).autoconnect()
    
    @Published var queue: Queue<MemoriaRAMModel> = .init()
    
    @ObservedObject var viewModel: ViewModel = .init()
    
    var notificationRodando: Notify
    var notificationFinalizou: Notify
    var estrategiaAlocacao: EstrategiaAlocacao = .firstFit
    
    var memoria: Int = 0
    var memoriaTotal: Int = 0
    @Published var memoriaAlocada = 0
    
    
    func findRole(alg: EstrategiaAlocacao) -> Int?{
          
          var distance = self.viewModel.rams.enumerated()

              .map { (index,ram) in
              switch ram.tipo{
                      
                  case .so:
                      return (index,0)
                  case .processo(processo: _):
                      return (index,0)
                  case .buraco:
                      return (index,ram.posicaoFim! - ram.posicaoInicio!)
              }
              }.filter {$0.1 > 0}
          
          
          let max = distance.sorted(by: {$0.1 > $1.1}).first
          let min = distance.sorted(by: {$0.1 < $1.1}).first
          
          

          
          switch alg{
              case .bestFit:
                  return max?.0
              case .firstFit:
                  return try? self.viewModel.rams.firstIndex(where: {$0.tipo == .buraco})
              case .worstFit:
                  return min?.0
          }
      }
    
    
    func index(processo: Process) -> Int?{
        return try? self.viewModel.rams.firstIndex(where: { ram in
            
            switch ram.tipo{
            case .so:
                break
            case .processo(processo: let p):
                return p.id == processo.id
            case .buraco:
                break
            }
            return false
        })
    }

    
    func removeProcess(processo: Process){
            if let index = self.index(processo: processo){
                self.viewModel.rams[index].tipo = .buraco
            }
            self.mergeBuracos()

    }
    
    
    func mergeBuracos(){
        
        if let indexFirst = try? viewModel.rams.firstIndex(where: { $0.tipo == .buraco}){
            if let indexLast = try? viewModel.rams.lastIndex(where: { $0.tipo == .buraco}){
                let ram = MemoriaRAMModel(tipo: .buraco, posicaoInicio: self.viewModel.rams[indexFirst].posicaoInicio, posicaoFim: self.viewModel.rams[indexLast].posicaoFim! - (indexLast-indexFirst))
               
                
                if(indexLast > indexFirst){
                    self.viewModel.rams[indexFirst] = ram
                    self.viewModel.rams.removeSubrange(indexFirst+1...indexLast)
                    
                    
                }
            }
        }
        
            self.viewModel.objectWillChange.send()
        
           
        
    }
    
    func enqueue(){
  
        if(self.memoriaAlocada + (self.queue.elements.map({ r in
            switch r.tipo{
            case .so:
                return 0
            case .processo(processo: let p):
                return p.tamanhoProcesso
            case .buraco:
                return 0
            }
        }).first ?? 0) <= self.memoria){
                        //executa o algoritmo
                        if let fila = self.queue.dequeue(){
                            
                            
                            switch fila.tipo{
                                
                            case .so:
                                break
                            case .processo(processo: let p):

                                NotificationCenter.default.post(name: self.notificationRodando.name, object: p)
                                addProcess(ram: fila)
                                self.memoriaAlocada += p.tamanhoProcesso

                            case .buraco:
                                break
                            }
                        }
                }
        
        self.viewModel.objectWillChange.send()

    }
    
    func addProcess(ram: MemoriaRAMModel){
        
        
                
        if let index = findRole(alg:  self.estrategiaAlocacao){
                
                
                switch ram.tipo{
                    
                    case .so:
                        break
                    case .processo(processo: let processo):
                    
                        //Se basea no tamanaho e particiona
                        //Particiona
                    
                        var aux = self.viewModel.rams[index]

                
                        ram.posicaoInicio = aux.posicaoInicio
                        ram.posicaoFim =  aux.posicaoInicio! + processo.tamanhoProcesso
                    
                        if((ram.posicaoFim! -  ram.posicaoInicio!) >= (self.memoria - self.memoriaAlocada) && (ram.posicaoFim! -  ram.posicaoInicio!) > 0){
                            self.viewModel.rams[index] = ram
                        }else{
                            aux.posicaoInicio = ram.posicaoFim! + 1
                            aux.posicaoFim! += 1
                            
                            if(index+1 > self.viewModel.rams.count){
                                self.viewModel.rams[index] = ram
                                self.viewModel.rams[index+1] = aux
                            }else{
                                self.viewModel.rams[index] = ram
                                self.viewModel.rams.append(aux)
                            }
                            
                        }

    
                    case .buraco:
                        break
                    }
                
            }
        
       
        
        self.viewModel.objectWillChange.send()

        

       
    }
    
  
    
    init( nr: Notify, nf: Notify){
        
        self.notificationRodando = nr
        self.notificationFinalizou = nf
        
     
        self.cancellable =
            self.notificationRodando.publisher
            .zip(timer)
            .sink { [unowned self] (notification,timer) in
                
                
                if let ram = notification.object as? MemoriaRAMModel{
                    
                   

                    //addProcess(ram: ram)
                    self.queue.enqueue(ram)
                    enqueue()
           

                }else if let process = notification.object as? Process{
                

                        var processM = process
                        
                        if processM.addTime(tempo: timer){
                            self.removeProcess(processo: process)
                            processM.isFinished = true
                            memoriaAlocada -= process.tamanhoProcesso
                            NotificationCenter.default.post(name: self.notificationFinalizou.name, object: processM)
                        }else{
                            NotificationCenter.default.post(name: self.notificationRodando.name, object: processM)
                        }
                    enqueue()


                }

                self.viewModel.rams =  self.viewModel.rams.sorted { $0.posicaoInicio! < $1.posicaoInicio!}
              
        }
    }
}
