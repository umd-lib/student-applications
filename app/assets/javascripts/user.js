var init = function() {
  // pretty cheesy but we just want this to run on enumeration. 
  var $el = $(".container.users"); 
  if ( !$el.length ) { return  }

  // just to be sure...   
  $('input[type="checkbox"].admin-toggle').bootstrapToggle(); // assumes the checkboxes have the class "toggle"

  // for the toggler
  $(".admin-toggle").change( function() {
    var $this = $(this);   
    var url = $this.closest("tr").data("user-url"); 
    var admin = $this.prop("checked"); 
    var data = {  user: { admin: admin }   }; 
    App.putData(url, data).fail( function() { alert("System error with update to user!"); } ); 
  });


}

App.plugins.push(init);
