
var sendUserData = function(url, data, cb) { 
  $.ajax({
    url: url,
    type: 'PUT',
    dataType: 'json',
    success: function (data) {
      if ( cb != undefined ) { cb(data) }; 
    },
    data: data
  });
}

var init_user = function() {
  // pretty cheesy but we just want this to run on enumeration. 
  var el = document.getElementById("users_container"); 
  if ( el == null ) { return  }

  // just to be sure...   
  $('input[type="checkbox"].admin-toggle').bootstrapToggle(); // assumes the checkboxes have the class "toggle"

  // for the toggler
  $(".admin-toggle").change( function() {
    var $this = $(this);   
    var url = $this.closest("tr").data("user-url"); 
    var admin = $this.prop("checked"); 
    var data = {  user: { admin: admin }   }; 
    sendUserData(url, data); 
  });


}


$(document).ready(init_user);
$(document).on('turbolinks:load', init_user);
