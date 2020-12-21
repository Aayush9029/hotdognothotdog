//
//  CameraView.swift
//  hotdognothotdog
//
//  Created by Aayush Pokharel on 2020-12-21.
//

import SwiftUI

//Used ny the extension
import CoreML
import Vision

struct CameraView: View {
    
    @StateObject var camera = CameraModel()
    @State var resultText = ""

    
    
    var body: some View{
        ZStack{
            ZStack{
                // Going to Be Camera preview...
                CameraPreview(camera: camera)
                    .ignoresSafeArea(.all, edges: .all)
                VStack{
                    if camera.isClassified && resultText != ""{
                        Text(resultText)
                            .font(.system(size: 32))
                            .fontWeight(.bold)
                            .padding(100)
                            .background(Color.red)
                            .clipShape(Circle())
                            .shadow(color: .pink, radius: 10, x: -2, y: -2)
                            .shadow(color: .black, radius: 10, x: 2, y: 2)
                    }
                    else{
                        Text("Take Picture to Get Started")
                    }
                    Spacer()
                }.padding()
            }
            
            VStack{
                Spacer()
                
                HStack{
                    if camera.isTaken{
                        Button(action: {
                            if !camera.isClassified{
                                Classify(image: camera.savePic()!)
    
                            }else{
                                camera.isClassified = false
                                camera.reTake()
                            }
                            
                        }, label: {
                            if camera.isClassified{
                                Text("Retake")
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                    .padding(.vertical,20)
                                    .padding(.horizontal,40)
                                    .background(Color.red)
                                    .clipShape(Capsule())
                            }else{
                                
                                
                                Text("Classify")
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                    .padding(.vertical,20)
                                    .padding(.horizontal,40)
                                    .background(Color.green)
                                    .clipShape(Capsule())
                            }
                        })
                        .padding(.leading)
                    }
                    else{
                        
                        Button(action: camera.takePic, label: {
                            
                            ZStack{
                                
                                Circle()
                                    .fill(Color.pink)
                                    .frame(width: 65, height: 65)
                                
                                Circle()
                                    .stroke(Color.red,lineWidth: 2)
                                    .frame(width: 75, height: 75)
                            }
                        })
                    }
                }
                .frame(height: 75)
            }
        }
        .onAppear(perform: {
            
            camera.Check()
        })
        .alert(isPresented: $camera.alert) {
            Alert(title: Text("Please Enable Camera Access"))
        }
    }
}

extension CameraView{
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func Classify(image: UIImage){
        
        guard let model = try? VNCoreMLModel(for: HotDogClassifier().model) else {return}
        
        guard let ciImage = CIImage(image: image)else{return}
        
        let request = VNCoreMLRequest(model: model) { request, error in
            let results = request.results?.first as? VNClassificationObservation
            print(results?.identifier ?? "Error")
            simpleSuccess()
            DispatchQueue.main.sync {
                resultText =  results?.identifier ?? "Error"
                camera.isClassified = true
               
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
}
