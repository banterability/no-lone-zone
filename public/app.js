var socketStatusEl = document.querySelector('#socket-status');
var phoneStatusEl = document.querySelector('#phone-status');
var socket = io();
socket.on('connect', function(){
  setSocketStatus('ok', 'ok');
});
socket.on('disconnect', function(){
  setSocketStatus('disconnected', 'bad');
});
socket.on('error', function(){
  setSocketStatus('error', 'bad');
});
socket.on('reconnecting', function(){
  setSocketStatus('reconnecting...', 'unknown');
});

var registerPhone = function(){
  phone = prompt('phone number?');
  socket.emit('registerPhone', {phone: phone});
  setPhoneStatus('sending...', 'unknown')
}
socket.on('validationSent', function(){
  setPhoneStatus('message sent. waiting for reply...', 'unknown')
})
socket.on('phoneValid', function(){
  setPhoneStatus('valid', 'ok');
});

var setPhoneStatus = function(msg, className){
  setStatus(phoneStatusEl, msg, className);
}
var setSocketStatus = function(msg, className){
  setStatus(socketStatusEl, msg, className);
}
var setStatus = function(el, statusMessage, statusClass){
  el.textContent = statusMessage;
  el.className = statusClass;
}