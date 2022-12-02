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
        
        let index_lista = self.viewModel.processosEmExecucao.enumerated().map { (index,rams) in
            if(rams.tipo == .buraco){
                return index
            }else{
                return -1
            }
        }.filter{$0 > 0}
        
        let reducedInto = index_lista.reduce(into: [[Int]]()) { (result, next) in
            //Retrieve the last sequence, check if the current - last item of sequence is 1
            if var lastSequence = result.last, let last = lastSequence.last, next-last == 1 {
                lastSequence.append(next)
                result[result.endIndex-1] = lastSequence
            } else { //It's not => New array of its own
                result.append([next])
            }
        }
        
        print(reducedInto)
        
        for interval in reducedInto{
            print(interval)
            if(interval.count > 2){
                print("interval.count > 2")
                let indexFirst = interval.first!
                let indexLast = interval.last!
                let ram = MemoriaRAMModel(tipo: .buraco,
                                          posicaoInicio: self.viewModel.processosEmExecucao[indexFirst].posicaoInicio ,
                                          posicaoFim: self.viewModel.processosEmExecucao[indexLast].posicaoFim! - (indexLast - indexFirst))
                if(indexLast > indexFirst){
                    self.viewModel.processosEmExecucao[indexFirst] = ram
                    self.viewModel.processosEmExecucao.removeSubrange(indexFirst+1...indexLast)
                }
            }
        }
        
    

        
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
  
        if(self.viewModel.memoriaAlocada + sizeOfCurrentProcess() < (self.viewModel.memoria)){
                        //executa o algoritmo
                        if let fila = self.filaEspera.dequeue(){
                            
                            
                            switch fila.tipo{
                                
                            case .so:
                                break
                            case .processo(processo: let p):

                                NotificationCenter.default.post(name: self.notificationRodando.name, object: p)
                                    addProcess(ram: fila)
                                    self.viewModel.memoriaAlocada = sumOfProcessesSizes()
                            case .buraco:
                                break
                            }
                        }
                }
        

    }
    
    func addProcess(ram: MemoriaRAMModel){
        

                
        if let index = findRole(alg:  self.viewModel.estrategiaAlocacao){
                
                
                switch ram.tipo{
                    
                    case .so:
                        break
                    case .processo(processo: let processo):
                    
                    
      
                    
                        var aux = self.viewModel.processosEmExecucao[index]
                    
                
                        ram.posicaoInicio = aux.posicaoInicio //100
                        ram.posicaoFim =  aux.posicaoInicio! + processo.tamanhoProcesso //101
                    
                        aux.posicaoInicio = ram.posicaoFim! + 1 //102
                        aux.posicaoFim =  aux.posicaoFim! + 1
                        
                    
                    if(aux.posicaoFim! > aux.posicaoInicio!){
                        
                        
                        if(index+1 > self.viewModel.processosEmExecucao.count){
                            self.viewModel.processosEmExecucao[index] = ram
                            self.viewModel.processosEmExecucao[index+1] = aux
                        }else{
                            self.viewModel.processosEmExecucao[index] = ram
                            self.viewModel.processosEmExecucao.append(aux)
                        }
                        
                        
                        
//                        let newInterval = self.viewModel.processosEmExecucao.enumerated().filter({ (i, _) in
//                            return i > index + 1
//                        }).reduce(Array<MemoriaRAMModel>()) { (partialResult, trupla) in
//
//                            var partialResultVar = partialResult
//                            let aux_map =  self.viewModel.processosEmExecucao[trupla.offset]
//
//                            aux_map.posicaoInicio! = self.viewModel.processosEmExecucao[trupla.offset-1].posicaoFim! + 1
//
//                            aux_map.posicaoFim! += 1
//
//                            if(aux_map.posicaoFim! > aux_map.posicaoInicio!){
//                                partialResultVar.append(aux_map)
//                            }
//
//                            return partialResultVar
//
//                        }
//
//                        if !newInterval.isEmpty{
//
//                            self.viewModel.processosEmExecucao.removeSubrange(index+1...self.viewModel.processosEmExecucao.count-1)
//                            self.viewModel.processosEmExecucao += newInterval
//
//                        }
                        
                    }else{
                        self.viewModel.processosEmExecucao[index] = ram
                    }

    
                    case .buraco:
                        break
                    }
                
            }
        

        

       
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
