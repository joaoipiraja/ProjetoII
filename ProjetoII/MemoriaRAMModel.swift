//
//  MemoriaRAMModel.swift
//  ProjetoII
//
//  Created by João Victor Ipirajá de Alencar on 22/11/22.
//

import Foundation


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
    @Published var posicaoInicio:Int = 0
    @Published var posicaoFim:Int = 0
    var tipo: Tipo
    var tamanho: Int?
    
    init(tipo: Tipo, tamanho:Int? = nil){
        self.tipo = tipo
        self.tamanho = tamanho
    }
    static var MOCK = MemoriaRAMModel(tipo: .processo(processo: .init(duracaoProcesso: 10, tamanhoProcesso: 10, tempoCriacao: 10)), tamanho: 10)
    
}
