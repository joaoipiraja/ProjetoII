//
//  ContentView.swift
//  ProjetoII
//
//  Created by João Victor Ipirajá de Alencar on 16/11/22.
//

import SwiftUI
import Combine




struct ContentView: View {
    
        
    @ObservedObject var ram: MemoriaRAM
    @ObservedObject var c: Controladora
    
    @State private var showingAlert = false
    
    var nf: Notify = .init(name: "finalizou")
    var nr: Notify = .init(name: "rodando")
    var ne: Notify = .init(name: "esperando")

    
    init(){

        
        nf.register()
        nr.register()
        ne.register()
        


        ram = .init(nr: nr, nf: nf)
        c = .init(nf: nf, ne: ne)
    }
    

    func calculateTempoMedio() -> Double{
        let soma = c.processesFinalizados.filter{ $0.isFinished}.reduce(0.0) { $0 + ($1.tempoAtual! - $1.tempoCriacao)}
        return soma/Double(c.processesFinalizados.count)
    }
    
    

    var body: some View {
        
        VStack{
            
            
            
           

            Section {
                List{
                

                    ForEach(ram.queue.elements) { ram in
                        switch ram.tipo{
                            case .buraco:
                                Text("")
                            case .processo(processo: let p):
                                Text("\(p.description)")
                            case .so:
                                Text("")
                        }
                    
                    }

                }
            } header: {
                Text("Espera")
            }
            
            HStack{
                ForEach(ram.rams, id: \.id) { ram in
                    Card(ram: ram)
                }
            }
             
            
            Section {
                List{

                    ForEach(c.processesFinalizados, id: \.id) { process in

                        Text("\(process.description)")

                    }

                }
            } header: {
                VStack{
                    Text("Finalizados")
                }
            }

            
            
            
            
            
            Button {
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 20))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 20))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 5))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso:  30))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 2))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 7))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 5))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 10))
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 3))
             
                
            } label: {
                Text("Teste")
            }
        }
       
        .onReceive(c.processesFinalizados.publisher, perform: { _ in
            showingAlert = c.processesEntrou.count == c.processesFinalizados.count
            
        }).alert("TempoMedio = \(calculateTempoMedio())s", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {
                showingAlert = false
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
