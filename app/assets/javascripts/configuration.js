//= require html.sortable
//= require bootstrap-toggle

var init  = function() {

  // we return if we don't run on this page
  if ( document.getElementById("new_enumeration") == null ) { return  }

  // this is the forms action we'll be sending to.
  var url = $("form#new_enumeration").attr("action");
  
  $('input[type="checkbox"].active-toggle').bootstrapToggle(); // assumes the checkboxes have the class "togglek"
  $('input[type="checkbox"].promoted-toggle').bootstrapToggle(); // assumes the checkboxes have the class "togglek"
  
 
  // helper function to get the id from the id att 
  var getId = function(str) { 
   return str.substr(str.indexOf('_') + 1 ) 
  }
  
  // For the row mover 
  $('.list-group').each( function() {
    sortable(this, { items: ':not(.new-enumeration)' })[0].addEventListener('sortupdate', function(e) {
      var ids = $.map($(e.detail.endparent).find("li"), function( e ) { if ( !/^new_/.test(e.id)  ) { return getId(e.id) } });   
      var data = { "update_positions_ids": ids };
      App.postData(url, data); 
    });
  }); 

  // for the actvie-toggler
  $(".active-toggle").change( function() {
    var $this = $(this);   
    var enumeration_id = getId($this.closest("li")[0].id); 
    var data = { "toggle_active_id": enumeration_id  } 
    App.postData(url, data); 
  });
  
  $(".promoted-toggle").change( function() {
    var $this = $(this);   
    var skill_id = getId($this.closest("li")[0].id); 
    var data = { "toggle_promoted_id":  skill_id  } 
    App.postData(url, data); 
  });

  // this inserts newly save li value into the list after a save. 
  var insertIntoListAfterSave = function() { 
    var clone = $li.clone();
    var $ul = $li.closest("ul");
    clone.find("input").val('');
    clone.appendTo($ul).hide().fadeIn(200);
    $this.replaceWith( function() { return this.value } );
  }

  // for new enumeartion values
 $(document).on( "keypress",".new-skill-value", function (e) {
    if (e.which == 13) {
      if ( this.value.length < 1 ) { return false; }
      $this = $(this);
      $li = $($this.closest("li")); 
      var data = { skill: { name: this.value, promoted: true  } };
      App.postData(url, data).done( insertIntoListAfterSave ).fail( function() { alert("Sorry, there was a problem creating this value.") } );
      return false;
    } 
  });

  // for new enumeartion values
 $(document).on( "keypress",".new-enumeration-value", function (e) {
    if (e.which == 13) {
      if ( this.value.length < 1 ) { return false; }
      $this = $(this);
      var $ul = $($this.closest("ul"));
      $li = $($this.closest("li")); 
      
      var index = $ul.find("li").length;
      var list =  $ul.data("list");
      var data = { enumeration: { value: this.value, list: list, position: index    } };
      App.postData(url, data).done( insertIntoListAfterSave ).fail( function() { alert("Sorry, there was a problem creating this value.") } );
      return false;
    } 
  });

}


App.plugins.push(init);
