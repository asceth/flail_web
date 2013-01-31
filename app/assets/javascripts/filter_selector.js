(function( $ ){
  $.fn.filterSelector = function () {
    function setReadOnlyState() {
      var $selectorCheckBox = $(this),
          fieldId = $selectorCheckBox.data('filter-selector'),
          $field = $('#' + fieldId)
          notChecked = !this.checked;

      $field.prop('readonly', notChecked);
    }

    return this.each(function () {
      // Set the initial state of each field
      setReadOnlyState.call(this);
      this.addEventListener('click', setReadOnlyState, false);
    });
  }
})( jQuery )
