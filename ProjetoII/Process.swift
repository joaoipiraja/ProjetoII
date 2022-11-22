//
//  Process.swift
//  ProjetoII
//
//  Created by João Victor Ipirajá de Alencar on 22/11/22.
//

import Foundation



class Process: Equatable{
    
    static func == (lhs: Process, rhs: Process) -> Bool {
        return lhs.id == rhs.id
    }
    

    let id = UUID()
    var idString: String {
        get{
            return "\(id.uuidString.prefix(5))"
        }
    }
    
    let duracaoProcesso: Int
    let tamanhoProcesso: Int
    
    var tempoCriacao = Date()
    var tempoInicio: Date? = nil
    var tempoAtual: Date? = nil
    
    
    public var description: String { return
        "Process(\(idString)): {duracaoProcesso = \(duracaoProcesso);\n tamanhoProcesso = \(tamanhoProcesso); tempoCriacao = \(tempoCriacao); tempoInicio = \(tempoInicio); tempoAtual = \(tempoAtual)}"
    }
    
    var isFinished: Bool{
        return tempoInicio != nil && tempoAtual != nil
    }
    
    init(duracaoProcesso: Int, tamanhoProcesso: Int) {
        self.duracaoProcesso = duracaoProcesso
        self.tamanhoProcesso = tamanhoProcesso
    }
    
    func addTime(tempo: Date) -> Bool{
        
            
        if let tempoInicio = tempoInicio{
    
            self.tempoAtual = tempo
            
            let interval = (self.tempoAtual! - tempoInicio)
                        
            if (interval.seconds  >= duracaoProcesso - 1 ) {
                return true
            }

        
        }else{
            tempoInicio = tempo
        }
        
        return false

            
    }
}
