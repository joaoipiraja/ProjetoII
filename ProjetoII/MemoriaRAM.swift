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
    
    
    func findRole(alg: EstrategiaAlocacao, tamanho: Int) -> Int?{
          
          var distance = self.viewModel.rams.enumerated()

              .map { (index,ram) in
              switch ram.tipo{
                      
                  case .so:
                      return (index,0)
                  case .processo(processo: _):
                      return (index,0)
                  case .buraco:
                    return  (index,ram.tamanho!)
              }
              }.filter {$0.1 > 0}
          
          
        let max = distance.sorted(by: {$0.1 > $1.1}).filter{$0.1 >= tamanho}.first
        let min = distance.sorted(by: {$0.1 < $1.1}).filter{$0.1 >= tamanho}.first
          
          
        
          
          switch alg{
              case .bestFit:
                  return min?.0
              case .firstFit:
                  return try? self.viewModel.rams.firstIndex(where: {$0.tipo == .buraco})
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
                print(listSplit)
                listSplit.filter{$0.count >= 2}.forEach { array in
               
                        let sum = array.map{$0.1}.reduce(0, +)

                        let indexFirst = (array.first?.0)!
                        let indexLast = (array.last?.0)!
                    
                        let inicial = self.viewModel.rams[indexFirst]
                        let buraco = MemoriaRAMModel(tipo: .buraco, tamanho: sum )
                        
                        self.viewModel.rams[indexFirst] = buraco
                        self.viewModel.rams.removeSubrange(indexFirst+1...indexLast)
                        
                    
         
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
        
       // self.viewModel.objectWillChange.send()

    }
    
    func addProcess(ram: MemoriaRAMModel){
        
        
                
        if let index = findRole(alg:  self.estrategiaAlocacao, tamanho: ram.tamanho ?? 0){
                
                
                switch ram.tipo{
                    
                    case .so:
                        break
                    case .processo(processo: let processo):
                    
                        //Se basea no tamanaho e particiona
                        //Particiona
                    
                        var aux = self.viewModel.rams[index]
                        aux.tamanho = (aux.tamanho ?? 0) - processo.tamanhoProcesso
                        
                    
                        if(aux.tamanho! > 0){
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
            }.store(in: &cancellables)
    }
    
    init( nr: Notify, nf: Notify){
        
        self.notificationRodando = nr
        self.notificationFinalizou = nf
        
        listenToNotications()
       

     
    }
    
}
