//
//  Queue.swift
//  ProjetoII
//
//  Created by João Victor Ipirajá de Alencar on 22/11/22.
//

import Foundation

struct Queue<T: AnyObject> {
    
        var elements: [T] = []

        mutating func enqueue(_ value: T) {
            elements.append(value)
        }

        mutating func dequeue() -> T? {
        guard !elements.isEmpty else {
          return nil
        }
        return elements.removeFirst()
      }


}
