import 'webpack-jquery-ui/sortable'

window.GobiertoAdmin.TermsController = (function() {
  function TermsController() {}

  TermsController.prototype.index = function() {
    _handleSortableList();
  };

  function _handleSortableList() {
    var wrapper = "tbody[data-behavior=sortable]";

    $(wrapper).sortable({
      items: 'tr',
      handle: '.custom_handle',
      forcePlaceholderSize: true,
      placeholder: '<tr><td colspan="8">&nbsp;&nbsp;</td></tr>',
      update: function() {
        _refreshPositions(wrapper);
        _requestUpdate(wrapper, _buildPositions(wrapper));
      },
      helper: _fixWidthHelper
    });
  }

  function _fixWidthHelper(e, ui) {
    ui.children().each(function() {
      $(this).width($(this).width());
    });
    return ui;
  }

  function _refreshPositions(wrapper) {
    $(wrapper).find("tr").each(function(index) {
      $(this).attr("data-pos", index + 1);
    });
  }

  function _buildPositions(wrapper) {
    var positions = [];

    $(wrapper).find("tr").each(function(index) {
      positions.push({
        id: $(this).data("id"),
        position: index + 1
      });
    });

    return positions;
  }

  function _requestUpdate(wrapper, positions) {
    $.ajax({
      url: $(wrapper).data("sortable-target"),
      method: "POST",
      data: { positions: positions }
    });
  }

  return TermsController;
})();

window.GobiertoAdmin.terms_controller = new GobiertoAdmin.TermsController;
