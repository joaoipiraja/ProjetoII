//
//  Card.swift
//  ProjetoII
//
//  Created by João Victor Ipirajá de Alencar on 26/11/22.
//

import SwiftUI




struct Card: View{

    @ObservedObject var ram: MemoriaRAMModel
    @State var progress:Double = 0.0
 


    var body: some View{
       
        switch (self.ram.tipo){
        case .so:
            ZStack{
                Color.blue.ignoresSafeArea()
                VStack{
//                    Text("\(self.ram.posicaoInicio ?? -1)")
//                        .font(.system(size: 30))
//                        .foregroundColor(.white)
                    Spacer()
                    Text("S.O")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                    Text("\(ram.tamanho ?? -1)")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                    Spacer()
//                    Text("\(self.ram.posicaoFim  ?? -1)")
//                        .font(.system(size: 30))
//                        .foregroundColor(.white)
                }.padding()
            }

            case .processo(processo: let p):

            ZStack{
                Color.red.ignoresSafeArea()
                VStack(){
                   
                    Spacer()
                    Text("\(p.idString)")
                        .font(.system(size: 30))
                    Text("\(ram.tamanho ?? -1)")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Spacer()
                  
                        
                }.padding().foregroundColor(.white)
            }

            case .buraco:

            ZStack{
                Color.red.opacity(0.5).ignoresSafeArea()
                VStack{
                    
              
                    Spacer()
                    Text("Buraco")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                    Text("\(ram.tamanho ?? -1)")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                    Spacer()
                 
                    
                }.padding()
            }


    }
    }
}



struct Card_Previews: PreviewProvider {
    static var previews: some View {
        Card(ram: .MOCK).frame(width: 300, height: 350)
    }
}