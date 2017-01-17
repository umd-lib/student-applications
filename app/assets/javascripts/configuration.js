//= require html.sortable
//= require bootstrap-toggle

var init  = function() {

  // we return if we don't run on this page
  if ( document.getElementById("new_enumeration") == null ) { return  }

  // this is the forms action we'll be sending to.
  var url = $("form#new_enumeration").attr("action");
  $('input[type="checkbox"].active-toggle').bootstrapToggle(); // assumes the checkboxes have the class "toggle"
  
 
  // helper function to get the id from the id att 
  var getId = function(str) { 
   return str.substr(str.indexOf('_') + 1 ) 
  }
  
  // For the row mover 
  $('.list-group').each( function() {
    sortable(this, { items: ':not(.new-enumeration)' })[0].addEventListener('sortupdate', function(e) {
      var ids = $.map($(e.detail.endparent).find("li"), function( e ) { if ( !/^new_/.test(e.id)  ) { return getId(e.id) } });   
      var data = { "_update_positions" : true, "ids": ids };
      App.postData(url, data); 
    });
  }); 

  // for the toggler
  $(".active-toggle").change( function() {
    var $this = $(this);   
    var enumeration_id = getId($this.closest("li")[0].id); 
    var active = $this.prop("checked"); 
    var data = { "_toggle_active" : active, "enumeration_id": enumeration_id  } 
    App.postData(url, data); 
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
      
      App.postData(url, data).done( callback );
      return false;
    } 
  
  
  });
}


App.plugins.push(init);
