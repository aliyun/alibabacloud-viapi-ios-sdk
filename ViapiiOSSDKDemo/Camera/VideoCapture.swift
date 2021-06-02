//
//  VideoCapture.swift
//  DaMoLab
//
//  Created by 薛林 on 2020/10/10.
//

import AVFoundation
import CoreVideo
import UIKit
import VideoToolbox

// 代理
@objc protocol VideoCaptureDelegate: AnyObject {
    @objc func videoCapture(_ videoCapture: VideoCapture, didCaptureFrame sampleBuffer: CMSampleBuffer)
}

/// - Tag: VideoCapture
@objc class VideoCapture: NSObject {
    enum VideoCaptureError: Error {
        case captureSessionIsMissing
        case invalidInput
        case invalidOutput
        case unknown
    }

    /// The delegate to receive the captured frames.
    @objc weak var delegate: VideoCaptureDelegate?

    /// A capture session used to coordinate the flow of data from input devices to capture outputs.
    let captureSession = AVCaptureSession()

    /// A capture output that records video and provides access to video frames. Captured frames are passed to the
    /// delegate via the `captureOutput()` method.
    let videoOutput = AVCaptureVideoDataOutput()

    /// The current camera's position.
    private(set) var cameraPostion = AVCaptureDevice.Position.front

    /// The dispatch queue responsible for processing camera set up and frame capture.
    private let sessionQueue = DispatchQueue(
        label: "com.example.damo.ai.video.sessionqueue")

    /// Toggles between the front and back camera.
    public func flipCamera(completion: @escaping (Error?) -> Void) {
        DispatchQueue.main.async {
            do {
                self.cameraPostion = self.cameraPostion == .back ? .front : .back

                // Indicate the start of a set of configuration changes to the capture session.
                self.captureSession.beginConfiguration()

                try self.setCaptureSessionInput()
                try self.setCaptureSessionOutput()

                // Commit configuration changes.
                self.captureSession.commitConfiguration()
                
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    

    /// Asynchronously sets up the capture session.
    ///
    /// - parameters:
    ///     - completion: Handler called once the camera is set up (or fails).
    @objc public func setUpAVCapture(completion: @escaping (Error?) -> Void) {
        sessionQueue.async {
            do {
                try self.setUpAVCapture()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }

    private func setUpAVCapture() throws {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .hd1280x720

        try setCaptureSessionInput()

        try setCaptureSessionOutput()

        captureSession.commitConfiguration()
    }

    private func setCaptureSessionInput() throws {
        // Use the default capture device to obtain access to the physical device
        // and associated properties.
        var cd: AVCaptureDevice?
        if #available(iOS 10.0, *) {
            guard let captureDevice = AVCaptureDevice.default(
                    .builtInWideAngleCamera,
                    for: AVMediaType.video,
                    position: cameraPostion) else {
                throw VideoCaptureError.invalidInput
            }
            cd = captureDevice
        } else {
            cd = cameraDevice(with: cameraPostion)
        }
        guard let captureDevice = cd else { return }
        // Remove any existing inputs.
        captureSession.inputs.forEach { input in
            captureSession.removeInput(input)
        }
        // 修改帧率
        let fps = 5
        let fpsRange = captureDevice.activeFormat.videoSupportedFrameRateRanges.first
        if fps > Int(fpsRange!.maxFrameRate) || fps < Int(fpsRange!.minFrameRate) {
            print("not soupport!")
        } else {
            do {
                try captureDevice.lockForConfiguration()
                captureDevice.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(fps))
                captureDevice.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(fps))
                captureDevice.unlockForConfiguration()
            } catch {
                print("\(error)")
            }
        }
        
        // Create an instance of AVCaptureDeviceInput to capture the data from
        // the capture device.
        guard let videoInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            throw VideoCaptureError.invalidInput
        }

        guard captureSession.canAddInput(videoInput) else {
            throw VideoCaptureError.invalidInput
        }

        captureSession.addInput(videoInput)
    }

    private func setCaptureSessionOutput() throws {
        // Remove any previous outputs.
        captureSession.outputs.forEach { output in
            captureSession.removeOutput(output)
        }

        // Set the pixel type.
//        let settings: [String: Any] = [
//            String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_32BGRA
//        ]
        
        let settings: [String: Any] = [
            String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
        ]

        videoOutput.videoSettings = settings
        
        // Discard newer frames that arrive while the dispatch queue is already busy with
        // an older frame.
        videoOutput.alwaysDiscardsLateVideoFrames = true

        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)

        guard captureSession.canAddOutput(videoOutput) else {
            throw VideoCaptureError.invalidOutput
        }

        captureSession.addOutput(videoOutput)

        // Update the video orientation
        if let connection = videoOutput.connection(with: .video),
            connection.isVideoOrientationSupported {
            connection.videoOrientation =
                AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue)!
            connection.isVideoMirrored = cameraPostion == .front

            // Inverse the landscape orientation to force the image in the upward
            connection.videoOrientation = .portrait

//            if connection.videoOrientation == .portrait {
//                connection.videoOrientation = .portrait
//            }
//            else if connection.videoOrientation == .landscapeLeft {
//                connection.videoOrientation = .landscapeLeft
//            } else if connection.videoOrientation == .landscapeRight {
//                connection.videoOrientation = .landscapeRight
//            }
        }
    }

    /// Begin capturing frames.
    ///
    /// - Note: This is performed off the main thread as starting a capture session can be time-consuming.
    ///
    /// - parameters:
    ///     - completionHandler: Handler called once the session has started running.
    @objc public func startCapturing(completion completionHandler: (() -> Void)? = nil) {
        sessionQueue.async {
            if !self.captureSession.isRunning {
                // Invoke the startRunning method of the captureSession to start the
                // flow of data from the inputs to the outputs.
                self.captureSession.startRunning()
            }

            if let completionHandler = completionHandler {
                DispatchQueue.main.async {
                    completionHandler()
                }
            }
        }
    }

    /// End capturing frames
    ///
    /// - Note: This is performed off the main thread, as stopping a capture session can be time-consuming.
    ///
    /// - parameters:
    ///     - completionHandler: Handler called once the session has stopping running.
    @objc public func stopCapturing(completion completionHandler: (() -> Void)? = nil) {
        sessionQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }

            if let completionHandler = completionHandler {
                DispatchQueue.main.async {
                    completionHandler()
                }
            }
        }
    }
    
    private func cameraDevice(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let cameras = AVCaptureDevice.devices(for: .video)
        for camera in cameras {
            if (camera.position == position) {
                return camera
            }
        }
        return nil
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension VideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {

    public func captureOutput(_ output: AVCaptureOutput,
                              didOutput sampleBuffer: CMSampleBuffer,
                              from connection: AVCaptureConnection) {
        guard let delegate = delegate else { return }
        delegate.videoCapture(self, didCaptureFrame: sampleBuffer)
    }
}
