var init = function() { 

  if ( !$('.container.prospects').length ) { return  }

  // this is for adding permanent_addresses. we just want one
  $("#addresses").on('cocoon:after-insert', function() {
    $('.add-permanent-address').toggle();   
  }).on('cocoon:before-remove', function() { 
    $('.add-permanent-address').toggle();   
   });

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
 
  // this hides the checkboxes on the availability table. 
  $("#availability-table > tbody > tr > td  input").hide();

  $(".availability-availability-table > tbody > tr > td:not(.time-label) ").on("click", function(event) {
    var $this = $(this); 
    $this.toggleClass("success");
    $this.toggleClass("warning"); 

    var checkbox =  $this.find("input");
    checkbox.prop("checked", !checkbox.prop("checked"));
  })

  // For the file upload bits
  $("input#resume_file").on("change", function(e) { 
    var $uploader = $(".upload");
    $uploader.attr("value", "Submit (" + e.target.value + ")");
    $uploader.show();
    $(".show-link").hide();
  });

  $("form.uploadForm").submit( function(e){
    e.preventDefault();
   
    var $this = $(this);
    var formData = new FormData();

    var file =  document.getElementById('resume_file').files[0];

    if (!(/^application\/pdf$/.test(file.type) || /\.pdf$/i.test(file.name))) {
      alert("Not permitted format. Please upload a PDF.");
      return;
    }

    formData.append("resume[file]", file, file.name);

    // in test Rails doesn't do CSRF..
    var $token = $this.find("input[name='authenticity_token']");
    if ( $token.length > 0 ) { 
      formData.append("authenticity_token", $token[0].value);
    }
    
    var $method = $this.find("input[name='_method']");
    if ( $method.length > 0  ) {
      formData.append("_method", $method[0].value );
    } 
   
    var success = function(data) {
      $("#prospect_resume_id").attr( "value", data.id );
      $upload = $(".upload"); 
      $upload.removeClass("btn-warning").addClass("btn-success")
      $upload.attr("value", "Success!").attr("disabled", "disabled") 
    }
    
    var failure = function() { alert("Sorry, we have encountered and error."); } 
    var url = $this.attr("action");
    
    App.postData( url, formData ).done( success ).fail( failure );
  })

  $('input[type="checkbox"]#prospect_hired').bootstrapToggle(); // assumes the checkboxes have the class "toggle"
  $('input[type="checkbox"]#prospect_suppressed').bootstrapToggle(); // assumes the checkboxes have the class "toggle"

}

App.plugins.push(init);
