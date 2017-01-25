//= require bootstrap-slider

var init = function() { 

  var $el = $('.container.prospects.index');
  if ( !$el.length ) { return  }
  
  // the checkbox to select all... 
  $("#prospect-select-all").change( function(){
    $( "input.deactivate" ).click(); 
  })        

  // toggles if the button is clickable or not
  var $btn = $("#deactivate-prospects");
  $( $el, "input.deactivate" ).change( function(){
    if ( $( 'input.deactivate:checked').length == 0  ) { $btn.attr("disabled", "disabled"); }
    else { $btn.removeAttr('disabled'); }
  });
              
  // the modal for the actually deletion..
  $("#deactivate-modal").on('show.bs.modal', function(e) {
    $(".deactivate-table > tbody").empty();
    $("tr:not(:first):has(input:checked)").clone().appendTo(".deactivate-table > tbody");           
  });

  // submits the deactivation from the modal
  $("#submit-deactivate").click( function() {
     var $this = $(this);
     var ids = new Array();
     var $rows =$(".prospects tr:not(:first):has(input:checked)"); 
     $.each( $( $rows ).find("input.deactivate:checked"), function() {
        ids.push( $(this).val() );
      });
      var url = $this.data("deactivate-url");
      var data = { "ids" : ids };
      
      var callback = function(data) {
          $("#prospect-select-all").removeAttr("checked"); 
          $rows.find("input").removeAttr("checked").remove(); 
          $("#deactivate-modal").modal('hide');
          var msg = '<div class="alert alert-info fade in"><button class="close" data-dismiss="alert">x</button>' + ids.length + ' records deleted</div>';
          $rows.addClass("danger"); 
        $("body > .container").prepend(msg);           
      }
    
      App.postData( url, data ).done(callback).fail( function() { alert("Problem with update!"); } );
  
  });

  // we can clean up out sliders on each open/close
  $("#filter-modal").on('show.bs.modal', function(e){ 
    $("#available-hours-selector").bootstrapSlider({tooltip: 'always'}); 
  });
  
  $("#filter-modal").on('hidden.bs.modal', function(e){ 
    $("#available-hours-selector").bootstrapSlider('destroy'); 
  });

  // this submits the filter form after pulling the values from the slider.
  $("#submit-filter").click( function(e) { 
    e.preventDefault(); 
    var vals = $("#available-hours-selector").bootstrapSlider('getValue'); 
    $("#availability-min").val( vals[0] );       
    $("#availability-max ").val( vals[1] );       
    $("#filter-prospects-form").submit();         
  });
 

  $("#availabilityModal").on('show.bs.modal', function (event) {
    $(".avail-cell.success").removeClass("success").addClass("warning");
    var button = $(event.relatedTarget);
    var dayTimes = button.data('daytimes');
    dayTimes.forEach( function(dt) {
      $("#avail-" + dt ).removeClass("warning").addClass("success");
    });
  });

}

App.plugins.push(init);
