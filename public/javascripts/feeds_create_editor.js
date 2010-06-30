// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

 
$(document).ready(function() {	
 
// All non-GET requests will add the authenticity token
  // if not already present in the data packet
 	$(document).ajaxSend(function(event, request, settings) {
       if (typeof(window.AUTH_TOKEN) == "undefined") return;
       // <acronym title="Internet Explorer 6">IE6</acronym> fix for http://dev.jquery.com/ticket/3155
       if (settings.type == 'GET' || settings.type == 'get') return;
 
       settings.data = settings.data || "";
       settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(window.AUTH_TOKEN);
     });
	 
	 $(".feed_create_submit").click(function(event) {
	 	$('#feed_create_spinner').show();
	 	event.preventDefault();
	 	$.post($(this).attr("href"), $("#feed_form").serialize(), function(data) {
			return false;
		});
	 });
});
