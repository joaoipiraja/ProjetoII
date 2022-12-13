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
    @Published var processosExecucao: Array<MemoriaRAMModel> = []
    
}




class MemoriaRAM: ObservableObject{
    
    var cancellables = Set<AnyCancellable>()
    var timer = Timer.publish(every: 1, on: .current, in: .default).autoconnect()
    
    @Published var queue: Queue<MemoriaRAMModel> = .init()
    @ObservedObject var viewModel: ViewModel = .init()
    

    var estrategiaAlocacao: EstrategiaAlocacao = .firstFit
    var memoriaDisponivel: Int = 0
    var memoriaTotal: Int = 0
    @Published var memoriaAlocada = 0
    
    var notificationRodando: Notify
    var notificationFinalizou: Notify
    
    
    init( nr: Notify, nf: Notify){
        
        self.notificationRodando = nr
        self.notificationFinalizou = nf
        
        listenToNotications()
     
    }
    
    
    
    
    func sumProcessTotal() -> Int{
    
        return self.viewModel.processosExecucao.map { value in
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
    
    func getBuracosSizes() -> Array<(Int,Int)>{
        
        return self.viewModel.processosExecucao.enumerated().map { (index,ram) in
            switch ram.tipo{
                
                case .buraco:
                    return (index, ram.tamanho!)
                default:
                    return (index, -1)
            }
            
        }.filter{$0.1 > 0}
    }
    
    
    func findRole(alg: EstrategiaAlocacao, tamanho: Int) -> Int?{
          
        var distance = self.getBuracosSizes()
          
        let max = distance.sorted(by: {$0.1 > $1.1}).filter{$0.1 >= tamanho}.first
        let min = distance.sorted(by: {$0.1 < $1.1}).filter{$0.1 >= tamanho}.first
  
        switch alg{
              case .bestFit:
                  return min?.0
              case .firstFit:
              return try? self.viewModel.processosExecucao.lastIndex(where: {$0.tipo == .buraco})
              case .worstFit:
                  return max?.0
          }
      }
    
    
    func index(processo: Process) -> Int?{
        return try? self.viewModel.processosExecucao.firstIndex(where: { ram in
            
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
                self.viewModel.processosExecucao[index].tipo = .buraco

            }
            self.mergeBuracos()
            self.memoriaAlocada = sumProcessTotal()

    }
    
    // Agrupar buracos próximos
    func groupNearBuracos(array: [(Int,Int)]) -> [[(Int,Int)]]? {
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
        
        let listOfIndexes = getBuracosSizes()
        
        if let listSplit = groupNearBuracos(array: listOfIndexes){
        

                listSplit.filter{$0.count >= 2}.forEach { array in
               
                        let sum = array.map{$0.1}.reduce(0, +)
                    
                        let falta = memoriaAlocada - sum
                        
                        let indexFirst = (array.first?.0)!
                        let indexLast = (array.last?.0)!
                        
                        var buraco = MemoriaRAMModel(tipo: .buraco, tamanho:  sum)
                    
                    
                        self.viewModel.processosExecucao[indexFirst] = buraco
                        

                        if(indexLast > indexFirst+1){
                            self.viewModel.processosExecucao.removeSubrange(indexFirst+1...indexLast)
                        }else if(indexLast == indexFirst+1){
                            self.viewModel.processosExecucao.remove(at: indexFirst+1)
                        }
                    

                }

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
    
    func nextProcessToExecute(){
  
        if(sumProcessTotal() + sizeOfNextOnQueue() <= self.memoriaDisponivel){
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
        

    }
    

    
    func addProcess(ram: MemoriaRAMModel){
        
        
                
        if let index = findRole(alg:  self.estrategiaAlocacao, tamanho: ram.tamanho ?? 0){
                
                
                switch ram.tipo{
                    
               
                    case .processo(processo: let processo):
                    
                        //Se basea no tamanaho e particiona
                        //Particiona
                    
                        var aux = self.viewModel.processosExecucao[index]
                        aux.tamanho = (aux.tamanho!) - processo.tamanhoProcesso
                      
                    
                    
                    print(aux.tamanho!)
                    if(aux.tamanho! > 0){
                            
                            if(index+1 > self.viewModel.processosExecucao.count){
                                self.viewModel.processosExecucao[index] = ram
                                self.viewModel.processosExecucao[index+1] = aux
                            }else{
                                self.viewModel.processosExecucao[index] = ram
                                self.viewModel.processosExecucao.append(aux)
                            }
                            
                        } else if(aux.tamanho! < 0) {
                                self.viewModel.processosExecucao[index] = ram

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
                    
                    
                    var processModified = process
                    
                    if processModified.addTime(tempo: timer){
                        self.removeProcess(processo: process)
                        processModified.isFinished = true
                        NotificationCenter.default.post(name: self.notificationFinalizou.name, object: processModified)
                    }else{
                        NotificationCenter.default.post(name: self.notificationRodando.name, object: processModified)
                    }

                    
                }
                nextProcessToExecute()
                
                self.mergeBuracos()
                
                //Evitar dos processos extrapolarem o tamanho da memoria
                if let index = self.viewModel.processosExecucao.lastIndex(where: {$0.tipo == .buraco}){
                    let buracoSoma = self.viewModel.processosExecucao.filter{$0.tipo == .buraco}.reduce(0) {$0 + $1.tamanho!}
                    
                    let buracoTamanhoAtual = self.viewModel.processosExecucao[index].tamanho!
                    
                    
                    let dif = memoriaDisponivel - sumProcessTotal()
                    if(dif != 0){
                        self.viewModel.processosExecucao[index].tamanho =  dif - (buracoSoma - buracoTamanhoAtual)
                    }else{
                        self.viewModel.processosExecucao.remove(at: index)
                    }
                }

            }.store(in: &cancellables)
    }
    
   
    
}
