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
    let name = Notification.Name("rodando")
    let nameFinalizou = Notification.Name("finalizou")

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
    
    func imprimirProcesso(){
    
        
        print("\n\nMemoria {")
        for r in rams{
            print("Posicao Inicio -> ",r.posicaoInicio)
            print("Posicao Fim -> ",r.posicaoFim)
            switch r.tipo{
                
            case .so:
                print("SO")
            case .processo(processo: let processo):
                print(processo.description)
            case .buraco:
                print("Buraco")
            }
            print("\n")
        }
        print("}\n\n")
    }

    
    func removeProcess(processo: Process){
            if let index = self.index(processo: processo){
                self.rams[index].tipo = .buraco
                self.mergeBuracos()
            }
    }
    
    
    func atualizarProcesso(processo: Process){
        
            if let index = self.index(processo: processo){
                self.rams[index].tipo = .processo(processo: processo)
            }
    }
    
    func mergeBuracos(){
        
    
       
            self.rams =  self.rams.sorted { $0.posicaoFim! < $1.posicaoFim!}
            let ram = MemoriaRAMModel(tipo: .buraco)
        
         
            
            if let index = try? self.rams.firstIndex(where: {$0.tipo == .buraco}){
                
                print(self.rams[index].posicaoInicio,self.rams[index].posicaoFim)
                ram.posicaoInicio = self.rams[index].posicaoInicio
                    
                    for i in index+1..<self.rams.count{
                        print("Prox ram ->",self.rams[i].posicaoInicio,self.rams[i].posicaoFim, self.rams[i].tipo)

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
        
            DispatchQueue.main.async {
                self.rams =  self.rams.sorted { $0.posicaoFim! < $1.posicaoFim!}
            }
                
        

       
    }
    
    func inicial(){
        let so = MemoriaRAMModel(tipo: .so, posicaoInicio: 0, posicaoFim: 99)
        let buraco = MemoriaRAMModel(tipo: .buraco, posicaoInicio: 100, posicaoFim: 140)
        
        rams.append(so)
        rams.append(buraco)

    }
    
    init(){
        DispatchQueue.main.async {
            self.inicial()
        }
        
        self.cancellable = NotificationCenter.default
            .publisher(for: name)
            .zip(timer)
            .sink { [unowned self] (notification,timer) in
                
                if let ram = notification.object as? MemoriaRAMModel{
                    addProcess(ram: ram)

                    
                    switch ram.tipo{
                            
                        case .so:
                            break
                        case .processo(processo: let processo):
                            NotificationCenter.default.post(name: self.name, object: processo)
                        case .buraco:
                            break
                    }


                }else if let process = notification.object as? Process{
                

                    var processM = process
                    
                    if processM.addTime(tempo: timer){
                        self.removeProcess(processo: process)
                        NotificationCenter.default.post(name: self.nameFinalizou, object: processM)
                    }else{
                        NotificationCenter.default.post(name: self.name, object: processM)
                    }
                    
                    self.atualizarProcesso(processo: processM)
                    self.mergeBuracos()

                }
                
        }
    }
}
