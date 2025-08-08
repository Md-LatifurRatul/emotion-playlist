# app.py
from flask import Flask, request, jsonify
import numpy as np
import librosa
import tensorflow as tf
import os

app = Flask(__name__)

interpreter = tf.lite.Interpreter(model_path="emotion_audio.tflite")
interpreter.allocate_tensors()
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

labels = ['neutral', 'calm', 'happy', 'sad', 'angry', 'fearful', 'disgust', 'surprised']

def extract_mfcc(file_path):
    y, sr = librosa.load(file_path, sr=16000, mono=True, duration=3)
    mfcc = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=40).T
    if mfcc.shape[0] < 130:
        mfcc = np.pad(mfcc, ((0, 130 - mfcc.shape[0]), (0, 0)), mode='constant')
    else:
        mfcc = mfcc[:130]
    return mfcc.astype(np.float32)

@app.route("/health", methods=["GET"])
def health_check():
    return "Server is running", 200


@app.route("/predict", methods=["POST"])
def predict():
    if "audio" not in request.files:
        print("[Flask] No audio file received")
        return jsonify({"error": "Missing audio file."}), 400

    audio_file = request.files["audio"]
    file_path = "temp.wav"
    audio_file.save(file_path)
    print(f"[Flask] Received audio file: {file_path}, size: {os.path.getsize(file_path)} bytes")

    try:
        mfcc = extract_mfcc(file_path)
        print(f"[Flask] Extracted MFCC shape: {mfcc.shape}")
        input_data = np.expand_dims(mfcc, axis=0)  # shape (1, 130, 40)

        interpreter.set_tensor(input_details[0]['index'], input_data)
        interpreter.invoke()
        output = interpreter.get_tensor(output_details[0]['index'])
        print(f"[Flask] Model raw output: {output}")
        predicted_index = int(np.argmax(output))
        emotion = labels[predicted_index]
        print(f"[Flask] Predicted emotion: {emotion}")

        return jsonify({"emotion": emotion})

    except Exception as e:
        print(f"[Flask] Error during prediction: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if os.path.exists(file_path):
            os.remove(file_path)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
