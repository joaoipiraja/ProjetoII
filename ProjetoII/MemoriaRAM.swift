//
//  MemoriaRAM.swift
//  ProjetoII
//
//  Created by João Victor Ipirajá de Alencar on 22/11/22.
//

import Foundation
import Combine
import SwiftUI


enum EstrategiaAlocacao{
  case bestFit
  case firstFit
  case worstFit
}


class MemoriaRAM: ObservableObject{
    
    var cancellable: Cancellable?
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Published var queue = Queue<MemoriaRAMModel>()
    @Published var rams: Array<MemoriaRAMModel> = []
    
    var notificationRodando: Notify
    var notificationFinalizou: Notify
    
    
    let memoria = 40
    @Published var memoriaAlocada = 0
    
    
    func findRole(alg: EstrategiaAlocacao) -> Int?{
          
          var distance = self.rams.enumerated()

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
                  return try? self.rams.firstIndex(where: {$0.tipo == .buraco})
              case .worstFit:
                  return min?.0
          }
      }
    
    
    func index(processo: Process) -> Int?{
        return try? self.rams.firstIndex(where: { ram in
            
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
                self.rams[index].tipo = .buraco
            }
            self.mergeBuracos()

    }
    
    
    func mergeBuracos(){
        
    
       
            self.rams =  self.rams.sorted { $0.posicaoFim! < $1.posicaoFim!}
            let ram = MemoriaRAMModel(tipo: .buraco)
        
         
            
            if let index = try? self.rams.firstIndex(where: {$0.tipo == .buraco}){
                
                ram.posicaoInicio = self.rams[index].posicaoInicio
                    
                    for i in index+1..<self.rams.count{

                        if(self.rams[i].tipo == .buraco){
                                ram.posicaoFim = self.rams[i].posicaoFim!
                            
                                if(i >= self.rams.count-1){
                                    self.rams[index] = ram
                                    self.rams.removeSubrange(index+1...i)
                                    break
                                }
                            
                        } else {

                            if ram.posicaoFim != nil{
                                    self.rams[index] = ram
                                    self.rams.removeSubrange(index+1...i)
                            }
                            break
                        }
                        
                        
                    }
                

            }
        
           
        
    }
    
    func enqueue(){
  
                if(self.memoriaAlocada <= self.memoria){
                        //executa o algoritmo
                        if let fila = self.queue.dequeue(){
                            

                            switch fila.tipo{
                                
                            case .so:
                                break
                            case .processo(processo: let p):
                                addProcess(ram: fila)
                                self.memoriaAlocada += p.tamanhoProcesso
                                NotificationCenter.default.post(name: self.notificationRodando.name, object: p)

                            case .buraco:
                                break
                            }
                        }
                }
    }
    
    func addProcess(ram: MemoriaRAMModel){
        
        
        

        
                
        if let index = findRole(alg: .worstFit){
                
                
                switch ram.tipo{
                    
                    case .so:
                        break
                    case .processo(processo: let processo):
                
                    if(self.rams[index].posicaoFim! - self.rams[index].posicaoInicio! >= processo.tamanhoProcesso ){
                        ram.posicaoInicio = self.rams[index].posicaoInicio
                        ram.posicaoFim =  ram.posicaoInicio! + processo.tamanhoProcesso

                        
                    
                        if(index+1 > self.rams.count){
                            
                            let aux = self.rams[index]
                            aux.posicaoInicio = ram.posicaoFim! + 1
                            aux.posicaoFim =  self.rams[index].posicaoFim
                            
            
                            
                            if(aux.posicaoInicio! >= aux.posicaoFim!){
                                    self.rams[index] = ram
                                
                            }else{
                                    self.rams[index] = ram
                                    self.rams[index+1] = aux
                                
                            }


                            
                        }else{
                            let aux = self.rams[index]
                            aux.posicaoInicio = ram.posicaoFim! + 1
                            aux.posicaoFim = self.rams[index].posicaoFim
                            


                            if(aux.posicaoInicio! >= aux.posicaoFim!){
                                    print("n mudou")
                                    self.rams[index] = ram
                                
                            }else{
                                    self.rams[index] = ram
                                    self.rams.append(aux)
                            }


                        }
                    }
                        
                        
                    case .buraco:
                        break
                    }
                
            }
        
        self.rams =  self.rams.sorted { $0.posicaoFim! < $1.posicaoFim!}
            
                
        

       
    }
    
    func inicial(){
        let so = MemoriaRAMModel(tipo: .so, posicaoInicio: 0, posicaoFim: 99)
        let buraco = MemoriaRAMModel(tipo: .buraco, posicaoInicio: 100, posicaoFim: 140)
        
        rams.append(so)
        rams.append(buraco)

    }
    
    init(nr: Notify, nf: Notify){
        
        self.notificationRodando = nr
        self.notificationFinalizou = nf
        
        self.inicial()
        self.cancellable =
            self.notificationRodando.publisher
            .zip(timer)
            .sink { [unowned self] (notification,timer) in
                
                
                if let ram = notification.object as? MemoriaRAMModel{
                    
                   

                    //addProcess(ram: ram)
                    self.queue.enqueue(ram)
           

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
                        

                }
                enqueue()

                
        }
    }
}
