# AI-Powered Menstrual Health App-MENSACARE

## 📌 Overview  
**MensaCare** App is an **AI-powered** menstrual health management tool. It studies each user’s cycle data, learns from it, and detects unusual patterns that may indicate irregularities. The app analyzes about three months of cycle patterns, provides information on abnormalities, and gives personalized recommendations to help users maintain their health.

It also offers optional features such as secure health advice, private teleconsultations, and sanitary product ordering for extra convenience and support.MensaCare keeps user data safe through strong encryption and privacy protection. By combining AI, healthcare support, and data security, the app offers a modern and comprehensive way to manage menstrual health, helping women understand their bodies better and take timely action.


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
## 🩺 Feature Comparison

The table below compares popular existing apps with MensaCare, highlighting the features that set our app apart:

| **Feature**                            | **Existing Apps** | **MensaCare App** |
|---------------------------------------|-------------------|-------------------|
| Track period dates                    | ✅ Yes            | ✅ Yes            |
| Track symptoms                        | ✅ Yes            | ✅ Yes            |
| Fertility window prediction           | ✅ Yes            | ✅ Yes            |
| User-friendly interface               | ✅ Yes            | ✅ Yes            |
| AI-powered abnormality detection      | ❌ No             | ✅ Yes            |
| Personalized health recommendations   | ❌ No             | ✅ Yes            |
| 3-month cycle pattern analysis        | ❌ No             | ✅ Yes            |
| Private teleconsultations             | ❌ No             | ✅ Yes            |
| Sanitary product ordering & delivery  | ❌ No             | ✅ Yes            |


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



