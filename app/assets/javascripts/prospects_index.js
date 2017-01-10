//= require bootstrap-slider

$(function() {
  $.fn.init_prospects_table = function() { 
     $(this).each(function() {
       var $this = $(this);  
       if ( $this.hasClass("initialised") ) { return; } 

       // the checkbox to select all... 
       $("#prospect-select-all").change( function(){
           $( "input.deactivate" ).click(); 
       })        

       // toggles if the button is clickable or not
        var $btn = $("#deactivate-prospects");
        $( $this, "input.deactivate" ).change( function(){
          if ( $( 'input.deactivate:checked').length == 0  ) { $btn.attr("disabled", "disabled"); }
          else { $btn.removeAttr('disabled'); }
        });
              
        // the modal for the actually deletion..
       $("#deactivate-modal").on('show.bs.modal', function(e) {
          $(".deactivate-table > tbody").empty();
          $("tr:not(:first):has(input:checked)").clone().appendTo(".deactivate-table > tbody");           
        });

       $("#submit-deactivate").click( function() {
         var $this = $(this);
         var ids = new Array();
         var $rows =$(".prospects tr:not(:first):has(input:checked)"); 
         $.each( $( $rows ).find("input.deactivate:checked"), function() {
            ids.push( $(this).val() );
          });
          var url = $this.data("deactivate-url");
          var data = { "ids" : ids };
          $.ajax({
            url: url,
            type: 'post',
            data: data, 
            dataType: 'json',
            success: function (data) {
              $("#prospect-select-all").removeAttr("checked"); 
              $rows.find("input").removeAttr("checked").remove(); 
              $("#deactivate-modal").modal('hide');
              var msg = '<div class="alert alert-info fade in"><button class="close" data-dismiss="alert">x</button>' + ids.length + ' records deleted</div>';
              $rows.addClass("danger"); 
              $("body > .container").prepend(msg);           
            },
          });
        });
 
       $this.addClass("initialised");  
     })
  
 
     $("#available-hours-selector").slider({}); 

     $("#submit-filter").click( function(e) { 
        e.preventDefault(); 
        var vals = $("#available-hours-selector").slider('getValue'); 
        $("#availability-min").val( vals[0] );       
        $("#availability-max ").val( vals[1] );       
        $("#filter-prospects-form").submit();         
      });
  
  }
  

  $(document).on("turbolinks:load", $(".table.prospects:not(.initialised)").init_prospects_table );

})
