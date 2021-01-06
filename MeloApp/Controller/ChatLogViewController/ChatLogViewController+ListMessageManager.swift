//
//  ChatLogViewController+ListMessageManager.swift
//  MeloApp
//
//  Created by Minh Tri on 1/4/21.
//

import Foundation
import UIKit

class ListMessage {
    var messages: [[Message]] = []
    
    var count: Int {
        get {
            return messages.count
        }
    }
    
    subscript(index: Int) -> [Message] {
        get {
            return messages[index]
        }
        
        set {
            messages[index] = newValue
        }
    }
    
    func addMessageBegin(_ message: Message) {
        if messages.count == 0 {
            messages.append([message])
            return
        }
            
        let dateMessAdd = message.sendAt as! Date
        let dateMessBegin = messages[0].first!.sendAt as! Date
        
        if abs(dateMessAdd.timeIntervalSince1970 - dateMessBegin.timeIntervalSince1970) > 600.0 {
            messages[0].insert(message, at: 0)
        } else {
            messages.insert([message], at: 0)
        }
    }
    
    func addMessageLast(_ message: Message) {
        if messages.count == 0 {
            messages.append([message])
            return
        }
        
        let index = messages.count - 1
        let lastMessage = messages[index].last!
        
        let dateMessAdd = message.sendAt as! Date
        let dateMessLast = lastMessage.sendAt as! Date
        
        if abs(dateMessAdd.timeIntervalSince1970 - dateMessLast.timeIntervalSince1970) > K.distanceTimeGroupMessage {
            messages.append([message])
        } else {
            messages[index].append(message)
        }
    }
    
    func addSectionFirst(_ sectionMessages: [Message]) {
        if sectionMessages.count == 0 { return }
        
        let (sortedKeys, groupedMessages) = groupMessages(sectionMessages)
            
        if messages.count == 0 {
            sortedKeys.forEach { (date) in
                if let values = groupedMessages[date] {
                    messages.append(values)
                }
            }
            return
        }
        
        let lastDateInNewSection = sortedKeys[sortedKeys.count - 1]
        let firstDateInFirstSection = messages[0].first!.sendAt as! Date
        
        if abs(lastDateInNewSection.timeIntervalSince1970 - firstDateInFirstSection.timeIntervalSince1970) > K.distanceTimeGroupMessage {
            messages.insert(groupedMessages[lastDateInNewSection]!, at: 0)
        } else {
            messages[0].insert(contentsOf: groupedMessages[lastDateInNewSection]!, at: 0)
        }
        
        for i in stride(from: sortedKeys.count - 2, to: 0, by: -1) {
            
            messages.insert(groupedMessages[sortedKeys[i]]!, at: 0)
        }
    }
    
    func addSectionLast(_ sectionMessages: [Message]) {
        if sectionMessages.count == 0 { return }
        
        let (sortedKeys, groupedMessages) = groupMessages(sectionMessages)
        
        if messages.count == 0 {
            sortedKeys.forEach { (date) in
                if let values = groupedMessages[date] {
                    messages.append(values)
                }
            }
            return
        }
        
        let firstDateInNewSection = sortedKeys[0]
        let lastDateInLastSection = messages[messages.count - 1].last!.sendAt as! Date
        
        if abs(firstDateInNewSection.timeIntervalSince1970 - lastDateInLastSection.timeIntervalSince1970) > K.distanceTimeGroupMessage {
            messages.append(groupedMessages[firstDateInNewSection]!)
        } else {
            messages[messages.count - 1].append(contentsOf: groupedMessages[firstDateInNewSection]!)
        }
        
        for i in 1..<sortedKeys.count {
            messages.append(groupedMessages[sortedKeys[i]]!)
        }
    }
    
    func updateMessage(_ newMessage: Message) {
        var prevIndex = 0
        var currIndex = 0
        let messageDate = newMessage.sendAt as! Date
        
        
        for (i, value) in messages.enumerated() {
            let firstDateInSection = value.first!.sendAt as! Date
            
            currIndex = i
            if messageDate > firstDateInSection {
                prevIndex = currIndex
            } else {
                break
            }
        }
        
        if let indexMessage = messages[prevIndex].firstIndex(where: { $0.uid! == newMessage.uid! }) {
            messages[prevIndex][indexMessage] = newMessage
        }
    }
    
    // Note: message sorted from firestore
    private func groupMessages(_ messages: [Message]) -> ([Date], [Date: [Message]]) {

        var flag: Date = Date(timeIntervalSince1970: 0)
        let result = Dictionary(grouping: messages) { (message) -> Date in

            let date = message.sendAt as! Date
            
            if abs(date.timeIntervalSince1970 - flag.timeIntervalSince1970) > K.distanceTimeGroupMessage {
                flag = date
            }

            return flag
        }
        
        let sortedKeys = result.keys.sorted()
        return (sortedKeys, result)
    }
}
