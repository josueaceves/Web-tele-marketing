$(document).ready(function(){

  $('.varify-phone-button').on('click', function(event){
    var href = ("/users/"+  $(this).attr('id')+ "/verify_number")
    var request = $.ajax({
      method: "Post",
      dataType: "Json",
      url: href
    })
    request.done(function(response){
      $("span#twilio-verification-code").text(response.code)
    });

    var request = $.ajax({
      method: "Post",
      dataType: "Json",
      url: "/check_verification"
    })
    request.done(function(request){
      console.log(request.response)
    });
  });
});
