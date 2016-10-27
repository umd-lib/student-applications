

$(document).ready(function() {

  // we had a pattern for collapses and radio buttons. if the true is checked,
  // make sure its associated collapse is open.
  $("input[type='radio'][value='true']:checked").each( function() { 
    var collapse = $(this).data("target");
    if (collapse) { $(collapse).collapse("show") } 
   }); 

  // if the unselect is selected, we should zero out the values in collapse
  $("input[type='radio'][value='false']").click( function(event) {
    var collapse = $(this).data("target");
    $(collapse).find( 'input' ).val(''); 
  });

  // just makes sure if you click the toggle, it says shut...
  $("input[type='radio'][data-toggle='collapse']").on('click.bs.collapse.data-api', function(event) {
    event.stopPropagation()   
    var collapse = $(this).data("target");
    if ( $(this).val() == 'true' ) {
      $(collapse).collapse("show");   
    } else { 
      $(collapse).collapse("hide"); 
    
    } 
  });  
  
  $("#availability-table > tbody > tr > td  input").hide();

  $("#availability-table > tbody > tr > td:not(.time-label) ").on("click", function(event) {
    var $this = $(this); 
    $this.toggleClass("success");
    $this.toggleClass("warning"); 
    
    var checkbox =  $this.find("input");
    checkbox.prop("checked", !checkbox.prop("checked"));
  })


})
