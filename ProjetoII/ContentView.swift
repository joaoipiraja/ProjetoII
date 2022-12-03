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
    
    @ObservedObject private var sheetViewModel: SheetViewModel = .init()
    @State private var showingSheet = false
    @State private var showingAlert = false
    
    @State private var progress: Double = 0.0

    
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
        let soma = c.processesFinalizados.filter{ $0.isFinished}.reduce(0.0) { $0 + ($1.tempoAtual! - $1.tempoCriacao!)}
        return soma/Double(c.processesFinalizados.count)
    }
    
    func generateProcesses(){
        
        for _ in Range(0...self.sheetViewModel.qntdProcessos){
            let randomTempoCriacao = self.sheetViewModel.intervaloTempoCriacao.range.randomElement()!
            let randomDuracao = self.sheetViewModel.intervaloDuracao.range.randomElement()!
            let randomTamanho = self.sheetViewModel.intervaloTamanhoProcesso.range.randomElement()!
            
            c.addProcess(process: .init(duracaoProcesso: randomDuracao, tamanhoProcesso: randomTamanho, tempoCriacao: randomTempoCriacao))
        }
    }
    
    func generateInitialState(){
        
        self.ram.estrategiaAlocacao = self.sheetViewModel.alocacao
        
        self.ram.memoriaTotal = self.sheetViewModel.tamanhoMemoria
        
        self.ram.memoria = self.sheetViewModel.tamanhoMemoria - self.sheetViewModel.tamanhoMemoriaSistemaOperacional
        
        let so = MemoriaRAMModel(tipo: .so, posicaoInicio: 0, posicaoFim: self.sheetViewModel.tamanhoMemoriaSistemaOperacional)
        
        let buraco = MemoriaRAMModel(tipo: .buraco, posicaoInicio: so.posicaoFim! + 1, posicaoFim: (so.posicaoFim! + 1) + (self.ram.memoriaTotal - self.sheetViewModel.tamanhoMemoriaSistemaOperacional) )
        
        self.ram.viewModel.rams.append(so)
        self.ram.viewModel.rams.append(buraco)

        
        print(self.sheetViewModel.tamanhoMemoria)
        

        DispatchQueue.main.async {
            self.ram.objectWillChange.send()
        }
        
    }
    
    

    var body: some View {
        
        VStack{
            
            
            ProgressView(value: self.progress, total: 100,
                               label: {
                Text("Executando -  \(self.ram.estrategiaAlocacao.rawValue)")
                                       .padding(.bottom, 4)
                               }, currentValueLabel: {
                                   Text("\(Int(progress))%")
                                       .padding(.top, 4)
                               }
                           ).progressViewStyle(.linear).padding()
                           
            
            
            Section{
                List{
                    ForEach(c.processesEntrou.filter{$0.tempoCriacao == nil}.sorted { $0.tempoCriacaoSeconds < $1.tempoCriacaoSeconds}, id: \.id) { p in
                        
                        Text("Processo \(p.idString) -> Daqui \(p.tempoCriacaoSeconds)s")
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
                Text("Memoria - \(ram.memoriaAlocada)/\(ram.memoria) MB")
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
                showingSheet = true

//                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 20, tempoCriacao: 5))
//
//                c.addProcess(process: .init(duracaoProcesso: 100, tamanhoProcesso: 40, tempoCriacao: 10))
//
//                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 5, tempoCriacao: 10))
//
//                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 2, tempoCriacao: 15))
//                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 20, tempoCriacao: 5))
//
//                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 20, tempoCriacao: 20))
//
//                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 5, tempoCriacao: 25))
//
//                c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 2, tempoCriacao: 30))
//
                
            } label: {
                Text("Iniciar simulação")
            }.disabled(c.processesEntrou.count != c.processesFinalizados.count)
        }
       
       
        .onReceive(c.processesFinalizados.publisher, perform: { _ in
            showingAlert = c.processesEntrou.count == c.processesFinalizados.count
            self.progress =  100.0 * Double(self.c.processesFinalizados.count) / Double(self.c.processesEntrou.count)

            
        }).alert("TempoMedio = \(calculateTempoMedio())s", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {
                showingAlert = false
            }
        }.sheet(isPresented: $showingSheet, onDismiss: {
            c.processesFinalizados = []
            generateInitialState()
            generateProcesses()
            
        }) {
            Sheet(viewModel: sheetViewModel)
        }
        .padding()

       

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
