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
        
        ram = .init(nr: nr, nf: nf, memoriaSize: 40, so: .init(tipo: .so, posicaoInicio: 0, posicaoFim: 99),alocacao: .bestFit)
        c = .init(nf: nf, ne: ne)
    }
    

    func calculateTempoMedio() -> Double{
        let soma = c.processesFinalizados.filter{ $0.isFinished}.reduce(0.0) { $0 + ($1.tempoAtual! - $1.tempoCriacao!)}
        return soma/Double(c.processesFinalizados.count)
    }
    
    

    var body: some View {
        
        VStack{
            
            
            Section{
                List{
                    ForEach(c.processesEntrou.filter{$0.tempoCriacao == nil}, id: \.id) { p in
                        
                        Text("Processo \(p.idString) -> Entrará daqui + \(p.tempoCriacaoSeconds)s")
                    }
                }
            }header: {
                Text("Esperando Executar")
            }
           

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
            
            Section{
                HStack{
                    ForEach(ram.viewModel.rams, id: \.id) { ram in
                        Card(ram: ram)
                    }
                }
            }header: {
                Text("Memoria - \(ram.memoriaAlocada)/\(ram.memoria)MB")
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
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 20, tempoCriacao: 10))
                
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 20, tempoCriacao: 10))
                
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 5, tempoCriacao: 10))
                
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 2, tempoCriacao: 10))
                c.addProcess(process: .init(duracaoProcesso: 5, tamanhoProcesso: 20, tempoCriacao: 10))
                
                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 20, tempoCriacao: 10))
                
                c.addProcess(process: .init(duracaoProcesso: 20, tamanhoProcesso: 5, tempoCriacao: 10))
                
                c.addProcess(process: .init(duracaoProcesso: 30, tamanhoProcesso: 20, tempoCriacao: 10))
            
                
            } label: {
                Text("Iniciar simulação")
            }.disabled(c.processesEntrou.count != c.processesFinalizados.count)
        }
       
//        .onReceive(ram.viewModel.rams.publisher, perform: { r in
//            print(r.posicaoInicio)
//            print(r.posicaoFim)
//            print(r.tipo)
//
//        })
        .onReceive(c.processesFinalizados.publisher, perform: { _ in
            showingAlert = c.processesEntrou.count == c.processesFinalizados.count
            self.ram.viewModel.objectWillChange.send()
            
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
