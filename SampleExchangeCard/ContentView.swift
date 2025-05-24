//
//  ContentView.swift
//  SampleExchangeCard
//
//  Created by Rin on 2025/05/24.
//

import SwiftUI
import Observation
import UniformTypeIdentifiers

extension View {
    @ViewBuilder
    func modifiers<Content: View>(@ViewBuilder content: @escaping (Self) -> Content) -> some View{
        content(self)
    }
}

struct Product: Identifiable, Equatable {
    let id = UUID().uuidString
    let color: Color
    
    static func == (lhs: Product, rhs: Product) -> Bool {
         return lhs.id == rhs.id
     }
}

enum ExchangeType: CaseIterable {
    case pokepoke
    case iosApp
    
    var name: String {
        switch self {
        case .pokepoke:
            return "いれかえ"
        case .iosApp:
            return "あぷりぽいの"
        }
    }
}

struct ContentView: View {
    
    @State var viewModel = ViewModel()
    
    @State var exchangeType: ExchangeType = .pokepoke
    @State private var draggingItem: Product?

    
    var body: some View {
        VStack {
            Picker("", selection: $exchangeType) {
                ForEach(ExchangeType.allCases, id: \.self) {
                    Text($0.name)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            if viewModel.products.isEmpty {
                ProgressView()
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ]
                    ) {
                        ForEach(viewModel.products) { product in
                            productCard(product: product)
                                .modifiers { card in
                                    switch exchangeType {
                                    case .pokepoke:
                                        card
                                            .draggable(product.id) {
                                                productCard(product: product)
                                                    .frame(width: 100, height: 100)
                                                    .opacity(0.5)
                                            }
                                            .dropDestination(for: String.self) { droppedProduct, _ in
                                                viewModel.exchangeProducts(sourceId: droppedProduct.first ?? "", targetId: product.id)
                                                return true
                                            } isTargeted: { isTargeted in
                                                viewModel.updateTargetState(productId: product.id, isTargeted: isTargeted)
                                            }
                                    case .iosApp:
                                        card
                                            .draggable(product.id) {
                                                productCard(product: product)
                                                    .frame(width: 100, height: 100)
                                                    .opacity(0.5)
                                                    .onAppear {
                                                        draggingItem = product
                                                    }
                                            }
                                            .dropDestination(for: String.self) { items, location in
                                                draggingItem = nil
                                                return false
                                            } isTargeted: { status in
                                                if let draggingItem, status, draggingItem.id != product.id {
                                                    if let sourceIndex = viewModel.products.firstIndex(of: draggingItem),
                                                       let destinationIndex = viewModel.products.firstIndex(of: product) {
                                                        withAnimation(.bouncy) {
                                                            let sourceItem = viewModel.products.remove(at: sourceIndex)
                                                            viewModel.products.insert(sourceItem, at: destinationIndex)
                                                        }
                                                    }
                                                }
                                            }
                                    }
                                }
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
        Rectangle()
            .fill(product.color.gradient)
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
    var targetedProductIds: Set<String> = []
    
    func onAppear() {
        Task {
            products = await usecase.fetch()
        }
    }
    
    func exchangeProducts(sourceId: String, targetId: String) {
        guard let sourceIndex = products.firstIndex(where: { $0.id == sourceId }),
              let targetIndex = products.firstIndex(where: { $0.id == targetId }),
              sourceIndex != targetIndex else {
            return
        }
        
        let sourceProduct = products[sourceIndex]
        let targetProduct = products[targetIndex]
        
        products[sourceIndex] = targetProduct
        products[targetIndex] = sourceProduct
    }
    
    func updateTargetState(productId: String, isTargeted: Bool) {
        if isTargeted {
            targetedProductIds.insert(productId)
        } else {
            targetedProductIds.remove(productId)
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
            Product(color: .brown),
            Product(color: .teal),
            Product(color: .black),
            Product(color: Color(red: 0.9, green: 0.4, blue: 0.7)), // ピンク系
            Product(color: Color(red: 0.5, green: 0.3, blue: 0.9)), // パープル系
            Product(color: Color(red: 0.2, green: 0.6, blue: 0.9)), // ライトブルー
            Product(color: Color(red: 0.7, green: 0.9, blue: 0.3)), // ライトグリーン
            Product(color: Color(red: 0.9, green: 0.8, blue: 0.2)), // ゴールド
            Product(color: Color(red: 0.3, green: 0.3, blue: 0.3)), // ダークグレー
            Product(color: Color(red: 0.6, green: 0.4, blue: 0.2)), // ブラウン系
            Product(color: Color(red: 0.9, green: 0.1, blue: 0.1))  // 明るい赤
        ]
    }
}
