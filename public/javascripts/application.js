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

function set_list(){
    $.get("/rss_entries", $("#list_selector").serialize(), function(data){
        return false;
    });
}
 
$(document).ready(function() {
	
	$('#feed_create_spinner').hide();
	$('.feed_update_spinner').hide();
 
// All non-GET requests will add the authenticity token
  // if not already present in the data packet
 	$(document).ajaxSend(function(event, request, settings) {
       if (typeof(window.AUTH_TOKEN) == "undefined") return;
       // <acronym title="Internet Explorer 6">IE6</acronym> fix for http://dev.jquery.com/ticket/3155
       if (settings.type == 'GET' || settings.type == 'get') return;
 
       settings.data = settings.data || "";
       settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(window.AUTH_TOKEN);
     });

	 $('.feed_create_title_error').hide(); 
	 $('.feed_create_uri_error').hide(); 
	 	 
	 $(".link_to_nowhere").click(function(event) {
	 	event.preventDefault();
	 });
	 
	 $("a.set_list").click(function(event){
         event.preventDefault();
         $.get($(this).attr("href"), $("#list_selector").serialize(), function(data){
			 return false;
         });
     });
	 
     $("a.view_entries").click(function(event){
         event.preventDefault();
         $.get($(this).attr("href"), {view: $(this).attr("view")}, function(data){
			 return false;
         });
     });
	 
	 $("input[name='radio']").change(function(event){
		event.preventDefault();
        $.get('/rss_entries', {view: $("input[name='radio']:checked").val()}, function(data){
			return false;
        });
	});
	
	$(".update_dataset").click(function(event){
		event.preventDefault();
		$(".header_bar").html("<%= escape_javascript(render :partial => 'header_bar') %>");
        $.get('/rss_entries', {dataset: $(this).attr("dataset")}, function(data){
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
	 	$('#feed_create_spinner').show();
	 	event.preventDefault();
	 	$.post($(this).attr("href"), $("#feed_form").serialize(), function(data) {
			//$("#right_bar_3").html(data);
			return false;
		});
	 });
	 
	 $(".feed_update_submit").click(function(event) {
	 	$('#feed_update_spinner' + $(this).attr("id")).show();
	 	event.preventDefault();
	 	$.put($(this).attr("href"), $("#feed_update_form" + $(this).attr("id")).serialize(), function(data) {
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
	 
	 $(".read_link").click(function(event){
         event.preventDefault();
         $.get($(this).attr("href"), {view: $(this).attr("view")}, function(data){
			 return false;
         });
     });
 
  ajaxLinks();
});
