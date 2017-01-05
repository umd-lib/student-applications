var initAvailabilityModal = function() { 
  
  var $modal = $("#availabilityModal"); 
  if ( $modal == null ) { return  }

  $modal.on('show.bs.modal', function (event) {
    
    $(".avail-cell.success").removeClass("success").addClass("warning"); 
    var button = $(event.relatedTarget); 
    var dayTimes = button.data('daytimes');
    console.log(dayTimes);  
    dayTimes.forEach( function(dt) { 
      console.log(dt); 
      $("#avail-" + dt ).removeClass("warning").addClass("success"); 
    }); 
  });
  



}


$(document).ready(function() {
  initAvailabilityModal();
});
$(document).on("turbolinks:load", initAvailabilityModal);
