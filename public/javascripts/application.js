function setCaretTo(obj, pos) {
  if (obj.setSelectionRange) {
    /* Gecko is a little bit shorter on that. Simply
       focus the element and set the selection to a
       specified position */
    obj.focus();
    obj.setSelectionRange(pos, pos);
  } else if(obj.createTextRange) {
    /* Create a TextRange, set the internal pointer to
       a specified position and show the cursor at this
       position */
    var range = obj.createTextRange();
    range.move("character", pos);
    range.select();
  }
}

function documentSize() {
  var dimensions = {width: 0, height: 0};

  if (document.documentElement) {
    dimensions.width = document.documentElement.offsetWidth;
    dimensions.height = document.documentElement.offsetHeight ;
  } else if (window.innerWidth && window.innerHeight) {
    dimensions.width = window.innerWidth;
    dimensions.height = window.innerHeight;
  }

  return dimensions;
}
