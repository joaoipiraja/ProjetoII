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
        let soma = c.processes_finalizados.filter{ $0.isFinished}.reduce(0.0) { $0 + ($1.tempoAtual! - $1.tempoCriacao)}
        return soma/Double(c.processes_finalizados.count)
    }

    var body: some View {
        
        VStack{
            
           
            
            HStack{
                ForEach(self.ram.rams, id: \.id) { r in
                    Card(ram: r)
                }
                
            }
             
            
            Section {
                List{
                    
                    ForEach(ram.queue.elements, id: \.id) { r in
                        switch r.tipo{
                            case .so:
                                Text("")
                            case .processo(processo: let p):
                              Text("\(p.description)")
                            case .buraco:
                                Text("")
                                
                        }

                    }
                    
                }
            } header: {
                Text("Espera")
            }
            
            Section {
                List{

                    ForEach(c.processes_finalizados.filter{ $0.isFinished }, id: \.id) { process in

                        Text("\(process.description)")

                    }

                }
            } header: {
                VStack{
                    Text("Finalizados")
                    Text("Tempo Medio = \(calculateTempoMedio())")
                }
            }

            
            
            
            
            
            Button {
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 10))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 10))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 10))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 5))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 2))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 10))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 5))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 10))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 3))
             
                
            } label: {
                Text("Teste")
            }
        }
        .padding()


       

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
