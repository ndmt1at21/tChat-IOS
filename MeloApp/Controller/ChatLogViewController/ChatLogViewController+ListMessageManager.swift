//
//  ChatLogViewController+ListMessageManager.swift
//  MeloApp
//
//  Created by Minh Tri on 1/4/21.
//

import Foundation
import UIKit

/// Class manage array of messages group by distance date, one array messages - one group
///
/// Element of ListMessages is array of messages
///
/// Date key of group is oldest message in array message = first message in array messages
class ListMessages {
    var messages: [[Message]] = []
    
    /// Number of array messages in ListMessages
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
    
    /// This function add one message to ListMessage at begin ListMessage
    ///
    /// Array messages auto append or create new section for message depend message's date
    ///
    /// - Parameter message: message add to ListMessage
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
    
    /// This function add one message to ListMessage at last ListMessage
    ///
    /// Array messages auto append or create new section for message depend message's date
    ///
    /// - Parameter message: message add to ListMessage
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
    
    /// This function add array messages to ListMessage at begin ListMessage
    ///
    /// Array messages auto splited into sub section message (by distance date config in class) and add to begin ListMessage
    ///
    /// - Parameter sectionMessages: array message add to ListMessage
    func addSectionFirst(_ sectionMessages: [Message]) {
        if sectionMessages.count == 0 { return }
        
        // group message by distance time
        let (sortedKeys, groupedMessages) = groupMessages(sectionMessages, by: K.distanceTimeGroupMessage)
        
        // if messages[] dont't have anything
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
    
    /// This function add array messages to ListMessage at last
    ///
    /// Array messages auto splited into sub section message (by distance date config in class) and add to ListMessage
    ///
    /// - Parameter sectionMessages: array message add to ListMessage
    func addSectionLast(_ sectionMessages: [Message]) {
        if sectionMessages.count == 0 { return }
        
        let (sortedKeys, groupedMessages) = groupMessages(sectionMessages, by: K.distanceTimeGroupMessage)
        
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
    
    /// This function returns update message by id when it changed
    ///
    /// ```
    /// updateMessage(Message(id: 123, 'test'))
    /// ```
    ///
    /// - Parameter newMessage: new message content use to update with ID already in ListMessage
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
    
    /// This function returns a tupple (sortedDateKeys, sortedDateDictionary) for a give messages
    ///
    /// ```
    /// groupMessage([m1, m2], 500)
    /// ```
    /// Why use sortedKeys in return? Because Dictionary Date: [Message] can't sorted, so use sortedKeys to find faster and in sorted position
    ///
    /// - Parameter messages: Array messages will be grouped by distanceTime
    /// - Parameter distanceTime: Distance time between two group (in miliseconds)
    /// - Returns: sortedDateKeys (sorted ascending date key in each group) and dateDictionary (messages array with key)
    private func groupMessages(_ messages: [Message], by distanceTime: Double) -> ([Date], [Date: [Message]]) {

        var flag: Date = Date(timeIntervalSince1970: 0)
        let result = Dictionary(grouping: messages) { (message) -> Date in

            let date = message.sendAt as! Date
            
            if abs(date.timeIntervalSince1970 - flag.timeIntervalSince1970) > distanceTime {
                flag = date
            }

            return flag
        }
        
        let sortedKeys = result.keys.sorted()
        return (sortedKeys, result)
    }
}
