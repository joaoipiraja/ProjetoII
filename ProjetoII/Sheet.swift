import SwiftUI


class Interval:ObservableObject{
    @Published var maximo:Int = 0
    @Published var minimo:Int = 0
    
    var range: ClosedRange<Int>{
        get{
            return self.minimo ... self.maximo
        }
    }

}
class SheetViewModel: ObservableObject{
    
    @Published var alocacao:EstrategiaAlocacao = .firstFit
    @Published var qntdProcessos:Int = 0
    @Published var tamanhoMemoria: Int = 0
    @Published var tamanhoMemoriaSistemaOperacional: Int = 0
    @Published var intervaloTamanhoProcesso: Interval = .init()
    @Published var intervaloTempoCriacao: Interval = .init()
    @Published var intervaloDuracao: Interval = .init()

}

struct Sheet: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: SheetViewModel

       var body: some View {
           
           
           
           Form {
               
                   Picker("Estratégia Alocacao", selection: $viewModel.alocacao) {
                       ForEach(EstrategiaAlocacao.allCases, id: \.self) { value in
                           Text(value.localizedName)
                               .tag(value)
                       }
                   }
                   
                   Section{
                       Stepper("Quantidade de processos: \(viewModel.qntdProcessos)",
                           value: $viewModel.qntdProcessos,
                           in: 0...100
                       )
                       
                       Stepper("Tamanho da Memória: \(viewModel.tamanhoMemoria)",
                           value:$viewModel.tamanhoMemoria,
                           in: 0...100
                       )
                       
                       Stepper("Tamanho da área de memória ocupada pelo sistema operacional: \(viewModel.tamanhoMemoriaSistemaOperacional)",
                           value: $viewModel.tamanhoMemoriaSistemaOperacional,
                               in: 0...viewModel.tamanhoMemoria
                       )
                      
                       
                       
                   }
                   
                   Section{
                       Stepper("Minimo: \(viewModel.intervaloTamanhoProcesso.minimo)",
                           value: $viewModel.intervaloTamanhoProcesso.minimo,
                               in: 0...viewModel.tamanhoMemoria
                       )
                       Stepper("Máximo: \(viewModel.intervaloTamanhoProcesso.maximo)",
                           value: $viewModel.intervaloTamanhoProcesso.maximo,
                           in: viewModel.tamanhoMemoria+1...viewModel.tamanhoMemoria
                       )

                   }header: {
                       Text("Intervalo Tamanho processo")
                   }
                   
                   Section{
                       Stepper("Minimo: \(viewModel.intervaloTempoCriacao.minimo) s",
                               value: $viewModel.intervaloTempoCriacao.minimo,
                           in: 0...100
                       )
                       Stepper("Máximo: \(viewModel.intervaloTempoCriacao.maximo) s",
                           value: $viewModel.intervaloTempoCriacao.maximo,
                           in: 0...100
                       )

                   }header: {
                       Text("Intervalo Tempo de Criação")
                   }

                   Section{
                       Stepper("Minimo: \(viewModel.intervaloDuracao.minimo) s",
                           value: $viewModel.intervaloDuracao.minimo,
                           in: 0...100
                       )
                       Stepper("Máximo: \(viewModel.intervaloDuracao.maximo) s",
                           value: $viewModel.intervaloDuracao.maximo,
                           in: 0...100
                       )

                   }header: {
                       Text("Intervalo Duração")
                   }
               
               
               
                Button("Iniciar Execucao") {
                    presentationMode.wrappedValue.dismiss()         // activate theme!
                }

                   
           }
               
       }
    
//    @State private var colorScheme = 1
//
//    var body: some View {
//
//
//
//
//        Picker("Color Scheme", selection: $colorScheme) {
//
//            EstrategiaAlocacao.AllCases.enumerated()
//
//
//            ForEach(<#_#>) { alg in
//                Text(alg).tag(0)
//            }
//
//
//        }.pickerStyle(WheelPickerStyle())
//    }
        
   
}

struct Sheet_Previews: PreviewProvider {
    static var previews: some View {
        Sheet(viewModel: .init())
    }
}
