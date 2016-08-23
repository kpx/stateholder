var Walkie = (function() {
   navigator.getUserMedia = 
    (navigator.getUserMedia || 
     navigator.webkitGetUserMedia ||
     navigator.mozGetUserMedia || 
     navigator.msGetUserMedia);

  var AudioContext = 
    (window.AudioContext || 
     window.webkitAudioContext || 
     window.mozAudioContext || 
     window.oAudioContext || 
     window.msAudioContext);
  
  var socket = new WebSocket("ws://localhost:8080/ws");
  socket.binaryType = 'arraybuffer';
  
  var sending = false;
  var source;
  
  var bufferSize = 2048;

  var recordingContext = new AudioContext();
  var speakerContext = new AudioContext();

  var initAudioCache = false;
  var audioCache = [];
  var nextTime = 0;

  var onopen = function() {
    if (navigator.getUserMedia) {
      navigator.getUserMedia(
        {audio:true}, 
        getUserMediaSuccess, 
        function(e) {
          alert('Error capturing audio.');
        });
    };
  };
  
  var onmessage = function(audioMessage) {
    if (!sending) {
      playAudioMessage(audioMessage.data)
    }
  }

  var playAudioMessage = function(data) {
    var array = new Float32Array(data);
    var audioBuffer = speakerContext.createBuffer(1, bufferSize, 44100);
    
    audioBuffer.copyToChannel(array, 0);
    audioCache.push(audioBuffer);

    if ((initAudioCache === true) || ((initAudioCache === false) && (audioCache.length > 5))) { 
      initAudioCache = true;
      playCache(audioCache);
    }
  }

  var playCache = function (cache) {
    while (cache.length) {
      var buffer = cache.shift();
      var source = speakerContext.createBufferSource();
      source.buffer = buffer;
      source.connect(speakerContext.destination);
      if (nextTime == 0) {
        nextTime = speakerContext.currentTime + 0.05;  
      }
      source.start(nextTime);
      nextTime += source.buffer.duration;  
    }
  };

  var getUserMediaSuccess = function(event) {
  	  var audioInput = recordingContext.createMediaStreamSource(event);
      var scriptNode = recordingContext.createScriptProcessor(bufferSize, 1, 1);

      scriptNode.onaudioprocess = function(audioProcessEvent){
        if(sending) {
          var channelData = audioProcessEvent.inputBuffer.getChannelData(0);
          socket.send(channelData);
        }
      }

      audioInput.connect(scriptNode)
      scriptNode.connect(recordingContext.destination);
  }

  socket.onmessage = onmessage;
  socket.onopen = onopen;

  return {
    join: function() {
      socket.send("join");
    },
    startSending: function() {
      sending = true;
    },
    stopSending: function() {
      sending = false;
    }

  }
})();