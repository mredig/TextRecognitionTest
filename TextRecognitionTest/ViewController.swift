//
//  ViewController.swift
//  TextRecognitionTest
//
//  Created by Michael Redig on 10/31/19.
//  Copyright © 2019 Red_Egg Productions. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		guard let image = UIImage(named: "test") else { return }
		getText(from: image)
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
					print(recognizedText.string)
				}
			}
		}
		request.recognitionLevel = .accurate
		request.revision = VNRecognizeTextRequestRevision1
		request.usesLanguageCorrection = false

		do {
			try requestHandler.perform([request])
		} catch {
			NSLog("Error requesting text recognition: \(error)")
		}
	}

}
