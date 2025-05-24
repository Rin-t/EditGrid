//
//  ContentView.swift
//  SampleExchangeCard
//
//  Created by Rin on 2025/05/24.
//

import SwiftUI
import Observation

struct Product: Identifiable {
    let id = UUID().uuidString
    let color: Color
}

struct ContentView: View {
    
    @State var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            if viewModel.products.isEmpty {
                ProgressView()
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.flexible()),
                                  GridItem(.flexible())]
                    ) {
                        ForEach(viewModel.products) { product in
                            productCard(product: product)
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    @ViewBuilder
    private func productCard(product: Product) -> some View {
        ZStack {
            product.color
            Text(product.color.description)
        }
        .cornerRadius(10)
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    ContentView()
}


@MainActor
@Observable
final class ViewModel {
    
    @ObservationIgnored
    let usecase = UseCase()
    
    var products: [Product] = []
    
    func onAppear() {
        Task {
            products = await usecase.fetch()
            print("完了")
        }
    }
}


actor UseCase {
    func fetch() async -> [Product] {
        try? await Task.sleep(nanoseconds: 2000000000)
        
        return [
            Product(color: .red),
            Product(color: .blue),
            Product(color: .green),
            Product(color: .yellow),
            Product(color: .orange),
            Product(color: .purple),
            Product(color: .pink),
            Product(color: .gray),
            Product(color: .cyan),
            Product(color: .mint),
            Product(color: .indigo),
            Product(color: .brown)
        ]
    }
}
