# test_tflite.py
import numpy as np
import tensorflow as tf
import pandas as pd

# -----------------------------
# 1. Load TFLite model
# -----------------------------
tflite_model_path = "saved_models/mensus_multilabel_weighted.tflite"
interpreter = tf.lite.Interpreter(model_path=tflite_model_path)
interpreter.allocate_tensors()

# Get input & output details
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

print("📂 Input details:", input_details)
print("📂 Output details:", output_details)

# -----------------------------
# 2. Abnormality labels
# -----------------------------
labels = [
    "PMS_PMDD",
    "PCOS",
    "Menorrhagia",
    "Amenorrhea",
    "Endometriosis",
    "Thyroid_Disorders",
    "Perimenopause",
    "Anemia",
    "Hormonal_Imbalance"
]

# -----------------------------
# 3. Option A: Manual input
# -----------------------------
# Replace with real patient values
manual_input = [
    7,   # Sleep_hours
    0,   # Weight_Loss
    1,   # Weight_Gain
    0,   # Weight_Normal
    0,   # Smoking_Alcohol
    0,   # Birth_control_use
    1,   # Hair_Loss
    0,   # Acne
    1,   # Fatigue
    0,   # Bloating
    1,   # Nausea
    0,   # Dizziness
    0,   # Hot_flashes
    3,   # Headache (scale 1–5)
    2,   # Lower_back_pain (scale 1–5)
    1,   # Pain_during_sex (scale 1–5)
    3,   # Flow (scale 1–5)
    2,   # Pelvic_pain (scale 1–5)
    4,   # Stress (scale 1–5)
    2,   # Irritability
    1,   # Forgetfulness
    0,   # Depression
    0,   # Tension
    0    # Social_withdrawal
]

input_data = np.array([manual_input], dtype=np.float32)

# -----------------------------
# 3. Option B: Load from dataset row
# -----------------------------
# Uncomment this if you want to test a row from dataset.csv
# df = pd.read_csv("dataset.csv")
# input_data = df.drop(columns=[
#     "PMS_PMDD", "PCOS", "Menorrhagia", "Amenorrhea",
#     "Endometriosis", "Thyroid_Disorders", "Perimenopause",
#     "Anemia", "Hormonal_Imbalance"
# ]).iloc[[0]].values.astype(np.float32)  # take first row

print("\n🔍 Input shape:", input_data.shape)

# -----------------------------
# 4. Run Inference
# -----------------------------
interpreter.set_tensor(input_details[0]['index'], input_data)
interpreter.invoke()
predictions = interpreter.get_tensor(output_details[0]['index'])

print("\n✅ Prediction output (probabilities):")
print(predictions)

# -----------------------------
# 5. Thresholded Predictions
# -----------------------------
threshold = 0.5
binary_predictions = (predictions >= threshold).astype(int)

print("\n🔎 Thresholded Predictions (0 = absent, 1 = present):")
for i, label in enumerate(labels):
    prob = predictions[0][i]
    pred = binary_predictions[0][i]
    print(f"{label:20s} → {pred} (prob={prob:.3f})")
