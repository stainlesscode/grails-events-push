<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
    <r:require modules="jquery, grailsEvents"/>
    <meta name='layout' content='main'/>
    <r:script>
    $(document).ready(function () {

      /*
       Register a grailsEvents handler for this window, constructor can take a root URL,
       a path to event-bus servlet and options. There are sensible defaults for each argument
       */
      window.grailsEvents = new grails.Events("${createLink(uri: '')}", {logLevel:"debug", binary:true, transport:'websocket'});

       window.grailsEvents.on("afterInsert", function (data) {
          $("#messages").append("<div>" + $.stringifyJSON(data) + "</div>");
        }, {});

      /*
       Add a listener for the topic from first input + a listener on afterInsert topic.
       */
      function subscribe() {
        /*
         Adding a listener requires a topic to listen and a function handler to react, data should be a JSON object
         */
        grailsEvents.on($('#topic').val(), function (data) {
          $("#messages").append("<div>" + data.message + "</div>")
        }, {});
      }

      function getKeyCode(ev) {
        if (window.event) return window.event.keyCode;
        return ev.keyCode;
      }

      function dataURItoArrayBuffer(dataURI) {
            var uint = new Uint8Array(dataURI.length);
            for (var i = 0, j = dataURI.length; i < j; ++i) {
                uint[i] = dataURI.charCodeAt(i);
            }
            return uint.buffer;
        }

      function dataURIArrayBufferToUint(dataURI) {
            dataURI = String.fromCharCode.apply(null, new Uint8Array(dataURI));
            var byteString = atob(dataURI.split(',')[1]);

            // separate out the mime component
            var mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0]

            // write the bytes of the string to an ArrayBuffer
            var ab = new ArrayBuffer(byteString.length);
            var ia = new Uint8Array(ab);
            for (var i = 0; i < byteString.length; i++) {
                ia[i] = byteString.charCodeAt(i);
            }
            return ia;
        }

      function connect() {
        $('#phrase').val('');
        $('#sendMessage').attr('class', '');
        $('#phrase').focus();
        subscribe();
        $('#connect').val("Switch transport");
      }

        //Another stupid sample
         window.URL = window.URL ||
            window.webkitURL        ||
            window.mozURL           ||
            window.msURL            ||
            window.oURL;
         navigator.getUserMedia  = navigator.getUserMedia ||
            navigator.webkitGetUserMedia ||
            navigator.mozGetUserMedia ||
            navigator.msGetUserMedia;
         window.MediaSource = window.MediaSource || window.WebKitMediaSource;
        if (!!!window.MediaSource) {
          alert('MediaSource API is not available');
        }
        if (!window.BlobBuilder && window.WebKitBlobBuilder){
                window.BlobBuilder = window.WebKitBlobBuilder;
            }
        var startTime = 0;
        var video = document.querySelector('video');
         var canvas = $("#canvas");
         var ctx = canvas.get()[0].getContext('2d');
         var canvas2 = $("#canvas2");
         var ctx2 = canvas2.get()[0].getContext('2d');


      function renderAB(_stream){
        requestAnimationFrame(function () {

         var img = new Image();
                    img.onload = function () {
                        ctx2.drawImage(this, 0, 0, 320, 240);
                    };
                    img.src = String.fromCharCode.apply(null, new Uint8Array(_stream));

            var elapsed = new Date().getTime()-startTime;
            console.log("process time:"+elapsed);
        });
      }

      $('#anotherReceive').change(function (event) {
          if($(this).attr('checked')){
            grailsEvents.on($('#topic').val(), function (_stream) {
                if(_stream instanceof ArrayBuffer){
                  renderAB(_stream);
                }else{
                  target.src = _stream;
                }
            }, {});

        }
      });

    function captureVideo(){
        startTime = new Date().getTime();
        ctx.drawImage(video, 0, 0, 320, 240);
            var data = canvas.get()[0].toDataURL('image/jpeg', 1.0);
            var ab = dataURItoArrayBuffer(data);
            //var ab = ctx.getImageData(0,0,320,240).data.buffer;
            grailsEvents.send($('#to').val(), ab);
    }

      $('#another').change(function (event) {

        if(!$(this).attr('checked')){
            clearTimeout(videoTimer);
            video.pause();
            if(localMediaStream){
                localMediaStream.stop();
            }
            URL.revokeObjectURL(video.src);
            return;
        }

         var onFailSoHard = function(e) {
           console.log('Reeeejected!', e);
         };

          if (navigator.getUserMedia) {
            navigator.getUserMedia({video: true}, function(stream) {
                window.localMediaStream = stream;
                video.src = URL.createObjectURL(stream);
            }, onFailSoHard);
          }

           window.videoTimer = setInterval(
                function () {
                captureVideo();
            }, 250);

      });

      $('#connect').click(function (event) {
        if ($('#topic').val() == '') {
          alert("Please enter a PubSub topic to subscribe");
          return;
        }
        connect();
      });

      $('#topic').keyup(function (event) {
        $('#sendMessage').attr('class', 'hidden');
        var keyc = getKeyCode(event);
        if (keyc == 13 || keyc == 10) {
          connect();
          return false;
        }
      });

      $('#phrase').attr('autocomplete', 'OFF');
      $('#phrase').keyup(function (event) {
        var keyc = getKeyCode(event);
        if (keyc == 13 || keyc == 10) {
          /*
           Sending an event to server (will be also to local in a future release).
           Requires the event topic to be used, and a JSON object.
           */

          grailsEvents.send($('#topic').val(), {message:$('#phrase').val()});
          $('#phrase').val('');
          return false;
        }
        return true;
      });

      $('#send_message').click(function (event) {
        if ($('#topic').val() == '') {
          alert("Please enter a message to publish");
          return;
        }
        /*
         Same sending method than above but using click button.
         */
         console.log($('#topic').val());
        grailsEvents.send($('#topic').val(), {message:$('#phrase').val()});
        $('#phrase').val('');
        return false;
      });


      $('#topic').focus();
    });
    </r:script>
</head>

<body>
<h2>Select topic to subscribe</h2>

<div id='pubsub'>
    <input id='topic' type='text' value="sampleBro-1"/>
</div>

<input id='connect' class='button' type='submit' name='connect' value='Connect'/>
<br/>

<h2 id="s_h" class='hidden'>Publish Topic</h2>

<div id='sendMessage' class='hidden'>
    <input id='phrase' type='text'/>
    <input id='send_message' class='button' type='submit' name='Publish' value='Publish Message'/>

    <p>Another stupid sample : <input id='another' class='button' type='checkbox'/>

    <p>Receive : <input id='anotherReceive' class='button' type='checkbox'/>
        Broadcast To : <input id='to' type='text' value='sampleBro-1'/></p>
</div>
<br/>

<h2>Real Time PubSub Update</h2>
<ul id='messages'></ul>

<div>
    <video id="live" width="320" height="240" autoplay></video>
    <img id="target" style="display: inline;"/>
    <canvas width="320" id="canvas2" height="240"
            style="display: inline;" />

    <div style='visibility:hidden;width:0; height:0;'><canvas width="320" id="canvas" height="240"
                                                              style="display: inline;"></canvas>
    </div>
</div>

</body>
</html>