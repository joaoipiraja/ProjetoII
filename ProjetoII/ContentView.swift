//
//  ContentView.swift
//  ProjetoII
//
//  Created by João Victor Ipirajá de Alencar on 16/11/22.
//

import SwiftUI
import Combine

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
    func toHourFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let newDateString = dateFormatter.string(from: self)
        
        return newDateString
    }
}

extension TimeInterval {
    var seconds: Int {
        return Int(self) % 60
    }
}



class Process: Equatable{
    
    static func == (lhs: Process, rhs: Process) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    enum Estado{
        
       case emEspera
       case rodando
       case finalizado(tempoMedio: Double, memoriaDesalocar: Int)
        
        
        func toString() -> String{
            switch self{
                
            case .emEspera:
                return "Em Espera"
            case .rodando:
                return "Rodando"
            case .finalizado(tempoMedio: let tempoMedio, memoriaDesalocar: let memoriaDesalocar):
                return "Finalizado(tempoMedio = \(tempoMedio); memoriaDesalocar = \(memoriaDesalocar)"
            }
        }
   }
        
    let id = UUID()
    var idString: String {
        get{
            return "\(id.uuidString.prefix(5))"
        }
    }
    
    let duracaoProcesso: Int
    let tamanhoProcesso: Int
    
    var tempoCriacao = Date()
    var tempoInicio: Date? = nil
    var tempoAtual: Date? = nil
    
    var estado: Estado = .emEspera
    
    init(duracaoProcesso: Int, tamanhoProcesso: Int) {
        self.duracaoProcesso = duracaoProcesso
        self.tamanhoProcesso = tamanhoProcesso
    }
    
    func addTime(tempo: Date){
        
            
        if let tempoInicio = tempoInicio{
    
            self.tempoAtual = tempo
            
            let interval = (tempoAtual! - tempoInicio)
            if (interval.seconds >= duracaoProcesso) {
                estado = .finalizado(tempoMedio:
                                        tempoAtual! - tempoCriacao, memoriaDesalocar: tamanhoProcesso)
            }
        }else{
            tempoInicio = tempo
        }
            
    }
}


class ViewModel: ObservableObject{
    
    let memoriaTamanho:Int = 10
    var memoriaOcupada:Int = 0
    
    let calendar = Calendar.current

    let processEntered = PassthroughSubject<Process,Never>()
    private var process: AnyPublisher<Process, Never> //read only
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var cancellables = Set<AnyCancellable>()
    
    @Published  var processes = [Process]()

    
    init(){
                
        process = processEntered.eraseToAnyPublisher()
            
        process
        .zip(timer)
        .receive(on: DispatchQueue.global())
        .map({ [unowned self] (process, timer) in
            var processM = process
            
            print(self.memoriaTamanho,self.memoriaOcupada)

            
            switch processM.estado{
                
            case .emEspera:
                
                if(self.memoriaOcupada + process.tamanhoProcesso <= self.memoriaTamanho){
                      self.memoriaOcupada += process.tamanhoProcesso
                    processM.estado = .rodando
                }
                

            case .rodando:
                
                processM.addTime(tempo: timer)
                
            case .finalizado(tempoMedio: _, memoriaDesalocar: _):
                print("Finalizou")
               
            }
            return processM
        })
        .sink(receiveValue: {  [unowned self] process in
            
           
                  
            
            switch process.estado{
                
            case .emEspera:
                print("emEspera ->", process.idString)
                print(process.tempoInicio)
                print(process.tempoAtual)

                self.processEntered.send(process)
            case .rodando:
                print("rodando ->", process.idString)
                print(process.tempoInicio)
                print(process.tempoAtual)
                self.processEntered.send(process)
         
               
                //self.processEntered.send(completion: .finished)
            case .finalizado(tempoMedio: let tempoMedio, memoriaDesalocar: let memoriaDesalocar):
                
                self.memoriaOcupada -= memoriaDesalocar
                
                print("finalizado ->", process.idString, tempoMedio)
                print(process.tempoInicio)
                print(process.tempoAtual)
            }
            
            DispatchQueue.main.async {
                if let index = processes.index(of: process){
                    self.processes[index] = process

                }else{
                    self.processes.append(process)
                }
            }
         
           
        })
        .store(in: &cancellables)
    }
}

struct ContentView: View {
    
    @ObservedObject var viewModel = ViewModel()
    let process =  PassthroughSubject<Process,Never>()
 

    var body: some View {
        
        VStack{
            

            
            List{
                
                ForEach(viewModel.processes, id: \.id) { process in
                    
                    Section(content: {
                        Text("\(process.estado.toString())")
                        Text("Tempo de criacao = \(process.tempoCriacao.toHourFormat())")
                        Text("Tempo de inicio = \(process.tempoInicio?.toHourFormat() ?? "-")")
                        Text("Tempo de atual = \(process.tempoAtual?.toHourFormat() ?? "-")")
                    }, header: {
                        Text("Processo id(\(process.idString))")
                    })
                   
//                    Text(process.tempoCriacao)
//                    Text(process.tempoInicio)
//                    Text(process.tempoAtual)

                }
                
            }
            
            
            Button {
                
            viewModel.processEntered.send(.init(duracaoProcesso: 10, tamanhoProcesso: 10))
            viewModel.processEntered.send(.init(duracaoProcesso: 20, tamanhoProcesso: 10))
            viewModel.processEntered.send(.init(duracaoProcesso: 10, tamanhoProcesso: 10))
                
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
