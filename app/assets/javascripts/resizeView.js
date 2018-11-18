// Resize smartphone and screen height according to viewport
function resizeView() {
  var viewportHeight = window.innerHeight;

  if (viewportHeight > 660) {
      viewportHeight = 660;
  }

  viewportHeight = viewportHeight - 10;
  var agentHeight = $('.agent').outerHeight(true);
  var responseWrapperHeight = $('#responseWrapper').outerHeight(true);
  var screenHeight = viewportHeight - agentHeight - responseWrapperHeight;
  $('.smartphone').height(viewportHeight);
  $('.screen').height(screenHeight);
}

resizeView();

window.addEventListener("resize", function() {
    resizeView();
    window.scrollTo(0, 0);
}, false);
