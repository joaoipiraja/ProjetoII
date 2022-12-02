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
    @State private var showingSheet = false

    
    @State private var showingAlert = false
    @State private var progress: Double = 0.0
    @ObservedObject private var sheetViewModel: SheetViewModel = .init()
    
    
    var nf: Notify = .init(name: "finalizou")
    var nr: Notify = .init(name: "rodando")
    var ne: Notify = .init(name: "esperando")
    
    
    init(){
        
        self.nf.register()
        self.nr.register()
        self.ne.register()
        
        ram = .init(nr: nr, nf: nf)
        c = .init(nf: nf, ne: ne)
    }
    
    func generateProcesses(){
        
        for _ in Range(0...self.sheetViewModel.qntdProcessos){
            let randomTempoCriacao = self.sheetViewModel.intervaloTempoCriacao.range.randomElement()!
            let randomDuracao = self.sheetViewModel.intervaloDuracao.range.randomElement()!
            let randomTamanho = self.sheetViewModel.intervaloTamanhoProcesso.range.randomElement()!
            
            c.addProcess(process: .init(duracaoProcesso: randomDuracao, tamanhoProcesso: randomTamanho, tempoCriacao: randomTempoCriacao))
            c.objectWillChange.send()
        }
    }
    
    func generateInitialState(){
        
        self.ram.viewModel.estrategiaAlocacao = self.sheetViewModel.alocacao
        
        self.ram.viewModel.memoriaTotal = self.sheetViewModel.tamanhoMemoria
        self.ram.viewModel.memoria = self.sheetViewModel.tamanhoMemoria - self.sheetViewModel.tamanhoMemoriaSistemaOperacional
        

        self.ram.viewModel.processosEmExecucao.append(.init(tipo: .so, posicaoInicio: 0, posicaoFim: self.sheetViewModel.tamanhoMemoriaSistemaOperacional))
        
        
        self.ram.viewModel.processosEmExecucao.append(.init(tipo: .buraco, posicaoInicio: self.sheetViewModel.tamanhoMemoriaSistemaOperacional+1, posicaoFim:self.ram.viewModel.memoria + 1))
        
        print(self.sheetViewModel.tamanhoMemoria)
        
        self.ram.objectWillChange.send()
    }

    var body: some View {
        
        VStack(alignment: .center){
                
                
                ProgressView(value: self.progress, total: 100,
                    label: {
                    Text("Executando -  \(self.ram.viewModel.estrategiaAlocacao.rawValue)")
                            .padding(.bottom, 4)
                    }, currentValueLabel: {
                        Text("\(Int(progress))%")
                            .padding(.top, 4)
                    }
                ).progressViewStyle(.linear).padding()
                
                Section{
                    List{
                        ForEach(c.viewModel.processesNotExec, id: \.id) { p in
                            
                            Text("Processo \(p.idString) -> Entrará daqui + \(p.tempoCriacaoSeconds)s")
                        }
                    }
                }header: {
                    Text("Esperando Executar")
                }
                
                
                Section {
                    List{
                        
                        
                        ForEach(ram.filaEspera.elements) { ram in
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
                
         
                    
                    VStack{
                        Text("Memoria - \(self.ram.viewModel.memoriaAlocada)/\( self.ram.viewModel.memoriaTotal)MB")
                        
                        HStack{
                            ForEach(ram.viewModel.processosEmExecucao, id: \.id) { ram in
                                Card(ram: ram)
                            }
                        }
                    }
              
                
            
                    VStack{
                        Text("Finalizados")
                         List{
                            
                             ForEach(c.viewModel.processesFinalizados, id: \.id) { process in
                                
                                Text("\(process.description)")
                                
                            }
                            
                        }
                    }
                
                
                
                
                
                
                
                Button {
                    
                    showingSheet = true
//                    c.processesFinalizados = []
//
//                    c.notificationFinalizou.register()
//                    c.notificationEspera.register()
//                    ram.notificationRodando.register()
//
//                    c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 20, tempoCriacao: 0))
//
//                    c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 20, tempoCriacao: 0))
//
//                    c.addProcess(process: .init(duracaoProcesso: 40, tamanhoProcesso: 5, tempoCriacao: 0))
//
//                    c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 2, tempoCriacao: 10))
//                    c.addProcess(process: .init(duracaoProcesso: 100, tamanhoProcesso: 5, tempoCriacao: 10))
//
//                    c.addProcess(process: .init(duracaoProcesso: 10, tamanhoProcesso: 20, tempoCriacao: 10))
//
//                    c.addProcess(process: .init(duracaoProcesso: 20, tamanhoProcesso: 5, tempoCriacao: 10))
//
//                    c.addProcess(process: .init(duracaoProcesso: 30, tamanhoProcesso: 20, tempoCriacao: 10))
//
                    
                } label: {
                    Text("Abrir Configurações")
                }.disabled(c.viewModel.processesEntrou.count != c.viewModel.processesFinalizados.count)
            }
            
            //        .onReceive(ram.viewModel.rams.publisher, perform: { r in
            //            print(r.posicaoInicio)
            //            print(r.posicaoFim)
            //            print(r.tipo)
            //
            //        })
        .onReceive(c.viewModel.processesFinalizados.publisher, perform: { _ in
            
                showingAlert = c.viewModel.isFinished
                        
            self.progress =  100.0 * Double(self.c.viewModel.processesFinalizados.count) / Double(self.c.viewModel.processesEntrou.count)
                
            }).alert("TempoMedio = \(c.viewModel.calculateTempoMedio())s", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {
                    showingAlert = false
                }
            }.sheet(isPresented: $showingSheet, onDismiss: {
                c.viewModel.processesFinalizados = []
                generateInitialState()
                generateProcesses()
                
            }) {
                Sheet(viewModel: sheetViewModel)
            }
        
            .padding()
            
            
            
        
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
