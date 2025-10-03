import tensorflow as tf
from tensorflow import keras

MODEL_PATH = "saved_models/mensus_multilabel_weighted.keras"
TFLITE_PATH = "saved_models/mensus_multilabel_weighted.tflite"

print("📂 Loading trained model...")
# Load without compiling since we only need inference
model = keras.models.load_model(MODEL_PATH, compile=False)

print("🔄 Converting to TensorFlow Lite...")
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

with open(TFLITE_PATH, "wb") as f:
    f.write(tflite_model)

print(f"✅ Model successfully converted to {TFLITE_PATH}")
