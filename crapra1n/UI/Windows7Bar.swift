//
//  Windows7Bar.swift
//  crapra1n
//
//  Created by Lakhan Lothiyi on 13/10/2022.
//

import SwiftUI

struct Windows7Bar: View {
    
    @Binding var value: Float
    @State var max: Float = 1
    
    @State var timer: Timer = Timer()
    
    @Environment(\.colorScheme) var cs
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                
                HStack {
                    GeometryReader { rectGeo in
                        Rectangle()
                            .foregroundColor(.green)
                            .frame(width: CGFloat( value / max ) * geo.size.width)
                            .overlay {
                                HStack {
                                    Rectangle()
                                        .fill(
                                            LinearGradient(colors: [.clear, .white.opacity(0.6), .clear], startPoint: .leading, endPoint: .trailing)
                                        )
                                        .frame(width: 80)
                                        .zIndex(3)
                                }
                            }
                    }
                    
                    Rectangle()
                        .foregroundColor(cs == .light ? .white : .black)
                        .zIndex(4)
                }
                
                Rectangle()
                    .foregroundColor(.clear)
                    .border(Color(.lightGray), width: 2)
                    .zIndex(5)
            }
            .frame(maxWidth: .infinity, maxHeight: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: 40)
    }
}

struct Windows7Bar_Previews: PreviewProvider {
    static var previews: some View {
        previewView()
    }
}

struct previewView: View {
    @State var number: Float = 0
    
    var body: some View {
        VStack {
            Windows7Bar(value: $number)
                .task {
                    Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                        number+=0.001
                        
                        if number >= 1 {
                            number = 0
                        }
                    }
                }
        }
    }
}
