# 🏥 PillMatrix – Digital Healthcare Workflow Platform

PillMatrix is a **hackathon-built prototype** developed during the **VIT × Google Gemini Prompt-a-thon**.  
It explores how cloud services, AI assistance, and role-based workflows can be used to digitize and streamline healthcare coordination between doctors, patients, labs, and pharmacists.

This repository contains the **frontend marketing and interaction layer** of the PillMatrix system.

---

## 🎯 Project Context

Healthcare workflows are often fragmented and paper-based, leading to delays, miscommunication, and errors.

The goal of PillMatrix was to **conceptually demonstrate** a unified digital platform that:
- Digitizes prescriptions and lab requests
- Enables secure role-based access
- Improves patient engagement using reminders and AI assistance

> ⚠️ This project is a **prototype** created under hackathon time constraints and is not a certified medical system.

---

## 🧩 Scope of This Repository

This repository focuses on:
- Public-facing website
- Role-based workflow explanation
- UI for login and onboarding
- Feature and system visualization

Backend services (Firebase, AI, OCR) were implemented separately or partially during the hackathon.

---

## 🏗️ Project Structure

src/
├── components/
│ ├── Navbar.tsx # Responsive navigation header
│ └── Footer.tsx # Footer with navigation and links
├── pages/
│ ├── Home.tsx # Landing page
│ ├── HowItWorks.tsx # Role-based workflow explanation
│ ├── Features.tsx # Platform features
│ ├── Security.tsx # Conceptual security overview
│ ├── Contact.tsx # Contact & FAQ
│ └── Login.tsx # Role-based login UI
├── App.tsx # Routing and layout
├── main.tsx # React entry point
└── index.css # Global styles

---

## 👥 User Roles (Conceptual Design)

### 🩺 Doctor
- Access patient records via QR
- Create digital prescriptions
- Request lab tests digitally

### 🧑 Patient
- Share QR for consultations
- View prescriptions and lab reports
- Receive medication reminders

### 🧪 Lab Technician
- View assigned lab requests
- Upload reports to patient records

### 💊 Pharmacist
- View verified prescriptions
- Dispense medicines digitally

---

## 🤖 AI Integration (Prototype)

- **Gemini API:** Patient-facing chatbot for medicine and prescription-related queries  
- **OCR:** Experimental text extraction from uploaded medical documents  
  - Implemented as a **proof-of-concept**
  - Accuracy not production-grade

---

## 🛠️ Technologies Used

- **React 18**
- **TypeScript**
- **React Router v6**
- **Tailwind CSS**
- **Vite**
- **Firebase (Auth & Firestore – partial)**
- **Google Gemini API (prototype integration)**

---

## 🚀 Getting Started

### Prerequisites
- Node.js 16+

### Installation
```bash
npm install
npm run dev
```
The app runs at http://localhost:3000.

📌 Project Status

✅ UI and workflow modeling completed

✅ Role-based navigation implemented

⚠️ Backend logic partially implemented

⚠️ OCR and security rules are experimental

🧠 Learning Outcomes

Designing role-based systems

Healthcare workflow modeling

Hackathon-scale system architecture

Integrating AI responsibly

Building presentable technical prototypes

📄 Disclaimer

This project is a student-built hackathon prototype intended for learning and demonstration purposes only.
It is not a certified medical platform and should not be used in real clinical environments.

🔮 Future Improvements

Strengthen Firebase security rules

Improve OCR accuracy

Complete backend workflows

Add audit logs and role validation

Mobile app implementation

PillMatrix – Exploring digital healthcare through cloud systems and AI-assisted workflows.
## 🌐 Live Demo

The frontend prototype is publicly hosted for demonstration purposes:

🔗 **https://pillmatrix.netlify.app**

> Note: This hosted version represents the **UI and workflow demonstration** of the PillMatrix concept.  
> Backend integrations (authentication, data persistence, OCR accuracy, and security rules) are **partial or simulated** and were implemented within hackathon constraints.
