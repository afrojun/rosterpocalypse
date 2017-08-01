$(function() {
  // **************
  // Join League
  // **************
  $(".join-league-button").on("click", function(event) {
    var league_name = $(this).data('league-name');
    fbq('trackCustom', 'JoinLeague', {
      league_name: league_name
    });
  });

  // **************
  // New/Edit Page
  // **************

  // Show value adjustment range sliders when the "Edit" link is clicked
  $(".edit_role_stat_modifiers").on("click", function(event) {
    event.preventDefault();

    var role = $(this).data("role");
    var update_div_class = ".update_" + role + "_stat_modifiers";
    var edit_link_id = "#edit_" + role + "_stat_modifiers";
    var set_link_id = "#set_" + role + "_stat_modifiers";

    $(update_div_class).removeClass("hide");
    $(edit_link_id).addClass("hide");
    $(set_link_id).removeClass("hide");
  });

  // Hide value adjustment range sliders when the "Done" link is clicked
  $(".set_role_stat_modifiers").on("click", function(event) {
    event.preventDefault();

    var role = $(this).data("role");
    var update_div_class = ".update_" + role + "_stat_modifiers";
    var edit_link_id = "#edit_" + role + "_stat_modifiers";
    var set_link_id = "#set_" + role + "_stat_modifiers";


    $(update_div_class).addClass("hide");
    $(edit_link_id).removeClass("hide");
    $(set_link_id).addClass("hide");
  });

  // When the range slider input changes update the corresponding text to show the value
  $(".role_stat_range_slider").on("input", function() {
    var role = $(this).data("role");
    var stat = $(this).data("stat");
    var league_type = location.pathname.split("/")[1].slice(0, -1);
    var slider_id = "#" + league_type + "_role_stat_modifiers_" + role + "_" + stat;
    var text_id = "#" + role + "_" + stat + "_modifier";

    $(text_id).text($(slider_id).val());
  });

  // When the range slider input changes update the corresponding text to show the value
  $(".req_roles_range_slider").on("input", function() {
    var role = $(this).data("role");
    var league_type = location.pathname.split("/")[1].slice(0, -1);
    var slider_id = "#" + league_type + "_required_player_roles_" + role;
    var text_id = "#" + role + "_req_roles_modifier";

    $(text_id).text($(slider_id).val());
  });
});