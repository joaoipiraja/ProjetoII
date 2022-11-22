//
//  MemoriaRAMModel.swift
//  ProjetoII
//
//  Created by João Victor Ipirajá de Alencar on 22/11/22.
//

import Foundation


class MemoriaRAMModel{
    var posicaoInicio:Int? = nil
    var posicaoFim:Int? = nil
    var processo: Process
    
    init(processo: Process){
        self.processo = processo
    }
}
