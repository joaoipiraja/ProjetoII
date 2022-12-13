//
//  ContentView.swift
//  ProjetoII
//
//  Created by João Victor Ipirajá de Alencar on 16/11/22.
//

import SwiftUI
import Combine


class Generator{
    
    
    static func initialState(sheetViewModel: SheetViewModel, ram: MemoriaRAM){
        ram.estrategiaAlocacao = sheetViewModel.alocacao
        
        ram.memoriaTotal = sheetViewModel.tamanhoMemoria
        
        ram.memoriaDisponivel = sheetViewModel.tamanhoMemoria - sheetViewModel.tamanhoMemoriaSistemaOperacional
        
        let so = MemoriaRAMModel(tipo: .so, tamanho: sheetViewModel.tamanhoMemoriaSistemaOperacional)
        
        let buraco = MemoriaRAMModel(tipo: .buraco, tamanho:  ram.memoriaTotal - sheetViewModel.tamanhoMemoriaSistemaOperacional)
        
        ram.viewModel.processosExecucao.append(so)
        ram.viewModel.processosExecucao.append(buraco)


        DispatchQueue.main.async {
            ram.objectWillChange.send()
        }
    }
    
    static func processes(sheetViewModel: SheetViewModel, controladora: Controladora){
        
        for _ in Range(0...sheetViewModel.qntdProcessos-1){
            let randomTempoCriacao = sheetViewModel.intervaloTempoCriacao.range.randomElement()!
            let randomDuracao = sheetViewModel.intervaloDuracao.range.randomElement()!
            let randomTamanho = sheetViewModel.intervaloTamanhoProcesso.range.randomElement()!
            
            controladora.addProcess(process: .init(duracaoProcesso: randomDuracao, tamanhoProcesso: randomTamanho, tempoCriacao: randomTempoCriacao))
        }
    }
    
    
    
    
    
}

struct ContentView: View {
    
        
    @ObservedObject var ram: MemoriaRAM
    @ObservedObject var controladora: Controladora
    
    @ObservedObject private var sheetViewModel: SheetViewModel = .init()
    @State private var showingSheet = false
    @State private var showingAlert = false
    
    @State private var progress: Double = 0.0
    @State private var arrayOfRam = Array<MemoriaRAMModel>()
    
    var nf: Notify = .init(name: "finalizou")
    var nr: Notify = .init(name: "rodando")
    var ne: Notify = .init(name: "esperando")

    
    init(){

        
        nf.register()
        nr.register()
        ne.register()
        
        ram = .init(nr: nr, nf: nf)
        controladora = .init(nf: nf, ne: ne)
    }
    

    func calculateTempoMedio() -> Double{
        let soma = controladora.processesFinalizados.filter{ $0.isFinished}.reduce(0.0) { $0 + ($1.tempoAtual! - $1.tempoCriacao!)}
        return soma/Double(controladora.processesFinalizados.count)
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
                    ForEach(controladora.processesEntrou.filter{$0.tempoCriacao == nil}.sorted { $0.tempoCriacaoSeconds < $1.tempoCriacaoSeconds}, id: \.id) { p in
                        
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
                    ForEach(self.ram.viewModel.processosExecucao, id: \.id) { ram in
                        Card(ram: ram)
                    }
                    .onReceive(self.ram.viewModel.processosExecucao.publisher) { _ in
                        self.ram.viewModel.processosExecucao = self.ram.viewModel.processosExecucao.reduce(into: Array<MemoriaRAMModel>()) { restante, elemento in
                            
                            if let last = restante.last{
                                
                                elemento.posicaoInicio = last.posicaoFim + 1
                                elemento.posicaoFim = elemento.posicaoInicio + elemento.tamanho!
                                
                            }else{
                                elemento.posicaoInicio = 0
                                elemento.posicaoFim =  elemento.tamanho!
                            }
                          
                            
                            restante.append(elemento)
                            
                        }
                    
                    }
                }
            }header: {
                Text("Memoria - \(ram.memoriaAlocada+self.sheetViewModel.tamanhoMemoriaSistemaOperacional)/\(ram.memoriaTotal) MB")
            }
           
             
            
            Section {
                List{

                    ForEach(controladora.processesFinalizados, id: \.id) { process in

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
            }.disabled(controladora.processesEntrou.count != controladora.processesFinalizados.count)
        }
       
       
        .onReceive(controladora.processesFinalizados.publisher, perform: { _ in
            showingAlert = controladora.processesEntrou.count == controladora.processesFinalizados.count &&
                controladora.processesEntrou.count > 0
            
            self.progress =  100.0 * Double(self.controladora.processesFinalizados.count) / Double(self.controladora.processesEntrou.count)
            DispatchQueue.main.async {
                self.ram.objectWillChange.send()
            }

            
        }).alert("TempoMedio = \(calculateTempoMedio())s", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {
                showingAlert = false
            }
        }.sheet(isPresented: $showingSheet, onDismiss: {
            
           

            DispatchQueue.main.async{
                self.ram.listenToNotications()
                self.controladora.listenToNotications()
                
                self.ram.viewModel.processosExecucao = []
                self.ram.memoriaAlocada = 0
                self.controladora.processesEntrou = []
                self.controladora.processesFinalizados = []
                self.progress = 0.0
                
                Generator.initialState(sheetViewModel: self.sheetViewModel, ram: self.ram)
                Generator.processes(sheetViewModel: self.sheetViewModel, controladora: self.controladora)

            }
           
     
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
