// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require webpack-bundle
//= require jquery
//= require tether
//= require bootstrap
//= require jquery_ujs
//= require turbolinks
//= require moment
//= require bootstrap-datetimepicker
//= require_tree .

// Javascript for the datetimepicker widget
$(function () {
    var pickerPrefs = {
      format: "Y-MM-DD HH:mm:ss",
      collapse: false,
      icons: {
        time:     "fa fa-clock-o",
        date:     "fa fa-calendar",
        up:       "fa fa-arrow-up",
        down:     "fa fa-arrow-down",
        left:     "fa fa-chevron-left",
        right:    "fa fa-chevron-right",
        previous: "fa fa-chevron-left",
        next:     "fa fa-chevron-right",
        today:    "fa fa-crosshairs",
        clear:    "fa fa-trash",
        close:    "fa fa-remove"
      }
    };
    $(".datetimepicker").datetimepicker(pickerPrefs);
});