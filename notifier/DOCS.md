# Home Assistant Add-on: Notifier

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
2. Find the *Notifier addon* and click it.
3. Click on the *INSTALL* button.

## How to use

The add-on has a couple of options available. To get the add-on running:

1. Start the add-on.
2. Have some patience and wait a couple of minutes.

Select your language for Text to to Speeck via the **Configuration** -> **Tts_lang**.
Select optionally a subdirectory name for audio mp3 or wav notifications via the **Configuration** -> **config_www_subdir**.
Mark optionally **Configuration** -> **music_test** or -> **tts_test** for immediate testing

Notes:

1. Tts requires `Picotts addon` for tts use in notifications.
2. For audio .mp3 or .wav notifications, you `must` create under /config the /www directory and insert there your audio messages (use samba addon for example)
3. Please insert the same directory in configuration.yaml, it's not strictly necessary, but so you can view and play for test your messages in the standard `Multimedia browser`

```yaml
homeassistant:
  media_dirs:
    media: /media
    notifier: /config/www
```

## Automations configuration ##

Estabilish events with triggere, the addon acts in the **action** key

```yaml
  action:
    - service: hassio.addon_stdin
      data: 
        addon: local_notifier
        input: 
          vol: 18
          sound: "music.mp3"
          text: "Tts text alternative to audio sound"
```

Each line explained

`service: hassio.addon_stdin`: 
Use hassio.addon_stdin service to send data over STDIN to an add-on.

`data.addon: local_notifier`: 
Tells the service to send the command to this add-on, local_notifier is the local name of the notifier addon.

`data.input: vol`: 
Alias name created for the volume in the add-on configuration, that estabilish the sound intensity in percent of the audio message notified, valid for each message, sound .wav/,mp3 or vocal tts pico.

**Subsequents Aliases names `sound` and `text`** are alternatives to activate sound or tts, if both are presents it's used the sound alias

`data.input: sound`: 
Alias name for indication of file name (.naw or .mp3) with the sound to send. 

`data.input: text`: 
Alias name created for indication of the text to vocally trasmit for advise or for information (picotts addon prerequisite)

Configuration examples

**1.** To use the Notifier with audio go to **Setup** -> **Automations** and create audio .mp3/.wav notification, follow the example:

```yaml
- id: 'nnnnnnnnnn'
  alias: Send audio message
  description: ''
  trigger:
  - platform: homeassistant
    event: start
  condition: []
  action:
    - service: hassio.addon_stdin
      data: 
        addon: local_notifier
        input: 
          vol: 18
          sound: "music.mp3"
mode: single
```
**2.** To use the Notifier with tts go to **Setup** -> **Automations** and create tts notification, follow the example:

```yaml
- id: 'nnnnnnnnnn'
  alias: Send tts message
  description: ''
  trigger:
  - platform: homeassistant
    event: start
  condition: []
  action:
    - service: hassio.addon_stdin
      data: 
        addon: local_notifier
        input: 
          vol: 18
          text: "Congratulations"
mode: single
```