// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var $j = jQuery.noConflict();
		
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
    $.post(this.action, $j(this).serialize(), null, "script");
    return false;
  })
 
  return this;
};
 
//Send data via get if <acronym title="JavaScript">JS</acronym> enabled
jQuery.fn.getWithAjax = function() {
  this.unbind('click', false);
  this.click(function() {
    $.get($j(this).attr("href"), $j(this).serialize(), null, "script");
    return false;
  })
  return this;
};
 
//Send data via Post if <acronym title="JavaScript">JS</acronym> enabled
jQuery.fn.postWithAjax = function() {
  this.unbind('click', false);
  this.click(function() {
    $.post($j(this).attr("href"), $j(this).serialize(), null, "script");
    return false;
  })
  return this;
};
 
jQuery.fn.putWithAjax = function() {
  this.unbind('click', false);
  this.click(function() {
    $.put($j(this).attr("href"), $j(this).serialize(), null, "script");
    return false;
  })
  return this;
};
 
jQuery.fn.deleteWithAjax = function() {
  this.removeAttr('onclick');
  this.unbind('click', false);
  this.click(function() {
    $.delete_($j(this).attr("href"), $j(this).serialize(), null, "script");
    return false;
  })
  return this;
};
 
//This will "ajaxify" the links
function ajaxLinks(){
    $j('.ajaxForm').submitWithAjax();
    $j('a.get').getWithAjax();
    $j('a.post').postWithAjax();
    $j('a.put').putWithAjax();
    $j('a.delete').deleteWithAjax();
}
 
$j(document).ready(function() {
 
// All non-GET requests will add the authenticity token
  // if not already present in the data packet
 $j(document).ajaxSend(function(event, request, settings) {
       if (typeof(window.AUTH_TOKEN) == "undefined") return;
       // <acronym title="Internet Explorer 6">IE6</acronym> fix for http://dev.jquery.com/ticket/3155
       if (settings.type == 'GET' || settings.type == 'get') return;
 
       settings.data = settings.data || "";
       settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(window.AUTH_TOKEN);
     });
 
  ajaxLinks();
});
