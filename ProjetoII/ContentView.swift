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
            
            
            Section {
                List{
                    
                    ForEach(c.processes.filter{ !$0.isFinished }, id: \.id) { process in
                        
                        Text("\(process.description)")

                    }
                    
                }
            } header: {
                Text("Espera")
            }
            
            Section {
                List{
                    
                    ForEach(ram.rams, id: \.processo.id) { ram in
                        
                        Text("\(ram.processo.description)")

                    }
                    
                }
            } header: {
                Text("Memoria RAM - \(c.memoria)")
            }
            
            Section {
                List{
                    
                    ForEach(c.processes.filter{ $0.isFinished }, id: \.id) { process in
                        
                        Text("\(process.description)")

                    }
                    
                }
            } header: {
                VStack{
                    Text("Finalizados")
                    Text("\(calculateTempoMedio())")
                }
            }

            
            
            
            
            
            Button {
                c.addProcess()
                c.addProcess()
                c.addProcess()
                c.addProcess()
                c.addProcess()
                c.addProcess()
                c.addProcess()
                c.addProcess()
                c.addProcess()
             
                
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
