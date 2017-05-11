(function($) {
    $.extend($.fn, {
        tabBar: function(setting) {

            if (setting && setting.selectedChanged) {
                this.selectedChanged = setting.selectedChanged;
            }
            var $s = this;
            var cls = this[0].children;
            this.addClass('tabBar');
            for (var i = 0; i < cls.length; i++) {
                var p = $(cls[i]);
                cls[i].setAttribute('i', i);
                if (i == 0) {
                    p.addClass('firstTab');
                }
                if (i == cls.length - 1) {
                    p.addClass('lastTab');
                }
                if (i == $s.selectedIndex) {
                    p.addClass('selected');
                }
                p.bind('touchend click', function() {
                    $s.onItemClick(this);
                })
            }
        },
        selectedIndex: 0,
        onItemClick: function(sender) {
            var i = parseInt(sender.getAttribute('i'));
            if (i == this.selectedIndex)
                return;
            var cls = this[0].children;
            $(cls[this.selectedIndex]).removeClass('selected');
            $(cls[i]).addClass('selected');
            var oldIndex = this.selectedIndex;
            this.selectedIndex = i;
            if (this.selectedChanged)
                this.selectedChanged(i, oldIndex);
        }
    });

})(jQuery);