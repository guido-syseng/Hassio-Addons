#!/usr/bin/with-contenv bashio
set -e
DEBUGGING=$(bashio::config 'debugging')
MUSIC_TEST=$(bashio::config 'music_test')
TTS_TEST=$(bashio::config 'tts_test')
CONFIG_WWW_SUBDIR=$(bashio::config 'config_www_subdir')
TTS_LANG=$(bashio::config 'tts_lang')
# sox sound parameters
parsoxda="$(echo "-V2")"
parsoxna="$(echo "-V1")"
parsoxdb="$(echo "-r 22050 -b 16 -e signed --endian little -t alsa stats")"
parsoxnb="$(echo "-r 22050 -b 16 -e signed --endian little -t alsa")"

urlencode() {
    # urlencode <string>

    old_lc_collate=${LC_COLLATE:-}
    LC_COLLATE=C
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:$i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done
    LC_COLLATE=$old_lc_collate
}

keyextract() {
    # keyextract <string> <key>

    local inp="${1}"
    local key="${2}"
    local out
    if [[ "$inp" == *"$key"* ]]; then
        post=${inp#*$key}  
        key=","
        ante=${post%%$key*}
        key="}"
        out=${ante%%$key*}
        out="$(echo  ${out} | xargs )"
    else
        out=""
    fi  
    printf "$out"
}

openport() {
    # openport <port> 

    local inp="${1}"
    local out
    (echo > /dev/tcp/localhost/$inp) > /dev/null 2>&1
    out=$?
    printf "$out"
}

checksubdir() {
    # checksubdir <subdir> 

    local inp="${1}"
    local out
    out=$(curl -s -o /dev/null -w "%{http_code}\n" "http://localhost:8123/local/"$inp)
    printf "$out"
}

#################################### Start bash ##########################################
bashio::log.info "Starting Notifier addon..."

# test subdir
dir="$(echo "${CONFIG_WWW_SUBDIR//null/}")"
dir="$(echo  ${dir} | xargs )"
if [[ ${#dir} -gt 0 ]]; then
    if [[ ${dir: 0: 1} == "/" ]]; then dir=${dir: 1}; fi
    if [[ ${dir: -1} != "/" ]]; then  dir="${dir}/"; fi       
    code="$(echo "$(checksubdir "$dir")")"
    if [ ! ${code} -eq 403 ] && [ ! ${code} -eq 200 ]; then
        bashio::log.error "La subdirectory $dir che dovrebbe contenere i files audio .wav o .mp3 per le notifiche è inesistente."
        bashio::log.error "Correggere l'errore creando la subdirectory sotto /config/www ."
        dir=""
    fi
fi

if ( $MUSIC_TEST ); then
    # sound sample .mp3 audio
    bashio::log.info "Starting music test..."
    url="zgb.wav"  
    RC=0
    if ( $DEBUGGING ); then
        (play -q $parsoxda -v 0.2 $url $parsoxdb) || RC=$?
    else
        (play -q $parsoxna -v 0.2 $url $parsoxnb) || RC=$?
    fi
    if [[ $RC -gt 0 ]]; then
        bashio::log.error "Invalid audio" 
    else 
        bashio::log.info "Playing executed"
    fi
fi

# test picotts installed & active
prt=59126
queryport="$(echo "$(openport "$prt")")"
if [[ ${queryport} -gt 0 ]]; then
    bashio::log.error "The Hass.io PicoTTS addon is not installed and active." 
    bashio::log.error "Consequently, the Text To Speek functionality cannot be used and only the reporting function with .wav or .mp3 audio files is available." 
else
    # sound sample picotts
    if ( $TTS_TEST ); then
        sleep 2
        bashio::log.info "Starting tts test..."
        dh=$(date '+%H');
        dm=$(date '+%M');
        caldatint="Pico TTS Demo  $dh   $dm"
        message="$(echo "$caldatint")"
        encomessage="$(echo "$(urlencode "$message")")"
        url="-t wav http://localhost:59126/speak?lang=$TTS_LANG&text=$encomessage"
        RC=0
        if ( $DEBUGGING ); then 
            (play -q $parsoxda -v 0.2 $url $parsoxdb) || RC=$?
        else
            (play -q $parsoxna -v 0.2 $url $parsoxnb) || RC=$?
        fi
        if [[ $RC -gt 0 ]]; then
            bashio::log.error "Invalid tts" 
        else 
            bashio::log.info "Tts executed"
        fi 
    fi
fi

######################## Read from STDIN one notify for one input #######################

if ( $DEBUGGING ); then 
    bashio::log.info "Notifier is waiting for commands..."
fi
while read -r input; do
    input="$(echo "$input" | jq --raw-output '.')"
    if ( $DEBUGGING ); then 
        bashio::log.info "Notifier is receiving the command: $input"
    fi
    input="$(echo "${input//\"/}")"
    input="$(echo "${input//null/}")"
    #volume="$(echo "$input" | jq '.volume')"
    volume="$(echo "$(keyextract "$input" "volume:")")"
    parv=1
    if [ ${#volume} -gt 0 ]; then 
        parv="$(echo "scale=2 ; $volume / 100" | bc)"
    fi
    #message="$(echo "$input" | jq '.message')"
    message="$(echo "$(keyextract "$input" "message:")")"
    encomessage="$(echo "$(urlencode "$message")")"
    #music="$(echo "$input" | jq '.music')"
    music="$(echo "$(keyextract "$input" "music:")")"
    if [[ ${#music} -gt 0 ]]; then
        url="http://localhost:8123/local/$dir$music"
        RC=0
        if ( $DEBUGGING ); then 
            (play -q $parsoxda -v $parv $url $parsoxdb) || RC=$?
        else
            (play -q $parsoxna -v $parv $url $parsoxnb) || RC=$?
        fi
        if [[ $RC -gt 0 ]]; then
            bashio::log.error "Invalid audio" 
        else 
            bashio::log.info "Playing executed"
        fi  
    elif [[ ${#encomessage} -gt 0 ]]; then
        if [[ ${queryport} -gt 0 ]]; then
            bashio::log.error "Parameters error"
        else 
            url="-t wav http://localhost:59126/speak?lang=$TTS_LANG&text=$encomessage"
            RC=0
            if ( $DEBUGGING ); then 
                (play -q $parsoxda -v $parv $url $parsoxdb) || RC=$?
            else
                (play -q $parsoxna -v $parv $url $parsoxnb) || RC=$?
            fi
            if [[ $RC -gt 0 ]]; then
                bashio::log.error "Invalid tts" 
            else 
                bashio::log.info "Tts executed"
            fi  
        fi
    else
        bashio::log.error "Parameters error"
    fi 
done
