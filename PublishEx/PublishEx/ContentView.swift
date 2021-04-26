//
//  ContentView.swift
//  PublishEx
//
//  Created by Арсений Паевщиков on 26.04.2021.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel(storage: Storage())
    
    var body: some View {
        Button("add") {
            viewModel.addStorage(9)
        }
        List(viewModel.dataList, id: \.self) { item in
            Text(item.description)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

final class ViewModel: ObservableObject {
    @Published var dataList: [Int] = []
    
    let storage: Storage
    var subscriptions = Set<AnyCancellable>()
    
    init(storage: Storage) {
        self.storage = storage
        
        storage.getData()
            .sink {
                self.dataList = $0
            }
            .store(in: &subscriptions)
        
        storage.subscribe()
            .sink {
                self.dataList = $0
            }
            .store(in: &subscriptions)
    }
    
    func addStorage(_ item: Int) {
        storage.addItem(item)
    }
}

final class Storage {
    func getData() -> AnyPublisher<[Int], Never> {
        Just(intList)
            .eraseToAnyPublisher()
    }
    
    private var subject = PassthroughSubject<[Int], Never>()
    
    var intList = [1, 2, 4, 5, 6]
    
    func addItem(_ item: Int) {
        intList.append(item)
        subject.send(intList)
    }
    
    func subscribe() -> AnyPublisher<[Int], Never> {
        subject.eraseToAnyPublisher()
    }
}
