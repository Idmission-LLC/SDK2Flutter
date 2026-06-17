## 11.1.7

**Android native SDK: 11.1.07.2.23 — Released 28 April 2026**
**iOS native SDK: 11.1.7.2.4**

### Android
* Added customizable properties for enhanced UI flexibility
* Updated DocumentDetect model with ID back-side prediction for improved document recognition
* Reduced overall SDK package size
* Implemented a timeout timer during capture to streamline user workflows
* Aligned prompt and error messaging on ID and Selfie screens with iOS behaviour
* Added support for separate front and back ID capture flow for improved control and user experience

### iOS
* IDentityMediumSDK2.0 version 11.1.7.2.4

### Flutter wrapper
* Plugin now installable directly via git reference in pubspec.yaml — no zip download required
* Fixed AndroidManifest theme merge: removed app-level theme override from plugin manifest so consumer app themes are no longer affected
* Added integration guide (INTEGRATION_GUIDE.md) covering Android and iOS setup end-to-end
