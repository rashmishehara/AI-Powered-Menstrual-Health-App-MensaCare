# AI-Powered Menstrual Health App-MENSACARE

## 📌 Overview  
The **AI-Powered Menstrual Health App** is a mobile application designed to help women manage their menstrual health effectively. Unlike traditional cycle tracking apps, this project leverages **Artificial Intelligence (AI)** to detect menstrual irregularities, provide **personalized health recommendations**, enable **secure teleconsultations**, and offer **private access to sanitary products**.  

Our mission is to create a **comprehensive, secure, and user-friendly platform** that empowers women to take control of their menstrual health and well-being.

---

## ✨ Features  
- 🔎 **Abnormality Detection** – AI-powered algorithms analyze menstrual patterns to detect irregular cycles and alert users.  
- 📅 **Cycle & Symptom Tracking** – Log cycle details, symptoms, and health data with AI-driven predictions and ovulation alerts.  
- 💡 **Personalized Health Insights** – Tailored diet, exercise, and lifestyle recommendations for better menstrual health.
- 🔐 **Data Security & Privacy** – Compliant with **PDPA** and global data protection regulations to safeguard user information.  
### Optionally, 
- 🩺 **Teleconsultations** – Secure, encrypted online doctor consultations for professional advice.  
- 🛍️ **Sanitary Product Access** – Optional discreet ordering and delivery of sanitary products.  


---

## 🛠️ Tech Stack  
- **Frontend:** Flutter (cross-platform mobile development)  
- **Backend:** Django  
- **Database:** MySQL  
- **AI Models:** Python (machine learning for irregularity detection & predictions)  
- **Cloud Services:** Google Cloud Platform (GCP)  

---
   

## 📂 Project Structure  

```bash
MensaCare/
│
├── frontend/                # Flutter mobile app
│
├── backend/                 # ML + API code (server + model)
│   ├── venv/                # Python virtual environment
│   ├── dataset.csv          # dataset used for training
│   ├── train_model.py       # script for training ML model
│   ├── server.py            # FastAPI server for predictions
│   └── saved_models/        # trained models (.keras, .tflite etc.)
│
├── database/                # MySQL schemas and migrations
│
└── README.md                # Documentation and resources



