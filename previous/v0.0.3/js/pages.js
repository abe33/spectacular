(function() {
  $(function() {
    var afterInstall, hs, pres, toc, tocList;
    hs = $('h2, h3, h4, h5, h6');
    afterInstall = false;
    hs = hs.filter(function() {
      if (this.textContent === 'Install') {
        afterInstall = true;
      }
      return afterInstall && $(this).parents('.caniuse_static').length === 0;
    });
    toc = $('<nav id="toc"><h2>Table Of Content</h2><ul></ul></nav>');
    tocList = toc.find('ul');
    hs.each(function() {
      var content, id, level;
      level = parseInt(this.nodeName.slice(1));
      content = this.textContent;
      id = content.replace(/[^\w]+/g, '-');
      this.id = id;
      return tocList.append("<li class='level" + level + "'><a href='#" + id + "'>" + content + "</a></li>");
    });
    $('hr').before(toc);
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
      div.prepend("<span class='toggle'>      <span class='coffee' data-text='view as js'>view as js</span>      <span class='js' data-text='view as coffee'>view as coffee</span>    </span>");
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
