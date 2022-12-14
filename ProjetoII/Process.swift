//
//  Process.swift
//  ProjetoII
//
//  Created by João Victor Ipirajá de Alencar on 22/11/22.
//

import Foundation



class Process: ObservableObject{
   

    let id = UUID()
    var idString: String {
        get{
            return "\(id.uuidString.prefix(5))"
        }
    }
    
    let duracaoProcesso: Int
    let tamanhoProcesso: Int
    
    @Published var tempoCriacao = Date()
    @Published var tempoInicio: Date? = nil
    private var tempoFinal: Date? = nil
    @Published var tempoAtual: Date? = nil
    
    
    
    public var description: String { return
        "Process(\(idString)): \n DuracaoProcesso = \(duracaoProcesso);\n tamanhoProcesso = \(tamanhoProcesso); tempoCriacao = \(tempoCriacao); tempoInicio = \(tempoInicio); tempoAtual = \(tempoAtual)} "
    }
    
    @Published var isFinished: Bool = false
    
    init(duracaoProcesso: Int, tamanhoProcesso: Int) {
        self.duracaoProcesso = duracaoProcesso
        self.tamanhoProcesso = tamanhoProcesso
    }
    
    func addTime(tempo: Date) -> Bool{
        
            
        if let tempoInicio = tempoInicio{
    
            self.tempoAtual = tempo

                        
            if (tempoAtual! >= tempoFinal!) {
                tempoAtual = tempoFinal
                return true
            }

        
        }else{
            tempoInicio = tempo
            tempoFinal = tempo.adding(seconds: duracaoProcesso)
        }
        
        return false

            
    }
}
