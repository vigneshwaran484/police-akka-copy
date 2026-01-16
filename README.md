# Police Akka

Police Akka is a digital public-safety application designed as a prototype to improve communication between citizens and law enforcement. The system enables citizens to report incidents with digital evidence and allows police officers to monitor, review, and respond through a centralized dashboard.

This project is built for academic, demonstration, and prototype purposes.

---

## Overview

Police Akka consists of two main components:

1. Citizen Mobile Application (Flutter)
2. Police Command Dashboard (Flutter Web)

The platform focuses on:
- Faster incident reporting
- Secure evidence storage
- Real-time visibility for police
- Assisted guidance through AI chat

---

## System Architecture

The application uses a hybrid backend approach:

- Authentication:
  - Firebase Phone Authentication (OTP) for citizen login
  - Supabase Authentication (Email/Password) for police dashboard

- Database:
  - Supabase PostgreSQL for structured data storage

- Storage:
  - Supabase Storage for images, videos, and audio evidence

- AI:
  - Groq API for chatbot-based guidance and assistance

- Real-time Updates:
  - Supabase Realtime for SOS alerts and incident updates

---

## Citizen Mobile App (police_app)

Built using Flutter for Android.

### Features

- Phone Number Login:
  - OTP-based authentication using Firebase
  - Aadhaar is not required to ensure ease of access

- SOS Alerts:
  - One-tap SOS sending live location data
  - Alerts are instantly visible on the police dashboard

- Incident Reporting:
  - Submit incident details with description and location
  - Attach photos, videos, or audio as evidence

- Location Enforcement:
  - Location services must be enabled for critical actions

- AI Chat Assistant:
  - Provides general guidance and app-related help
  - Does not provide legal advice

- Citizen Profile:
  - Users can add profile information and profile photo

---

## Police Dashboard (police_dashboard)

Built using Flutter Web for wide-screen monitoring.

### Features

- Live SOS Monitoring:
  - View active SOS alerts in real time
  - Mark alerts as resolved

- Incident Management:
  - View incidents sorted by severity
  - Access full incident details and evidence

- Previous Evidence Archive:
  - Store and retrieve historical evidence
  - Supports photo, video, and audio playback

- Citizen Records:
  - View registered citizen information

- Query Management:
  - Respond to citizen queries through the dashboard

- AI Chat Logs:
  - Review AI chatbot interactions for reference

---

## Technology Stack

Frontend:
- Flutter (Dart)
- Flutter Web

Backend:
- Supabase (PostgreSQL)
- Supabase Realtime
- Supabase Storage

Authentication:
- Firebase Authentication (Phone OTP)
- Supabase Authentication

AI:
- Groq API

Maps and Location:
- Geolocator
- Geocoding
- Google Maps API

---

## Setup Instructions

### Prerequisites

- Flutter SDK (3.x or later)
- Firebase Project with Phone Authentication enabled
- Supabase Project with database tables and storage buckets
- Groq API Key

---

### Installation

1. Clone the repository:
```bash
git clone https://github.com/vigneshwaran484/police-akka-copy.git
```
2.Configure Supabase:

Add your Supabase URL and Anon Key in the configuration files

Execute the provided SQL scripts in Supabase SQL Editor

Configure Row Level Security (RLS) policies as required

3.Configure Firebase:

Enable Phone Authentication

Add google-services.json to:
police_app/android/app/

4.Run the Citizen App:
```bash
cd police_app
flutter pub get
flutter run
```
5.Run the Police Dashboard:
```bash
cd police_dashboard
flutter pub get
flutter run -d chrome
```

