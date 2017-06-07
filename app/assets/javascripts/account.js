// Code to handle the sidebar actions on the User Account page to switch
// between the various tabs

$(document).on('turbolinks:load', function() {
  $('#account_page .nav-pills > li').on("click", "a", function(event) {
    event.preventDefault();

    console.log("Clicked: " + this);
    var active_nav_link = $('.nav-pills > li > a.active');
    var active_tab_id = active_nav_link.attr('href');

    // hide displaying tab content
    $(active_tab_id).addClass('hide');
    active_nav_link.removeClass('active');

    //add 'active' css into clicked navigation
    $(this).addClass('active');

    var target_tab_id = $(this).attr('href');
    $(target_tab_id).removeClass('hide');
  });
});
