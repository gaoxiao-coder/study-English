let currentAudio = null;
let currentSpeechUtterance = null;

function playAudioFromBase64(base64Audio) {
  try {
    if (currentAudio) {
      currentAudio.pause();
      currentAudio = null;
    }

    const audio = new Audio(base64Audio);
    
    audio.onended = function() {
      currentAudio = null;
      if (window.flutterAudioCompletion) {
        window.flutterAudioCompletion();
      }
    };
    
    audio.onerror = function() {
      currentAudio = null;
      if (window.flutterAudioError) {
        window.flutterAudioError();
      }
    };
    
    audio.play().then(function() {
      currentAudio = audio;
    }).catch(function(error) {
      console.error('音频播放失败:', error);
      if (window.flutterAudioError) {
        window.flutterAudioError();
      }
    });
  } catch (error) {
    console.error('创建音频失败:', error);
    if (window.flutterAudioError) {
      window.flutterAudioError();
    }
  }
}

function stopAudio() {
  try {
    if (currentAudio) {
      currentAudio.pause();
      currentAudio = null;
    }
  } catch (error) {
    console.error('停止音频失败:', error);
  }
}

function speakWithWebSpeech(text, accent) {
  try {
    if (!('speechSynthesis' in window)) {
      console.error('浏览器不支持Web Speech API');
      if (window.flutterAudioError) {
        window.flutterAudioError();
      }
      return false;
    }

    window.speechSynthesis.cancel();

    const utterance = new SpeechSynthesisUtterance(text);
    
    if (accent === 'british') {
      utterance.lang = 'en-GB';
    } else {
      utterance.lang = 'en-US';
    }
    
    utterance.rate = 0.9;
    utterance.pitch = 1.0;
    utterance.volume = 1.0;
    
    utterance.onstart = function() {
      currentSpeechUtterance = utterance;
      if (window.flutterAudioCompletion) {
        window.flutterAudioCompletion();
      }
    };
    
    utterance.onend = function() {
      currentSpeechUtterance = null;
      if (window.flutterAudioCompletion) {
        window.flutterAudioCompletion();
      }
    };
    
    utterance.onerror = function(event) {
      currentSpeechUtterance = null;
      console.error('语音合成错误:', event);
      if (window.flutterAudioError) {
        window.flutterAudioError();
      }
    };
    
    window.speechSynthesis.speak(utterance);
    return true;
  } catch (error) {
    console.error('Web Speech API调用失败:', error);
    if (window.flutterAudioError) {
      window.flutterAudioError();
    }
    return false;
  }
}

function stopWebSpeech() {
  try {
    if ('speechSynthesis' in window) {
      window.speechSynthesis.cancel();
    }
  } catch (error) {
    console.error('停止语音失败:', error);
  }
}
