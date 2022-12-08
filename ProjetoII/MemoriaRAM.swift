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
    
    var cancellables = Set<AnyCancellable>()
    var timer = Timer.publish(every: 1, on: .current, in: .default).autoconnect()
    
    @Published var queue: Queue<MemoriaRAMModel> = .init()
    
    @ObservedObject var viewModel: ViewModel = .init()
    
    var notificationRodando: Notify
    var notificationFinalizou: Notify
    
    var estrategiaAlocacao: EstrategiaAlocacao = .firstFit
    
    var memoria: Int = 0
    var memoriaTotal: Int = 0
    @Published var memoriaAlocada = 0
    
    
    
    func sumProcessTotal() -> Int{
    
        return self.viewModel.rams.map { value in
            switch value.tipo{
                
            case .so:
                return -1
            case .processo(processo: let processo):
                return processo.tamanhoProcesso
            case .buraco:
                return -1
            }
        }.filter{$0 > 0}.reduce(0) {$0 + $1}
    }
    
    func findRole(alg: EstrategiaAlocacao, tamanho: Int) -> Int?{
          
          var distance = self.viewModel.rams.enumerated()

              .map { (index,ram) in
              switch ram.tipo{
                      
                  case .so:
                      return (index,-1)
                  case .processo(processo: _):
                      return (index,-1)
                  case .buraco:
                    return  (index,ram.tamanho!)
              }
              }.filter {$0.1 > -1}
          
          
        let max = distance.sorted(by: {$0.1 > $1.1}).filter{$0.1 >= tamanho}.first
        let min = distance.sorted(by: {$0.1 < $1.1}).filter{$0.1 >= tamanho}.first
          
          
        
          
          switch alg{
              case .bestFit:
                  return min?.0
              case .firstFit:
              return try? self.viewModel.rams.lastIndex(where: {$0.tipo == .buraco})
              case .worstFit:
                  return max?.0
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
            self.memoriaAlocada = sumProcessTotal()
        

    }
    
    
    func splitByMissingInteger(array: [(Int,Int)]) -> [[(Int,Int)]]? {
        var arrayFinal :[[(Int,Int)]] = [ [(Int,Int)]() ]
        var i = 0
        for num in array{
            if arrayFinal[i].isEmpty || (arrayFinal[i].last == nil){
                arrayFinal[i].append(num)
            } else if num.0 == (arrayFinal[i].last!.0 + 1){
                arrayFinal[i].append(num)
            } else {
                i += 1
                arrayFinal.append([(Int,Int)]())
                arrayFinal[i].append(num)
            }
        }
        return arrayFinal
    }
    
    
    func mergeBuracos(){
        
        let listOfIndexes = self.viewModel.rams.enumerated().map { (index,ram) in
            switch ram.tipo{
                
            case .so:
                return (index, -1)
            case .processo(processo: _):
                return (index, -1)
            case .buraco:
                return (index, ram.tamanho!)
            }
            
        }.filter{$0.1 > 0}
        
        if let listSplit = splitByMissingInteger(array: listOfIndexes){
            
            print("SO ->", self.memoriaTotal - self.memoria)
            let p_espera = self.queue.elements.enumerated().map{ (index,ram) in
                return (index,ram.tamanho!)
            }
            let p =  self.viewModel.rams .enumerated().filter{
                $0.1.tipo != .buraco && $0.1.tipo != .so
            }
               .map{ (index,ram) in
                return (index,ram.tamanho!)
            }
            print("Espera ->",p_espera)
            print("Processos ->",p)
            print("Buracos->", listSplit)
            
            print((self.memoriaTotal - self.memoria) +
                            p.reduce(0) {$0 + $1.1} +
                            listSplit.reduce(0) {$0 + $1.reduce(0){$0 + $1.1}}
                            )
            
            
            
                listSplit.filter{$0.count >= 2}.forEach { array in
               
                        let sum = array.map{$0.1}.reduce(0, +)
                        let falta = memoriaAlocada - sum
                        
                        let indexFirst = (array.first?.0)!
                        let indexLast = (array.last?.0)!
                        
                        var buraco = MemoriaRAMModel(tipo: .buraco, tamanho:  sum)
                    
                    
                        self.viewModel.rams[indexFirst] = buraco
                        

                        if(indexLast > indexFirst+1){
                            self.viewModel.rams.removeSubrange(indexFirst+1...indexLast)
                        }else if(indexLast == indexFirst+1){
                            self.viewModel.rams.remove(at: indexFirst+1)
                        }
                    
                          
                            
                        
                        
                    

                }
//
//            if let index = self.viewModel.rams.lastIndex(where: {$0.tipo == .buraco }){
//                self.viewModel.rams[index].tamanho = memoria - memoriaAlocada
//            }
                
            }
        
      
        
            self.viewModel.objectWillChange.send()
        
           
        
    }
    
    func sizeOfNextOnQueue() -> Int{
        return (self.queue.elements.map({ r in
            switch r.tipo{
        
                case .processo(processo: let p):
                    return p.tamanhoProcesso
                default:
                    return 0
            }
        }).first ?? 0)
    }
    
    func enqueue(){
  
        if(sumProcessTotal() + sizeOfNextOnQueue() <= self.memoria){
                        //executa o algoritmo
                        if let fila = self.queue.dequeue(){
                            
                            
                            switch fila.tipo{
                    
                            case .processo(processo: let p):

                                NotificationCenter.default.post(name: self.notificationRodando.name, object: p)
                                addProcess(ram: fila)
                                self.memoriaAlocada = sumProcessTotal()

                            default:
                                break
                            }
                        }
                }
        
       // self.viewModel.objectWillChange.send()

    }
    
    func nextWillFinish() -> Int{
      
        var array: Array<MemoriaRAMModel> = self.viewModel.rams
        
       if let arrayListed = array.map{ value in
            switch value.tipo{
            case .processo(processo: let p):
                if let tempoAtual = p.tempoAtual{
                    return (p.tamanhoProcesso, p.tempoFinal! - tempoAtual)
                }else{
                    return (p.tamanhoProcesso, 0)
                }
               
            default:
                return (0,0)
            }
        }.filter{$0.1 > 0.0}.sorted(by: {$0.0 < $1.0}).first{
            return arrayListed.0
        }else{
            return 0

        }
       
    }
    
    func addProcess(ram: MemoriaRAMModel){
        
        
                
        if let index = findRole(alg:  self.estrategiaAlocacao, tamanho: ram.tamanho ?? 0){
                
                
                switch ram.tipo{
                    
               
                    case .processo(processo: let processo):
                    
                        //Se basea no tamanaho e particiona
                        //Particiona
                    
                        var aux = self.viewModel.rams[index]
                        aux.tamanho = (aux.tamanho!) - processo.tamanhoProcesso
                      
                    
                    
                    print(aux.tamanho!)
                    if(aux.tamanho! > 0){
                            
                            if(index+1 > self.viewModel.rams.count){
                                self.viewModel.rams[index] = ram
                                self.viewModel.rams[index+1] = aux
                            }else{
                                self.viewModel.rams[index] = ram
                                self.viewModel.rams.append(aux)
                            }
                            
                        } else if(aux.tamanho! < 0) {
                                self.viewModel.rams[index] = ram

                        }

                        default:
                            break
                    }
                
            }
        
       
        
        self.viewModel.objectWillChange.send()

        

       
    }
    
    
    func listenToNotications(){
        
        self.cancellables.removeAll()
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
                        NotificationCenter.default.post(name: self.notificationFinalizou.name, object: processM)
                    }else{
                        NotificationCenter.default.post(name: self.notificationRodando.name, object: processM)
                    }
                    //enqueue()
                    
                    
                }
                enqueue()
                
                self.mergeBuracos()
                if let index = self.viewModel.rams.lastIndex(where: {$0.tipo == .buraco}){
                    let buracoSoma = self.viewModel.rams.filter{$0.tipo == .buraco}.reduce(0) {$0 + $1.tamanho!}
                    
                    let buracoTamanhoAtual = self.viewModel.rams[index].tamanho!
                    
                    
                    let dif = memoria - sumProcessTotal()
                    if(dif != 0){
                        self.viewModel.rams[index].tamanho =  dif - (buracoSoma - buracoTamanhoAtual)
                    }else{
                        self.viewModel.rams.remove(at: index)
                    }
                }

            }.store(in: &cancellables)
    }
    
    init( nr: Notify, nf: Notify){
        
        self.notificationRodando = nr
        self.notificationFinalizou = nf
        
        listenToNotications()
       

     
    }
    
}
