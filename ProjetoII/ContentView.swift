//
//  ContentView.swift
//  ProjetoII
//
//  Created by João Victor Ipirajá de Alencar on 16/11/22.
//

import SwiftUI
import Combine




struct ContentView: View {
        
    @ObservedObject var ram = MemoriaRAM()
    @ObservedObject var c = Controladora()

    func calculateTempoMedio() -> Double{
        let soma = c.processes.filter{ $0.isFinished}.reduce(0.0) { $0 + ($1.tempoAtual! - $1.tempoCriacao)}
        return soma/Double(c.processes.count)
    }

    var body: some View {
        
        VStack{
            
//            
//            Section {
//                List{
//                    
//                    ForEach(c.processes.filter{ !$0.isFinished }, id: \.id) { process in
//                        
//                        Text("\(process.description)")
//
//                    }
//                    
//                }
//            } header: {
//                Text("Espera")
//            }
            
            Section {
                List{
                 
                    ForEach(ram.rams, id: \.id) { ram in
                        
                        switch ram.tipo{
                            case .so:
                            VStack{
                                Text("\(ram.posicaoInicio ?? -1)")
                                Text("\(ram.posicaoFim ?? -1)")
                                Text("S.O")
                            }
                            case .processo(processo: let p):
                                VStack{
                                    Text("\(ram.posicaoInicio ?? -1)")
                                    Text("\(ram.posicaoFim ?? -1)")
                                    Text("\(p.description)")
                                }
                                
                            case .buraco:
                                VStack{
                                    Text("\(ram.posicaoInicio ?? -1)")
                                    Text("\(ram.posicaoFim ?? -1)")
                                    Text("Buraco")
                                }

                        }
                    }
                    
                }
            } header: {
                Text("Memoria RAM - \(c.memoria)")
            }
            
//            Section {
//                List{
//                    
//                    ForEach(c.processes.filter{ $0.isFinished }, id: \.id) { process in
//                        
//                        Text("\(process.description)")
//
//                    }
//                    
//                }
//            } header: {
//                VStack{
//                    Text("Finalizados")
//                    Text("Tempo Medio = \(calculateTempoMedio())")
//                }
//            }

            
            
            
            
            
            Button {
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 5))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 2))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 3))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 5))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 2))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 10))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 5))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 2))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 3))
             
                
            } label: {
                Text("Teste")
            }
        }

       

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
