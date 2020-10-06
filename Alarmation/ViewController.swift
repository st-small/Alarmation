//
//  ViewController.swift
//  Alarmation
//
//  Created by Stanly Shiyanovskiy on 06.10.2020.
//

import UIKit
import UserNotifications

public final class ViewController: UITableViewController {

    // MARK: - Data
    private var groups = [Group]()

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "Arial Rounded MT Bold", size: 20)!]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        title = "Alarmadillo"
        
        groups.append(Group(name: "Enabled group", playSound: true, enabled: true, alarms: []))
        groups.append(Group(name: "Disabled group", playSound: true, enabled: false, alarms: []))

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addGroup))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Groups", style: .plain, target: nil, action: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(save), name: Notification.Name("save"), object: nil)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        load()
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Group", for: indexPath)

        let group = groups[indexPath.row]

        cell.textLabel?.text = group.name

        if group.enabled {
            cell.textLabel?.textColor = UIColor.black
        } else {
            cell.textLabel?.textColor = UIColor.red
        }

        if group.alarms.count == 1 {
            cell.detailTextLabel?.text = "1 alarm"
        } else {
            cell.detailTextLabel?.text = "\(group.alarms.count) alarms"
        }


        return cell
    }

    public override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        groups.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)

        save()
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let groupToEdit: Group

        if sender is Group {
            groupToEdit = sender as! Group
        } else {
            guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
            groupToEdit = groups[selectedIndexPath.row]
        }

        if let groupViewController = segue.destination as? GroupViewController {
            groupViewController.group = groupToEdit
        }
    }

    @objc
    private func addGroup() {
        let newGroup = Group(name: "Name this group", playSound: true, enabled: false, alarms: [])
        groups.append(newGroup)

        performSegue(withIdentifier: "EditGroup", sender: newGroup)

        save()
    }
    
    private func load() {
        do {
            groups.removeAll()

            let path = Helper.getDocumentsDirectory().appendingPathComponent("groups")
            let data = try Data(contentsOf: path)
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([Group].self, from: data) {
                groups = decoded
            }
        } catch {
            print("Failed to load")
        }

        tableView.reloadData()
    }
    
    @objc
    private func save() {
        do {
            let path = Helper.getDocumentsDirectory().appendingPathComponent("groups")
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(groups) {
                try encoded.write(to: path)
            }
        } catch {
            print(error.localizedDescription)
            print("Failed to save")
        }

        updateNotifications()
    }
    
    private func updateNotifications() {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .sound]) { [unowned self] (granted, error) in
            if granted {
                self.createNotifications()
            }
        }
    }
    
    private func createNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        for group in groups {
            guard group.enabled == true else { continue }

            for alarm in group.alarms {
                let notification = createNotificationRequest(group: group, alarm: alarm)

                center.add(notification) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error)")
                    }
                }
            }
        }
    }

    private func createNotificationRequest(group: Group, alarm: Alarm) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = alarm.name
        content.body = alarm.caption
        content.categoryIdentifier = "alarm"

        content.userInfo = ["group": group.id, "alarm": alarm.id]

        if group.playSound {
            content.sound = UNNotificationSound.default
        }

        content.attachments = createNotificationAttachments(alarm: alarm)
        let cal = Calendar.current

        var dateComponents = DateComponents()
        dateComponents.hour = cal.component(.hour, from: alarm.time)
        dateComponents.minute = cal.component(.minute, from: alarm.time)

        //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        return request
    }

    private func createNotificationAttachments(alarm: Alarm) -> [UNNotificationAttachment] {
        guard alarm.image.count > 0 else { return [] }

        let fm = FileManager.default

        do {
            let imageURL = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
            let copyURL = Helper.getDocumentsDirectory().appendingPathComponent("\(UUID().uuidString).jpg")
            try fm.copyItem(at: imageURL, to: copyURL)

            let attachment = try UNNotificationAttachment(identifier: UUID().uuidString, url: copyURL)

            return [attachment]
        } catch {
            print("Failed to attach alarm image: \(error)")
            return []
        }
    }
    
    private func display(group groupID: String) {
        _ = navigationController?.popToRootViewController(animated: false)

        for group in groups {
            if group.id == groupID {
                performSegue(withIdentifier: "EditGroup", sender: group)
                return
            }
        }
    }

    private func destroy(group groupID: String) {
        _ = navigationController?.popToRootViewController(animated: false)

        for (index, group) in groups.enumerated() {
            if group.id == groupID {
                groups.remove(at: index)
                break
            }
        }

        save()
        load()
    }

    private func rename(group groupID: String, newName: String) {
        _ = navigationController?.popToRootViewController(animated: false)

        for group in groups {
            if group.id == groupID {
                group.name = newName
                break
            }
        }

        save()
        load()
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension ViewController: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let groupID = userInfo["group"] as? String {
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                print("Default identifier")
                
            case UNNotificationDismissActionIdentifier:
                print("Dismiss identifier")
                
            case "show":
                display(group: groupID)
                break
                
            case "destroy":
                destroy(group: groupID)
                break
                
            case "rename":
                if let textResponse = response as? UNTextInputNotificationResponse {
                    rename(group: groupID, newName: textResponse.userText)
                }
                
                break
                
            default:
                break
            }
        }
        
        completionHandler()
    }
}
