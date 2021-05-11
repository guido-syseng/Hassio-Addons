#!/usr/bin/with-contenv bashio
set -e
DEBUGGING=$(bashio::config 'debugging')
MUSIC_TEST=$(bashio::config 'music_test')
TTS_TEST=$(bashio::config 'tts_test')
CONFIG_WWW_SUBDIR=$(bashio::config 'config_www_subdir')
TTS_LANG=$(bashio::config 'tts_lang')

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
    url="zgb.mp3"  
    RC=0
    if ( $DEBUGGING ); then 
        (play -q -v 0.2 $url -t alsa) > /dev/null 2>&1 || RC=$?
    else
        (play -q -v 0.2 $url -t alsa) || RC=$?
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
    bashio::log.error "L'addon di Hass.io PicoTTS non è installato e attivo." 
    bashio::log.error "Di conseguenza la funzionalità Text To Speek non può essere utilizzata ed è disponibile la sola funzione di segnalazione con files audio .wav o .mp3 ." 
else
    # sound sample picotts
    if ( $TTS_TEST ); then
        sleep 2
        bashio::log.info "Starting tts test..."
        dh=$(date '+%H');
        dm=$(date '+%M');
        caldatint="Pico TTS Demo  $dh   $dm"
        text="$(echo "$caldatint")"
        encotext="$(echo "$(urlencode "$text")")"
        url="-t wav http://localhost:59126/speak?lang=$TTS_LANG&text=$encotext"
        RC=0
        if ( $DEBUGGING ); then 
            (play -q -v 0.2 $url -t alsa) > /dev/null 2>&1 || RC=$?
        else
            (play -q -v 0.2 $url -t alsa) || RC=$?
        fi
        if [[ $RC -gt 0 ]]; then
            bashio::log.error "Invalid tts" 
        else 
            bashio::log.info "Tts executed"
        fi 
    fi
fi

######################## Read from STDIN one notify for one input #######################

while read -r input; do 
    input="$(echo "${input//\"/}")"
    input="$(echo "${input//null/}")"
    vol="$(echo "$(keyextract "$input" "vol:")")"
    if [ ${#vol} -gt 0 ]; then 
        parv="$(echo "scale=2 ; $vol / 100" | bc)"
    else
        parv=1
    fi
    text="$(echo "$(keyextract "$input" "text:")")"
    encotext="$(echo "$(urlencode "$text")")"
    sound="$(echo "$(keyextract "$input" "sound:")")"
    if [[ ${#sound} -gt 0 ]]; then
        url="http://localhost:8123/local/$dir$sound"
        RC=0
        if ( $DEBUGGING ); then 
            (play -q -v $parv $url -t alsa) > /dev/null 2>&1 || RC=$?
        else
            (play -q -v $parv $url -t alsa) || RC=$?
        fi
        if [[ $RC -gt 0 ]]; then
            bashio::log.error "Invalid audio" 
        else 
            bashio::log.info "Playing executed"
        fi  
    elif [[ ${#encotext} -gt 0 ]]; then
        if [[ ${queryport} -gt 0 ]]; then
            bashio::log.error "Parameters error..."
        else 
            url="-t wav http://localhost:59126/speak?lang=$TTS_LANG&text=$encotext"
            RC=0
            if ( $DEBUGGING ); then 
                (play -q -v $parv $url -t alsa) > /dev/null 2>&1 || RC=$?
            else
                (play -q -v $parv $url -t alsa) || RC=$?
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