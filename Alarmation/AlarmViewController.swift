//
//  AlarmViewController.swift
//  Alarmation
//
//  Created by Stanly Shiyanovskiy on 06.10.2020.
//

import UIKit

public final class AlarmViewController: UITableViewController {

    // MARK: - Outlets
    @IBOutlet private var name: UITextField!
    @IBOutlet private var caption: UITextField!
    @IBOutlet private var datePicker: UIDatePicker!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var tapToSelectImage: UILabel!
    
    // MARK: - Data
    public var alarm: Alarm!
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        title = alarm.name

        name.text = alarm.name
        caption.text = alarm.caption
        datePicker.date = alarm.time

        if alarm.image.count > 0 {
            let imageFilename = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
            imageView.image = UIImage(contentsOfFile: imageFilename.path)
            tapToSelectImage.isHidden = true
        }
    }
    
    private func save() {
        NotificationCenter.default.post(name: Notification.Name("save"), object: nil)
    }
    
    // MARK: - Actions
    @IBAction private func datePickerChanged(_ sender: UIDatePicker) {
        alarm.time = datePicker.date
        save()
    }

    @IBAction private func imageViewTapped(_ sender: UIImageView) {
        let vc = UIImagePickerController()
        vc.modalPresentationStyle = .formSheet
        vc.delegate = self
        present(vc, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension AlarmViewController: UITextFieldDelegate {
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        alarm.name = name.text!
        alarm.caption = caption.text!
        title = alarm.name

        save()
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension AlarmViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else { return }
        let fm = FileManager()

        if alarm.image.count > 0 {
            do {
                let currentImage = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)

                if fm.fileExists(atPath: currentImage.path) {
                    try fm.removeItem(at: currentImage)
                }
            } catch {
                print("Failed to remove current image")
            }
        }

        do {
            alarm.image = "\(UUID().uuidString).jpg"
            let newPath = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)

            let jpeg = image.jpegData(compressionQuality: 0.8)
            try jpeg?.write(to: newPath)

            save()
        } catch {
            print("Failed to save new image")
        }

        imageView.image = image
        tapToSelectImage.isHidden = true
    }
}
