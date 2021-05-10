# Home Assistant Add-on: Notifier

Notifier for Home Assistant.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

## About

How to play sounds and use Tts through a 3.5mm audio jack?

For Home Assistant notifications with use of 3.5mm audio jack and loudspeaker directly connected to Rasberry, this add-on install Sox & Pulse Audio (Registered Trademarks).

Clarification: only notifications for this addon, no no playlists, no multimedial server for audio and video. The configuration of the player and of tts is only internal to addon, no addition of definitions.

I wanted to connect directly a 3,5" jack between my Raspberry and a loudspeacker to receive notification for events, with option to hear a sound or a speech message and to estabilish the corrent intensity of each audio event.
I updated and improved the **Audio Player**, a creation  of **Dingle - Daniel Dingemanse** and installed also the addon **TtsPico** of **Poeschl** for use a good offline tts, in alternative to Google Tts.
I installed **Samba**  too for creation of /config/www repository & uploading of sounds and **Configurator** for seeing and tuning the necessary .yaml files.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
