/**
 * No Clocks, LLC JavaScript Library
 *  @see {@link https://shiny.rstudio.com/articles/js-events.html}
 */
 $(function() {

   $('document').ready(function(){
     console.log('Ready!');
   });

   // Extend shinydashboard::box
  $('.box .btn-box-tool').on('click', function(e){
    // console.log(this.getAttribute('data-collapsed'));
  });

  // Add magnifying glass icon to expandable images and handle behaviors
  $(document).on('shiny:value', function(event) {
    event.target.addEventListener('DOMNodeInserted', function(e){
     if(typeof(e.target.querySelectorAll) != 'undefined'){
      let nodes = e.target.querySelectorAll('img.expandable:not([draggable])');
      if(nodes.length) {
        Array.from(nodes).forEach(imageExpansion);
      }
     }
    });
  });

  // Typeset MathJax
  Shiny.addCustomMessageHandler('typeset-mathjax', function(message) {
    /** @deprecated will need to update if shiny adopts MathJax 3.x */
    if(window.MathJax) MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
  });

  /**
   * Shiny bindings
   */
  /*
  $(document).on('shiny:bound', function(event) {
    if(event.bindingType == "input") {
      // ...
    } else if (event.bindingType == "output") {
      // ...
    }
  });
  */

  function imageExpansion(node) {
    let parent = node.parentNode;
  	let button = document.createElement('button');
  		button.innerHTML = '<i class="far fa fa-search">&nbsp;</i>';
  		button.title = 'Click to Expand';
  		button.setAttribute('aria-expanded', "false");
  		button.classList.add("expand-img-btn");
  		button.addEventListener('click', function(){
  			node.classList.toggle('expanded');
  			if(button.getAttribute('aria-expanded') === "true") {
  			  button.setAttribute('aria-expanded', "false");
  			} else {
  			  button.setAttribute('aria-expanded', "true");
  			  button.focus();
  			}
  		});
  		node.draggable = false;
  		node.addEventListener('click', function() {
  			node.classList.remove('expanded');
  			button.setAttribute('aria-expanded', "false");
  		});
  		parent.addEventListener('keydown', function(event) {
  		  event = event || window.event;
        if ('key' in event && (event.key === 'Escape' || event.key === 'Esc')) {
            node.classList.remove('expanded');
            button.setAttribute('aria-expanded', "false");
        }
      });
  	parent.appendChild(button);
  }
 })
