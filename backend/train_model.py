# train_model.py
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.utils.class_weight import compute_class_weight
from sklearn.metrics import classification_report
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout, BatchNormalization, Input
import tensorflow.keras.backend as K

# -----------------------------
# 1. Load dataset
# -----------------------------
print("📂 Loading dataset...")
data = pd.read_csv("dataset.csv")

# Multi-label targets (all 9 abnormalities)
target_cols = [
    "PMS_PMDD", "PCOS", "Menorrhagia", "Amenorrhea",
    "Endometriosis", "Thyroid_Disorders", "Perimenopause",
    "Anemia", "Hormonal_Imbalance"
]
print(f"✅ Target columns: {target_cols}")

# Features (X) and labels (y)
X = data.drop(columns=target_cols).values
y = data[target_cols].values

print("\nClass distribution (sum of 1's per abnormality):")
print(data[target_cols].sum())

# -----------------------------
# 2. Preprocessing
# -----------------------------
scaler = StandardScaler()
X = scaler.fit_transform(X)

# Train-test split
X_train, X_val, y_train, y_val = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# -----------------------------
# 3. Compute Class Weights
# -----------------------------
class_weights = {}
for i, col in enumerate(target_cols):
    weights = compute_class_weight(
        class_weight="balanced",
        classes=np.array([0, 1]),
        y=data[col].values
    )
    class_weights[i] = {0: weights[0], 1: weights[1]}

print("\n⚖️ Computed class weights for each abnormality:")
for i, col in enumerate(target_cols):
    print(f"{col}: {class_weights[i]}")

# Custom weighted loss
def weighted_binary_crossentropy(y_true, y_pred):
    loss = 0
    for i in range(len(target_cols)):
        w0, w1 = class_weights[i][0], class_weights[i][1]
        loss_i = - (w1 * y_true[:, i] * K.log(y_pred[:, i] + 1e-7) +
                    w0 * (1 - y_true[:, i]) * K.log(1 - y_pred[:, i] + 1e-7))
        loss += K.mean(loss_i)
    return loss / len(target_cols)

# -----------------------------
# 4. Build Model
# -----------------------------
model = Sequential([
    Input(shape=(X.shape[1],)),
    Dense(128, activation="relu"),
    BatchNormalization(),
    Dropout(0.3),
    Dense(64, activation="relu"),
    Dropout(0.3),
    Dense(len(target_cols), activation="sigmoid")  # sigmoid for multi-label
])

model.compile(
    optimizer="adam",
    loss=weighted_binary_crossentropy,
    metrics=[tf.keras.metrics.AUC(name="auc")]
)

print(model.summary())

# -----------------------------
# 5. Train
# -----------------------------
history = model.fit(
    X_train, y_train,
    validation_data=(X_val, y_val),
    epochs=100,
    batch_size=8,
    verbose=1
)

# -----------------------------
# 6. Evaluate
# -----------------------------
print("📊 Evaluating model...")
y_pred = model.predict(X_val)
y_pred_classes = (y_pred > 0.5).astype(int)

for i, col in enumerate(target_cols):
    print(f"\n--- {col} ---")
    print(classification_report(y_val[:, i], y_pred_classes[:, i]))

# -----------------------------
# 7. Save model
# -----------------------------
os.makedirs("saved_models", exist_ok=True)
model.save("saved_models/mensus_multilabel_weighted.keras")
print("✅ Multi-label weighted model saved to saved_models/mensus_multilabel_weighted.keras")

# -----------------------------
# 8. Plot training curves
# -----------------------------
plt.plot(history.history["loss"], label="Train Loss")
plt.plot(history.history["val_loss"], label="Val Loss")
plt.plot(history.history["auc"], label="Train AUC")
plt.plot(history.history["val_auc"], label="Val AUC")
plt.xlabel("Epochs")
plt.ylabel("Value")
plt.legend()
plt.title("Training Progress with Class Weights")
plt.savefig("saved_models/multilabel_weighted_training_plot.png")
print("📊 Training curves saved to saved_models/multilabel_weighted_training_plot.png")
plt.close()
