//
//  ViewModelType.swift
//  Crippo
//
//  Created by 이빈 on 4/18/25.
//

import Foundation
import Combine

protocol ViewModelType: AnyObject, ObservableObject {
    associatedtype Input
    associatedtype Output
    associatedtype Action
    
    var cancellables: Set<AnyCancellable> { get set }
    
    var input: Input { get set }
    var output: Output { get set }
    
    func transform()
    func action(_ action: Action)
}
