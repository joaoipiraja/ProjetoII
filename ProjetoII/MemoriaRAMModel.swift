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





class MemoriaRAMModel: ObservableObject, Identifiable{
    
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
    
    @Published var posicaoInicio:Int?
    @Published var posicaoFim:Int?
    
    var tipo: Tipo
    
    var sizeOf: Int{
        get{
            return (posicaoFim ?? 0) - (posicaoInicio ?? 0)
        }
    }
    
    init(tipo: Tipo, posicaoInicio: Int? = nil, posicaoFim: Int? = nil){
        self.tipo = tipo
        self.posicaoInicio = posicaoInicio
        self.posicaoFim = posicaoFim
    }
    
    static var MOCK = MemoriaRAMModel(tipo: .buraco, posicaoInicio: 0, posicaoFim: 1)
    
}
