import Foundation

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
