# MediSync

![CI](https://github.com/leandromedina0218-del/medisync/actions/workflows/ci.yml/badge.svg)

> Full-stack health platform — Flutter mobile app for patients and web panel
> for laboratories and doctors. Built with Flutter, Firebase and Gemini AI.

## Architecture
- `medisync_core` — Domain layer (Dart pure, framework-agnostic)
- `medisync_app` — Patient mobile app (Flutter)
- `medisync_web` — Lab & doctor web panel (Flutter Web)
- `functions` — Cloud Functions (TypeScript)

## 📐 System Design & Clean Architecture
El proyecto implementa los principios de **Clean Architecture** y **Domain-Driven Design (DDD)** para garantizar la testabilidad, el desacoplamiento y el mantenimiento a largo plazo:
- **Capa de Dominio (Domain):** Entidades puras del negocio clínico, objetos de valor y contratos de repositorios libres de dependencias externas.
- **Capa de Datos (Data):** Gestión de fuentes de datos remotas y locales, mapeo de modelos y comunicación con servicios en la nube.
- **Capa de Presentación (Presentation):** Gestión de estados reactiva para desacoplar la interfaz de usuario de la lógica de control.

## Tech stack
Flutter · Firebase Auth · Firestore · Cloud Functions · Gemini API · Riverpod · Clean Architecture

## Status
🚧 In active development