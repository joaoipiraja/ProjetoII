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





class MemoriaRAM: ObservableObject{
    
    class ViewModel: ObservableObject{
        @Published var processosEmExecucao: Array<MemoriaRAMModel> = []
        @Published var memoriaTotal: Int = 0
        @Published var memoria: Int = 0
        @Published var memoriaAlocada = 0
        @Published var estrategiaAlocacao: EstrategiaAlocacao = .firstFit
    }
    
    var cancellable: Cancellable?
    var timer = Timer.publish(every: 1, on: .current, in: .default).autoconnect()
    
    @Published var filaEspera: Queue<MemoriaRAMModel> = .init()
    @Published var viewModel: ViewModel = .init()
    
    var notificationRodando: Notify
    var notificationFinalizou: Notify
    
    
    
    func findRole(alg: EstrategiaAlocacao) -> Int?{
          
        var distance = self.viewModel.processosEmExecucao.enumerated()

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
                  return min?.0
              case .firstFit:
              return try? self.viewModel.processosEmExecucao.firstIndex(where: {$0.tipo == .buraco})
              case .worstFit:
                  return max?.0
          }
      }
    
    
    func index(processo: Process) -> Int?{
        return try?self.viewModel.processosEmExecucao.lastIndex(where: { ram in
            
            switch ram.tipo{
            case .so:
                return false
            case .processo(processo: let p):
                return p.id == processo.id
            case .buraco:
                return true

            }
        })
    }

    
    func removeProcess(processo: Process){
            
            if let index = self.index(processo: processo){
                self.viewModel.processosEmExecucao[index].tipo = .buraco
                self.objectWillChange.send()
                self.mergeBuracos()
            }
        
    }
    
    
    func mergeBuracos(){
            
                self.viewModel.processosEmExecucao =  self.viewModel.processosEmExecucao.sorted { $0.posicaoInicio! < $1.posicaoInicio!}
            

                let ram = MemoriaRAMModel(tipo: .buraco)
            
             
                
                if let index = try? self.viewModel.processosEmExecucao.firstIndex(where: {$0.tipo == .buraco}){
                    
                    ram.posicaoInicio = self.viewModel.processosEmExecucao[index].posicaoInicio
                    
                    var cont = 1
                    var index_final = -1
                        
                        for i in index+1..<self.viewModel.processosEmExecucao.count{
                            
                            switch self.viewModel.processosEmExecucao[i].tipo{
                                
                                case .so:
                                    break
                                case .processo(processo: _):
                                    break
                                case .buraco:
                                    if(i == index+1){
                                        ram.posicaoFim = self.viewModel.processosEmExecucao[i].posicaoFim!

                                    }else{
                                        ram.posicaoFim = self.viewModel.processosEmExecucao[i].posicaoFim!
                                    }
                                    index_final = i
                                    break
                                
                            }

                        }
                    
                    if index_final >= 0 {
                        self.viewModel.processosEmExecucao[index] = ram
                        self.viewModel.processosEmExecucao.removeSubrange(index+1...index_final)
                    }

                }
            
                self.viewModel.objectWillChange.send()
            
               
            
        }
    
    func sizeOfCurrentProcess() -> Int{
        
        let arrayOfSizes = self.filaEspera.elements.map({ r in
            switch r.tipo{
            case .so:
                return 0
            case .processo(processo: let p):
                return p.tamanhoProcesso
            case .buraco:
                return 0
            }
        })
        return arrayOfSizes.first ?? 0
    }
    
    func sumOfProcessesSizes() -> Int{
        return self.viewModel.processosEmExecucao.map { ram in
            switch ram.tipo{

            case .so:
                return 0
            case .processo(processo: let p):
                return p.tamanhoProcesso
            case .buraco:
                return 0
            }
        }.reduce(0){$0 + $1}

    }
    
    func enqueue(){
   
        if(self.viewModel.memoriaAlocada + sumOfProcessesSizes() <= self.viewModel.memoria){
                         //executa o algoritmo
            if let fila = self.filaEspera.dequeue(){
                             
                             
                             switch fila.tipo{
                                 
                             case .so:
                                 break
                             case .processo(processo: let p):

                                 NotificationCenter.default.post(name: self.notificationRodando.name, object: p)
                                 addProcess(ram: fila)
                                 self.viewModel.memoriaAlocada += p.tamanhoProcesso

                             case .buraco:
                                 break
                             }
                         }
                 }
         
         self.viewModel.objectWillChange.send()

     }
    
    func addProcess(ram: MemoriaRAMModel){
        
        
                
        if let index = findRole(alg:  self.viewModel.estrategiaAlocacao){
                
                
                switch ram.tipo{
                    
                    case .so:
                        break
                    case .processo(processo: let processo):
                    
                        //Se basea no tamanaho e particiona
                        //Particiona
                    
                        var aux = self.viewModel.processosEmExecucao[index]

                
                        ram.posicaoInicio = aux.posicaoInicio
                        ram.posicaoFim =  aux.posicaoInicio! + processo.tamanhoProcesso
                    
                    if((ram.posicaoFim! -  ram.posicaoInicio!) >= (self.viewModel.memoria - self.viewModel.memoriaAlocada) && (ram.posicaoFim! -  ram.posicaoInicio!) > 0){
                            self.viewModel.processosEmExecucao[index] = ram
                        }else{
                            aux.posicaoInicio = ram.posicaoFim! + 1

                            if(index+1 > self.viewModel.processosEmExecucao.count){
                                self.viewModel.processosEmExecucao[index] = ram
                                self.viewModel.processosEmExecucao[index+1] = aux
                            }else{
                                self.viewModel.processosEmExecucao[index] = ram
                                self.viewModel.processosEmExecucao.append(aux)
                            }
                            
                        }

    
                    case .buraco:
                        break
                    }
                
            }
        
        self.viewModel.processosEmExecucao =  self.viewModel.processosEmExecucao.sorted { $0.posicaoInicio! < $1.posicaoInicio!}
        
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
                    self.filaEspera.enqueue(ram)
                    enqueue()
           

                }else if let process = notification.object as? Process{
                

                        var processM = process
                        
                        if processM.addTime(tempo: timer){
                        
                            processM.isFinished = true

                            self.removeProcess(processo: processM)
                            self.viewModel.memoriaAlocada = self.sumOfProcessesSizes()
                            NotificationCenter.default.post(name: self.notificationFinalizou.name, object: processM)

                            
                        }else{
                            NotificationCenter.default.post(name: self.notificationRodando.name, object: processM)
                            enqueue()
                        }
                    



                }

                
        }
    }
}
