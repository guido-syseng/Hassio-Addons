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

From the Info panel go to **Configuration**:
1. From Options select **tts_lang** to one of the languages supported by Pico Tts (preferably previously installed)
2. From Audio select **output** from `Default` to `Built-in Audio Stereo` 
3. Select optionally a subdirectory name for audio mp3 or wav notifications via the **config_www_subdir**.
4. Mark optionally **music_test** or -> **tts_test** for immediate testing, select **debugging**  for extended error messages for problem determination

Notes:

1. Tts requires `Picotts addon` [ https://github.com/Poeschl/Hassio-Addons ] for tts use in notifications.
2. For audio .mp3 or .wav notifications, you `must` create under /config the /www directory and insert there your audio messages (use samba addon for example)
3. Please insert the same directory in configuration.yaml, it's not strictly necessary, but so you can view and play for test your messages in the standard `Multimedia browser`

```yaml
homeassistant:
  media_dirs:
    media: /media
    notifier: /config/www
```

## Automations configuration ##

Estabilish events with trigger, the addon acts in the **action** key

```yaml
  action:
    - service: hassio.addon_stdin
      data: 
        addon: aaaannnn_notifier
        input: 
          volume: 18
          music: "music.mp3"
          message: "Tts message alternative to audio music"
```

Explaination of each line 

`service: hassio.addon_stdin`: 
Use hassio.addon_stdin service to send data over STDIN to an add-on.

`data.addon: aaaannnn_notifier`: 
Tells the service to send the command to this add-on, aaaannnn_notifier is the host name of the notifier addon, **read Hostname in the Info page** of the Notifier.

`data.input: volume`: 
Alias name created in the add-on  for the volumeumeume configuration, that estabilish the music intensity in percent of the audio message notified, valid for each kind of message, music .wav/,mp3 or vocal tts pico.

**Subsequents Aliases names `music` and `message`** are alternatives to activate music or tts, if both are presents it's used the music alias

`data.input: music`: 
Alias name for indication of file name (.Wav or .mp3) with the music to send. 

`data.input: message`: 
Alias name created for indication of the message to vocally trasmit for advise or for information (picotts addon prerequisite)

Configuration examples

**1.** To use the Notifier with audio go to **Setup** -> **Automations** and then create audio .Wav or .mp3 notification, following the example:

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
        addon: aaaannnn_notifier
        input: 
          volume: 18
          music: "music.mp3"
mode: single
```
**2.** To use the Notifier with tts go to **Setup** -> **Automations** and then create tts notification, following the example:

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
        addon: aaaannnn_notifier
        input: 
          volume: 18
          message: "Congratulations"
mode: single
```
