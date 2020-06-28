// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.



require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

import $ from 'jquery';
import 'bootstrap/dist/js/bootstrap';
// import 'bootstrap/js/dist/util'
// import './bootstrap_custom.js' needed to click twice on dropdowns
import { library, dom  } from '@fortawesome/fontawesome-svg-core'
import { fas } from '@fortawesome/free-solid-svg-icons'
import { far } from '@fortawesome/free-regular-svg-icons'
import { fab } from '@fortawesome/free-brands-svg-icons'
library.add(fas, far, fab)
dom.watch()
import 'jquery-easing';
// import Chart from 'chartjs';
// import 'bootstrap-switch-button';
import 'bootstrap-toggle';

// Add all icons to the library so you can use it in your page


$(document).on('turbolinks:load', function() {
  $('body').tooltip({
    selector: '[data-toggle="tooltip"]',
    container: 'body',
  });

  $('.ViewDelivery-reportStatusForm').on('ajax:success', function(event) {
    $(event.target).parents('.collapse').collapse('toggle');
    console.log(event.detail[0]['status']);
    if (event.detail[0]['status'] == 'delivered') {
      $(event.target).parents('.ViewDelivery-fulfillmentCard').find('.ViewDelivery-successHeader').removeClass('d-none')
      $(event.target).parent().html("<div class='h2'><div class='badge badge-success'><i class='fas fa-check-square'></i> Delivered!</div></div>");
    } else {
      $(event.target).parents('.ViewDelivery-fulfillmentCard').find('.ViewDelivery-returnHeader').removeClass('d-none')
      $(event.target).parent().html("<div class='h2'><div class='badge badge-danger'><i class='fas fa-times-square'></i> RETURNED</div></div>");
    }
  });

  $('.ViewDelivery-reportStatusForm').on('ajax:error', function(event) {
    alert("You must provide a note");
  });

  $('body').popover({
    selector: '[data-toggle="popover"]',
    container: 'body',
    html: true,
    trigger: 'hover',
  });

  $(document).find("#aid_request_needs_call_back").bootstrapToggle({
    on: "CALLBACK",
    off: "Callback",
    onstyle: "success",
    offstyle: "light",
    width: 100
  });

  $(document).find("#aid_request_urgent").bootstrapToggle({
    on: "URGENT",
    off: "Urgent",
    onstyle: "danger",
    offstyle: "light",
    width: 100
  });

  $(document).find("a#all-toggle").click(function() {
    console.log("all");
    $(".CreatePackingSlip-fulfillmentRow").show();
    $(".nav-item .nav-link").removeClass("active");
    $("a#all-toggle").addClass("active");
    return false;
  });

  $(document).find("a#basic-toggle").click(function() {
    console.log("Basic");
    $(".CreatePackingSlip-basicRow").show();
    $(".CreatePackingSlip-specialRow").hide();
    $(".nav-item .nav-link").removeClass("active");
    $("a#basic-toggle").addClass("active");
    return false;
  });

  $(document).find("a#special-toggle").click(function() {
    console.log("special");
    $(".CreatePackingSlip-basicRow").hide();
    $(".CreatePackingSlip-specialRow").show();
    $(".nav-item .nav-link").removeClass("active");
    $("a#special-toggle").addClass("active");
    return false;
  });


    (function($) {
      "use strict"; // Start of use strict

      if ($(window).width() < 768) {
        $("body").toggleClass("sidebar-toggled");
        $(".sidebar").toggleClass("toggled");
        if ($(".sidebar").hasClass("toggled")) {
          $('.sidebar .collapse').collapse('hide');
        };
      }

      // Toggle the side navigation
      $("#sidebarToggle, #sidebarToggleTop").on('click', function(e) {
        $("body").toggleClass("sidebar-toggled");
        $(".sidebar").toggleClass("toggled");
        if ($(".sidebar").hasClass("toggled")) {
          $('.sidebar .collapse').collapse('hide');
        };
      });

      // Close any open menu accordions when window is resized below 768px
      $(window).resize(function() {
        if ($(window).width() < 768) {
          $('.sidebar .collapse').collapse('hide');
        };
        
        // Toggle the side navigation when window is resized below 480px
        if ($(window).width() < 480 && !$(".sidebar").hasClass("toggled")) {
          $("body").addClass("sidebar-toggled");
          $(".sidebar").addClass("toggled");
          $('.sidebar .collapse').collapse('hide');
        };
      });

      // Prevent the content wrapper from scrolling when the fixed side navigation hovered over
      $('body.fixed-nav .sidebar').on('mousewheel DOMMouseScroll wheel', function(e) {
        if ($(window).width() > 768) {
          var e0 = e.originalEvent,
            delta = e0.wheelDelta || -e0.detail;
          this.scrollTop += (delta < 0 ? 1 : -1) * 30;
          e.preventDefault();
        }
      });

      // Scroll to top button appear
      $(document).on('scroll', function() {
        var scrollDistance = $(this).scrollTop();
        if (scrollDistance > 100) {
          $('.scroll-to-top').fadeIn();
        } else {
          $('.scroll-to-top').fadeOut();
        }
      });

      // Smooth scrolling using jQuery easing
      $(document).on('click', 'a.scroll-to-top', function(e) {
        var $anchor = $(this);
        $('html, body').stop().animate({
          scrollTop: ($($anchor.attr('href')).offset().top)
        }, 1000, 'easeInOutExpo');
        e.preventDefault();
      });

    })(jQuery); // End of use strict
});



  // $(document).on('ajax:success', '.ViewDelivery-deliverFulfillmentButton', function(e, data) { 
  //   console.log("here");
  //   $(this).replaceWith("<div class='badge badge-success'><i class='fas fa-check-square'></i> Delivered!</div>");
  //   $(this).parents('.collapse').collapse('toggle')
  // });
// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
