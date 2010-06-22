// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

//var $j = jQuery.noConflict();
		
jQuery.ajaxSetup({ 'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")} })
 
function _ajax_request(url, data, callback, type, method) {
    if (jQuery.isFunction(data)) {
        callback = data;
        data = {};
    }
    return jQuery.ajax({
        type: method,
        url: url,
        data: data,
        success: callback,
        dataType: type
        });
}
 
jQuery.extend({
    put: function(url, data, callback, type) {
        return _ajax_request(url, data, callback, type, 'PUT');
    },
    delete_: function(url, data, callback, type) {
        return _ajax_request(url, data, callback, type, 'DELETE');
    }
});
 
jQuery.fn.submitWithAjax = function() {
  this.unbind('submit', false);
  this.submit(function() {
    $.post(this.action, $(this).serialize(), null, "script");
    return false;
  })
 
  return this;
};
 
//Send data via get if <acronym title="JavaScript">JS</acronym> enabled
jQuery.fn.getWithAjax = function() {
  this.unbind('click', false);
  this.click(function() {
    $.get($(this).attr("href"), $(this).serialize(), null, "script");
    return false;
  })
  return this;
};
 
//Send data via Post if <acronym title="JavaScript">JS</acronym> enabled
jQuery.fn.postWithAjax = function() {
  this.unbind('click', false);
  this.click(function() {
    $.post($(this).attr("href"), $(this).serialize(), null, "script");
    return false;
  })
  return this;
};
 
jQuery.fn.putWithAjax = function() {
  this.unbind('click', false);
  this.click(function() {
    $.put($(this).attr("href"), $(this).serialize(), null, "script");
    return false;
  })
  return this;
};
 
jQuery.fn.deleteWithAjax = function() {
  //this.removeAttr('onclick');
  this.unbind('click', false);
  this.click(function() {
    $.delete_($(this).attr("href"), $(this).serialize(), null, "script");
    return false;
  })
  return this;
};
 
//This will "ajaxify" the links
function ajaxLinks(){
    $('.ajaxForm').submitWithAjax();
    $('a.get').getWithAjax();
    $('a.post').postWithAjax();
    $('a.put').putWithAjax();
    $('a.delete').deleteWithAjax();
}
 
$(document).ready(function() {
	
	$('#spinner')
    .hide()  // hide it initially
    .ajaxStart(function() {
        $(this).show();
    })
    .ajaxStop(function() {
        $(this).hide();
    });
 
// All non-GET requests will add the authenticity token
  // if not already present in the data packet
 	$(document).ajaxSend(function(event, request, settings) {
       if (typeof(window.AUTH_TOKEN) == "undefined") return;
       // <acronym title="Internet Explorer 6">IE6</acronym> fix for http://dev.jquery.com/ticket/3155
       if (settings.type == 'GET' || settings.type == 'get') return;
 
       settings.data = settings.data || "";
       settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(window.AUTH_TOKEN);
     });

	 $('.error').hide();  
	 	 
	 $(".link_to_nowhere").click(function(event) {
	 	event.preventDefault();
	 });
	 
     $("a.view_entries").click(function(event){
         event.preventDefault();
         $.get($(this).attr("href"), {view: $(this).attr("view")}, function(data){
			 return false;
         });
     });
	 
	 $(".feed_submit").click(function(event) {
	 	$('.error').hide();
		//var title = $("input#feed_title").val();
		//var uri = $("input#feed_uri").val();
		//var dataString = 'title='+title+'&uri='+uri;
	 	$.post("/feeds/create", $("#feed_form").serialize(), function(data) {
			//$("#right_bar_3").html(data);
			ajaxLinks();
			return false;
		});
	 });
	 
	 $(".search_submit").click(function(event) {
	 	event.preventDefault();
	 	$.get($(this).attr("href"), $("#search_form").serialize(), function(data) {
			return false;
		});
	 });
	 
	 $(".new_feed_submit").click(function(event) {
	 	event.preventDefault();
	 	$.post($(this).attr("href"), $("#feed_form").serialize(), function(data) {
			//$("#right_bar_3").html(data);
			return false;
		});
	 });
	 
	 $(".feed_update_submit").click(function(event) {
	 	event.preventDefault();
		alert("input#feed_title" + $(this).attr("id"));
	 	$.put($(this).attr("href"), {id: $(this).attr("id"), title: $("input#feed_title" + $(this).attr("id")).val(), uri: $("input#feed_uri" + $(this).attr("id")).val()}, function(data) {
			//$("#right_bar_3").html(data);
			return false;
		});
	 });
	 
	 $(".feed_delete").click(function(event) {
	 	event.preventDefault();
	 	$.delete_($(this).attr("href"), $("#feed_form").serialize(), function(data) {
			//$("#right_bar_3").html(data);
			return false;
		});
	 });
 
  ajaxLinks();
});
