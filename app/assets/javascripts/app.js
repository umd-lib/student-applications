window.App || (window.App = { plugins: [] });

// A generic SendData function. Receives a url, the data to post, and a
// callback
App.sendData = function(url, action, data ) {
  var processData = true;
  var contentType = 'multipart/form-data';
  
  if ( data instanceof FormData ) {
    processData = false; 
    contentType = false;
  } 
  
  return  $.ajax({
    url: url,
    type: action,
    dataType: 'json',
    processData: processData,
    contentType: contentType,
    data: data
  });
}


App.postData =  function(url, data) { 
  return App.sendData( url, 'post', data );
}

App.putData = function(url,data) {
  return App.sendData( url, 'put', data );
}


$(document).on("turbolinks:load", function() {
  App.plugins.forEach( function(func) { func(); } );
})
