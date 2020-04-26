# heartbeat

A new Flutter application.

By using this app you can measure your blood measure per minute (Heart Beat)


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## DEMO VIDEO

<!-- ![app video gif](/readmefilecontent/appvideogif.gif) -->
<img src="./readmefilecontent/appvideogif.gif" width="250" height="400"/>

This is the working procedure of our app 

install and test yourself

# Concept

You’ve probably seen or know of devices that people clip to their fingers in hospitals that measure their heart rate, or smartwatches capable of measuring your heart rate. They all have one thing in common: They measure the heart rate with a technique called photoplethysmography.

### A photoplethysmogram (PPG) 
    is an optically obtained plethysmogram that can be used to detect blood volume changes in the microvascular bed of tissue. — Wikipedia

Shining a light into a blood irrigated tissue, we can measure the variability of reflected light and extract the variation of blood flow. As we all know, the blood flow is dependent on the heart rate, so we can calculate the heart rate using the blood flow variation.

![blood processing image](https://miro.medium.com/max/640/1*75e0L3AW_FG9bAb9AVnGzQ.jpeg)
 credit goes to - Afonso Raposo

So, in our application, we’ll shine the camera’s flash and measure the intensity reflected using the phone’s camera. More specifically, we’ll measure the average value of all the pixel’s intensity of the camera image. Then, if we cover the camera and flash with our finger, the intensity measured will vary with the blood flow.

Thank you 😍️😍️😍️


