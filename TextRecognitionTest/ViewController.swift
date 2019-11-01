//
//  ViewController.swift
//  TextRecognitionTest
//
//  Created by Michael Redig on 10/31/19.
//  Copyright © 2019 Red_Egg Productions. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

class ViewController: UIViewController {
	@IBOutlet weak var textView: UITextView!

	@IBAction func pressedAddButton(_ sender: UIBarButtonItem) {
		let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

		switch authorizationStatus {
		case .authorized:
			presentImagePickerController()
		case .notDetermined:
			AVCaptureDevice.requestAccess(for: .video) { granted in
				if granted {
					DispatchQueue.main.async {
						self.presentImagePickerController()
					}
				} else {
					print("User denied camera access")
				}
			}
		default:
			NSLog("No permission for camera/photo library")
		}
	}

	private func presentImagePickerController() {
		guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
			NSLog("Can't access camera")
			return
		}

		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.sourceType = .camera
		present(imagePicker, animated: true, completion: nil)
	}

	func getText(from image: UIImage) {
		guard let cgImage = image.cgImage else { return }
		let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

		let request = VNRecognizeTextRequest { request, error in
			if let error = error {
				print("Error recognizing text: \(error)")
			}

			guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
			for currentObservation in observations {
				let topCandidate = currentObservation.topCandidates(1)
				if let recognizedText = topCandidate.first {
//					print(recognizedText.string)
					DispatchQueue.main.async {
						self.textView.text += "\(recognizedText.string)\n"
					}
				}
			}
		}
		request.recognitionLevel = .accurate
		request.revision = VNRecognizeTextRequestRevision1
		request.usesLanguageCorrection = true

		do {
			try requestHandler.perform([request])
		} catch {
			NSLog("Error requesting text recognition: \(error)")
		}
	}
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

		picker.dismiss(animated: true)

		guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
		textView.text = ""
		getText(from: image)
	}
}
