//= require_tree .
//= require html.sortable
//= require bootstrap-toggle


var sendData = function(data, cb) { 
  var url = $("form#new_enumeration").attr("action");
  $.ajax({
    url: url,
    type: 'post',
    dataType: 'json',
    success: function (data) {
      if ( cb != undefined ) { cb(data) }; 
    },
    data: data
  });
}


var getId = function(str) { 
 return str.substr(str.indexOf('_') + 1 ) 
}

var init = function() {
  // pretty cheesy but we just want this to run on enumeration. 
  var el = document.getElementById("new_enumeration"); 
  if ( el == null ) { return  }

  $('input[type="checkbox"].active-toggle').bootstrapToggle(); // assumes the checkboxes have the class "toggle"
  
  // For the row mover 
  $('.list-group').each( function() {
    sortable(this, { items: ':not(.new-enumeration)' })[0].addEventListener('sortupdate', function(e) {
      var ids = $.map($(e.detail.endparent).find("li"), function( e ) { if ( !/^new_/.test(e.id)  ) { return getId(e.id) } });   
      var data = { "_update_positions" : true, "ids": ids };
      sendData(data); 
    });
  }); 

  // for the toggler
  $(".active-toggle").change( function() {
    var $this = $(this);   
    var enumeration_id = getId($this.closest("li")[0].id); 
    var active = $this.prop("checked"); 
    var data = { "_toggle_active" : active, "enumeration_id": enumeration_id  } 
    sendData(data); 
  });


  // for new values
 $(document).on( "keypress",".new-enumeration-value", function (e) {
    if (e.which == 13) {
      var $this = $(this);
      var $ul = $($this.closest("ul"));
      var $li = $($this.closest("li")); 
      
      var index = $ul.find("li").length;
      var list =  $ul.data("list");
     
      var data = { enumeration: { value: this.value, list: list, position: index    } };
     
      var callback = function() { 
        
        var clone = $li.clone();
        clone.find("input").val('');
        clone.appendTo($ul).hide().fadeIn(200);
       
        $this.replaceWith( function() { return this.value } );
        $li.find(".toggle").prop("disabled", false);

      }
      
      sendData(data, callback);
      return false;
    } 
  
  
  });

}

$(document).ready(init);
$(document).on('turbolinks:load', init);
