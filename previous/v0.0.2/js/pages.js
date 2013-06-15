(function() {
  $(function() {
    var pres;
    $('.lang-coffeescript').each(function() {
      var code, coffee, div, js, pre, toggle;
      pre = $(this).parent();
      coffee = pre.text();
      js = CoffeeScript.compile(coffee, {
        bare: true
      }).replace(/return\s(\w+\()/g, '$1');
      code = hljs.highlight('javascript', js).value.replace(/\n$/gm, '');
      pre.addClass('lang-coffeescript');
      pre.wrap('<div class="code"></div>');
      div = pre.parent();
      div.height(pre.height());
      div.prepend("<span class='toggle'>      <span class='coffee'>view as js</span>      <span class='js'>view as coffee</span>    </span>");
      div.append("<pre class='lang-javascript'><code class='lang-javascript'>" + code + "</code></pre>");
      toggle = div.find('.toggle');
      return toggle.click(function() {
        div.toggleClass('compiled');
        if (div.hasClass('compiled')) {
          return div.height(div.find('.lang-javascript').data('height'));
        } else {
          return div.height(div.find('.lang-coffeescript').data('height'));
        }
      });
    });
    pres = $('pre code');
    return pres.each(function(i, el) {
      var lines, parent, text;
      el = $(el);
      parent = el.parent();
      parent.attr('data-height', parent.height());
      text = el.html();
      lines = text.split('\n');
      return parent.prepend("<ol>" + (lines.map(function(l, i) {
        return "<li>" + (i + 1) + "</li>";
      }).join('')) + "</ol>");
    });
  });

}).call(this);
