//
//  MemoriaRAMModel.swift
//  ProjetoII
//
//  Created by João Victor Ipirajá de Alencar on 22/11/22.
//

import Foundation
// 1000 MB
//0 - 999
// 0 - 99 - S0
// 100-

// Processo + Buraco
// Divide o p





class MemoriaRAMModel{
    
    enum Tipo: Equatable{
        
        static func == (lhs: Tipo, rhs: Tipo) -> Bool {
            switch (lhs, rhs) {
            case (.so, .so),(.processo(processo: _), .processo(processo: _)), (.buraco, .buraco): return true
            default: return false
            }
        }

        case so
        case processo(processo: Process)
        case buraco
        
        
    }
    
    let id = UUID()
    var posicaoInicio:Int?
    var posicaoFim:Int?
    var tipo: Tipo
    
    init(tipo: Tipo, posicaoInicio: Int? = nil, posicaoFim: Int? = nil){
        self.tipo = tipo
        self.posicaoInicio = posicaoInicio
        self.posicaoFim = posicaoFim
    }
    static var MOCK = MemoriaRAMModel(tipo: .buraco, posicaoInicio: 0, posicaoFim: 1)
    
}
