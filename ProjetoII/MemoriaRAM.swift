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
    var estrategiaAlocacao: EstrategiaAlocacao
    
    var memoria: Int
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
                return false
            case .processo(processo: let p):
                return p.id == processo.id
            case .buraco:
                return false

            }
        })
    }

    
    func removeProcess(processo: Process){
        
            if let index = self.index(processo: processo){
                self.viewModel.rams[index].tipo = .buraco

            }
            self.mergeBuracos()

    }
    
    
    func mergeBuracos(){
        
        
        if let indexFirst = try? self.viewModel.rams.firstIndex(where: {$0.tipo == .buraco}){
            
            if let indexLast = try? self.viewModel.rams.lastIndex(where: {$0.tipo == .buraco}){
                let ram = MemoriaRAMModel(tipo: .buraco,
                                          posicaoInicio: self.viewModel.rams[indexFirst].posicaoInicio ,
                                          posicaoFim: self.viewModel.rams[indexLast].posicaoFim! - (indexLast - indexFirst))
               
                if(indexLast > indexFirst){
                    self.viewModel.rams[indexFirst] = ram
                    self.viewModel.rams.removeSubrange(indexFirst+1...indexLast)
                }
                
            }
        }
        //     0         1                2
        // [0 1 2 3] [4 5 6 7] 8 9 10 [11 12 13]
        // 0 1 2 3 4 5 6 7 8 9 9 10
        /*
         index = 1
         index_final = 2     ultimo buraco da memoria
         cont = 0, 1        qntd de vezes que pulou um buraco
         */
      
//            var soma: Int = 0
//
//
//            if let index = try? self.viewModel.rams.firstIndex(where: {$0.tipo == .buraco}){
//
//                print(index)
//
//
//                var index_final = -1
//                    // 0, 1, 2
//                    // index = 1
//                    for i in 0..<self.viewModel.rams.count{
//
//
//                            if self.viewModel.rams[i].tipo == .buraco{
//                                soma += self.viewModel.rams[i].posicaoFim! - self.viewModel.rams[i].posicaoInicio!
//                                index_final = i
//                            }
//
//
//
//                    }
//
//
//                if index_final >= 0 {
//
//
//                    /*
//                     0        4     8
//                    S.O.      B     B
//                     3        7     10
//                     */
//
//                        let aux = MemoriaRAMModel(
//                            tipo: .buraco,
//                            posicaoInicio: self.viewModel.rams[index].posicaoInicio, // 4
//                            posicaoFim: self.viewModel.rams[index].posicaoFim! + soma) // 9
//                        self.viewModel.rams[index] = aux
//
//                    self.viewModel.rams.removeSubrange(index+1...index_final)
//                }
//
//            }
//
//
//
        
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
        }).first ?? 0) < self.memoria){
                        //executa o algoritmo
                        if let fila = self.queue.dequeue(){
                            
                            
                            switch fila.tipo{
                                
                            case .so:
                                break
                            case .processo(processo: let p):

                                NotificationCenter.default.post(name: self.notificationRodando.name, object: p)
                                addProcess(ram: fila)
                                
                                
                                    memoriaAlocada = self.viewModel.rams.map { ram in
                                    switch ram.tipo{

                                    case .so:
                                        return 0
                                    case .processo(processo: let p):
                                        return p.tamanhoProcesso
                                    case .buraco:
                                        return 0
                                    }
                                }.reduce(0){$0 + $1}

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
                    
                
                        ram.posicaoInicio = aux.posicaoInicio //100
                        ram.posicaoFim =  aux.posicaoInicio! + processo.tamanhoProcesso //101
                    
                        aux.posicaoInicio = ram.posicaoFim! + 1 //102
                        aux.posicaoFim =  aux.posicaoFim! + 1
                        
                    
                    if((aux.posicaoFim! -  aux.posicaoInicio!) <= self.memoria - self.memoriaAlocada){
                        
                        
                        if(index+1 > self.viewModel.rams.count){
                            self.viewModel.rams[index] = ram
                            self.viewModel.rams[index+1] = aux
                        }else{
                            self.viewModel.rams[index] = ram
                            self.viewModel.rams.append(aux)
                        }
                        
                        
                        
                    }else{
                        self.viewModel.rams[index] = ram

                    }

    
                    case .buraco:
                        break
                    }
                
            }
        
        self.viewModel.rams =  self.viewModel.rams.sorted { $0.posicaoInicio! < $1.posicaoInicio!}
        

        

       
    }
    
  
    
    init( nr: Notify, nf: Notify, memoriaSize:Int, so: MemoriaRAMModel, alocacao: EstrategiaAlocacao){
        
        self.notificationRodando = nr
        self.notificationFinalizou = nf
        
        let buraco = MemoriaRAMModel(tipo: .buraco, posicaoInicio: so.posicaoFim!+1, posicaoFim: so.posicaoFim!+1+memoriaSize)
        
        self.memoria = memoriaSize
        self.estrategiaAlocacao = alocacao
        
        self.viewModel.rams.append(so)
        self.viewModel.rams.append(buraco)
        
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
                            
                            
                            processM.isFinished = true
                            NotificationCenter.default.post(name: self.notificationFinalizou.name, object: processM)

                            self.removeProcess(processo: process)
                            
                            

                            memoriaAlocada = self.viewModel.rams.map { ram in
                                switch ram.tipo{

                                case .so:
                                    return 0
                                case .processo(processo: let p):
                                    return p.tamanhoProcesso
                                case .buraco:
                                    return 0
                                }
                            }.reduce(0){$0 + $1}
                            
                            

                            
                        }else{
                            NotificationCenter.default.post(name: self.notificationRodando.name, object: processM)

                        }
                    enqueue()



                }

                
        }
    }
}
