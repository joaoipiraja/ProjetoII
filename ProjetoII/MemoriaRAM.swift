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
    
    func imprimirProcesso(){
    
        
        print("\n\nMemoria {")
        for r in rams{
            print(r.posicaoInicio)
            print(r.posicaoFim)
            print(r.processo.description)
            print("\n")
        }
        print("}\n\n")
    }

    
    func removeProcess(processo: Process){
        DispatchQueue.main.async {
            self.rams.removeAll(where: { $0.processo.id == processo.id})
        }
        
    }
    
    
    func atualizarProcesso(processo: Process){
        
        DispatchQueue.main.async {
            if let index = try? self.rams.firstIndex(where: {$0.processo.id == processo.id}) {
                self.rams[index].processo = processo
            }
        }
    }
    
    init(){
        self.cancellable = NotificationCenter.default
            .publisher(for: name)
            .zip(timer)
            .sink { [unowned self] (notification,timer) in
                
                if let ram = notification.object as? MemoriaRAMModel{
                    
                    DispatchQueue.main.async {
                        self.rams.append(ram)
                    }
                    
                   // alocaProcesso(ram: ram)
                    NotificationCenter.default.post(name: self.name, object: ram.processo)

                }else if let process = notification.object as? Process{
                                    
                    var processM = process
                    
                    if processM.addTime(tempo: timer){
                        self.removeProcess(processo: process)
                        NotificationCenter.default.post(name: self.nameFinalizou, object: processM)
                    }else{
                        NotificationCenter.default.post(name: self.name, object: processM)
                    }
                    
                    atualizarProcesso(processo: processM)
                    
                }
                
        }
    }
}
