//
//  MemoriaRAM.swift
//  ProjetoII
//
//  Created by João Victor Ipirajá de Alencar on 22/11/22.
//

import Foundation
import Combine


class MemoriaRAM: ObservableObject{
    
    var cancellable: Cancellable?
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

   @Published var rams = Array<MemoriaRAMModel>()
    
    
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
    
    func addProcess(ram: MemoriaRAMModel){
        
        
            
            if let index = try? self.rams.firstIndex(where: {$0.tipo == .buraco}){
                
                
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
                            
                            if(aux.posicaoInicio == aux.posicaoFim){
                                    self.rams[index] = ram
                                
                            }else{
                                    self.rams[index] = ram
                                    self.rams[index+1] = aux
                                
                            }


                            
                        }else{
                            let aux = self.rams[index]
                            aux.posicaoInicio = ram.posicaoFim! + 1
                            aux.posicaoFim = self.rams[index].posicaoFim
                            
                            if(aux.posicaoInicio == aux.posicaoFim){
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
    
    init(){
        self.inicial()
        
        
        self.cancellable =
            Notify.Tipo.Rodando.It
            .zip(timer)
            .sink { [unowned self] (notification,timer) in
                
                if let ram = notification.object as? MemoriaRAMModel{
                    addProcess(ram: ram)

                    
                    switch ram.tipo{
                            
                        case .so:
                            break
                        case .processo(processo: let processo):
                        NotificationCenter.default.post(name: Notify.Tipo.Rodando.Name, object: processo)
                        case .buraco:
                            break
                    }


                }else if let process = notification.object as? Process{
                

                    var processM = process
                    
                    if processM.addTime(tempo: timer){
                        self.removeProcess(processo: process)
                        processM.isFinished = true
                        NotificationCenter.default.post(name: Notify.Tipo.Finalizou.Name, object: processM)
                    }else{
                        NotificationCenter.default.post(name: Notify.Tipo.Rodando.Name, object: processM)
                    }
                    

                }
                
        }
    }
}
