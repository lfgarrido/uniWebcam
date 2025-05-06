# Delphi + uniGUI Webcam Capture App

This sample project demonstrates how to manage and capture webcam input directly from the browser using **Delphi** and **uniGUI**, **without any third-party components**. All functionality is implemented using native components, standard HTML5 APIs, and JavaScript.

---

## 📦 Features

- ✅ **Multiple webcam support**
- 📸 **Snapshot capture**
- 🖋 **Capture with watermark overlay**
- ✂️ **Capture with selection crop tool**
- 🎛 **Camera selection via combo box (auto-detects webcams)**

---

## 🛠 Technology Stack

- **Delphi** (Object Pascal)
- **uniGUI Framework**
- **HTML5 getUserMedia() API** via browser-side JavaScript
- **Canvas and video** elements for rendering
- **TUniHTMLFrame** to host dynamic browser-side code
- **TUniImage** to show captured previews
- **TUniComboBox** to list and switch webcams
- **No third-party components required**

---

## 🧠 Technical Overview

### 🎥 Camera Access

Uses JavaScript’s `navigator.mediaDevices.enumerateDevices()` and `getUserMedia()` to:

- Detect connected video input devices
- Access and stream selected webcam to a `<video>` element
- Send list of devices back to Delphi using `ajaxRequest()`

### 🧩 Component Roles

- `TUniHTMLFrame` (`htmlCamFrame`) embeds the HTML `<video>` and `<canvas>` elements, plus JS logic for capturing and streaming.
- `TUniImage` (`imgPreview`) displays captured images (from the canvas).
- `TUniComboBox` (`cmbWebcam`) is dynamically populated with available camera labels and used to switch devices.
- Buttons (`btnCapture`, `btnStop`, etc.) trigger JavaScript functions via `UniSession.AddJS(...)`.

### ✂️ Crop + Selection Tool

- Uses [Jcrop](https://github.com/tapmodo/Jcrop) via JavaScript (no external files needed; embedded in files folder).
- Selected crop coordinates are sent to Delphi via `ajaxRequest(...)`.
- Delphi reads, decodes, and crops the image using `TPngImage`, `TBitmap`, and native GDI canvas drawing.

### 🖋 Watermarking

Drawn directly on canvas via JavaScript before sending image data to the server.

---

## 🚀 How It Works (Flow)

1. On `UniFormShow`, JavaScript runs and queries available cameras.
2. JS sends camera list to Delphi via `ajaxRequest`.
3. Delphi fills `TUniComboBox` with camera labels.
4. When user selects a camera, Delphi tells JS to switch the camera stream.
5. User can:
   - Capture a snapshot
   - Capture with watermark
   - Capture and crop via selection
6. The captured image is sent from browser to Delphi via base64 and rendered in the `TUniImage`.

---

## 📂 File Organization

- `Main.pas/.dfm` – Contains all form logic and UI elements.
- No external files required. Output images are saved under `files/images/`.

---

## 📌 Requirements

- Delphi (any version that supports uniGUI)
- uniGUI installed
- Modern web browser (Chrome, Edge, Firefox, etc.)

---

## 🔒 Permissions

- Ensure browser permissions for camera access are granted.
- Camera enumeration and video capture rely on `https://` or `localhost` for security.

---

## 📜 License

This project is open for learning and adaptation. You are free to use and modify it as needed.

---

## 🙌 Credits

Created using **Delphi + uniGUI**, leveraging modern browser APIs.
