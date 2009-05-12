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
