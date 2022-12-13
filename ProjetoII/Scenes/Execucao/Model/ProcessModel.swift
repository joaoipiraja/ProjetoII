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
    
   var tempoCriacaoSeconds: Int
   @Published var tempoCriacao: Date? = nil
   @Published var tempoInicio: Date? = nil
    var tempoFinal: Date? = nil
   @Published var tempoAtual: Date? = nil
    
    var progress: Double{
        get{
            if let tempoAtual = self.tempoAtual{
                if let tempoFinal = self.tempoFinal{
                   return 1.0 - (tempoFinal - tempoAtual)
                }
            }
            return 0
            
        }
    }
    
    var tempoRestante: Double{
        get{
            if let tempoAtual = self.tempoAtual{
                if let tempoFinal = self.tempoFinal{
                   return (tempoFinal - tempoAtual)
                }
            }
            return 0
        }
    }
    
    public var description: String {
            return
            "Process(\(idString)): \n DuracaoProcesso = \(duracaoProcesso);\n tamanhoProcesso = \(tamanhoProcesso); tempoCriacao = \(tempoCriacao?.toHourFormat() ?? "-"); tempoInicio = \(tempoInicio?.toHourFormat() ?? "-"); tempoAtual = \(tempoAtual?.toHourFormat() ?? "-")} "
    
    
    }
    
    @Published var isFinished: Bool = false
    
    init(duracaoProcesso: Int, tamanhoProcesso: Int, tempoCriacao: Int) {
        self.duracaoProcesso = duracaoProcesso
        self.tamanhoProcesso = tamanhoProcesso
        self.tempoCriacaoSeconds = tempoCriacao
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
