(function() {
  $(function() {
    var SlidingObject, collapseCell, expandCell, hs, pres, tocHeader, tocList, toggleCellExpansion;
    SlidingObject = (function() {
      function SlidingObject(target, container) {
        var body, doc, previousOnScroll,
          _this = this;
        this.target = target;
        this.container = container;
        previousOnScroll = window.onscroll;
        doc = document.documentElement;
        body = document.body;
        window.onscroll = function() {
          var top, topMax, topMin;
          if (previousOnScroll != null) {
            previousOnScroll();
          }
          topMin = _this.getOffset(_this.container);
          topMax = topMin + _this.container.clientHeight - _this.target.clientHeight;
          top = doc && doc.scrollTop || body && body.scrollTop || 0;
          top = Math.min(topMax, Math.max(topMin, top + 100)) - topMin;
          return _this.target.style.top = "" + top + "px";
        };
      }

      SlidingObject.prototype.getOffset = function(node) {
        if (node.nodeName.toLowerCase() === 'body') {
          return node.offsetTop;
        }
        return node.offsetTop + this.getOffset(node.parentNode);
      };

      return SlidingObject;

    })();
    hs = $('h2, h3, h4, h5, h6');
    hs = hs.filter(function() {
      return $(this).parents('.caniuse_static, header').length === 0;
    });
    if (hs.length > 0) {
      tocHeader = $('<h2>Table Of Content</h2>');
      tocList = $('<ul></ul>');
      hs.each(function() {
        var content, id, level;
        level = parseInt(this.nodeName.slice(1));
        content = this.textContent;
        id = content.replace(/[^\w]+/g, '-');
        this.id = id;
        return tocList.append("<li class='level" + level + "'><a href='#" + id + "'>" + content + "</a></li>");
      });
      $('#toc').append(tocHeader);
      $('#toc').append(tocList);
    }
    $('pre.coffeescript code').each(function() {
      var code, coffee, pre;
      pre = $(this).parent();
      coffee = pre.text();
      code = hljs.highlight('ruby', coffee).value;
      pre.removeClass('coffeescript');
      $(this).addClass('lang-coffeescript');
      return $(this).html(code);
    });
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
    pres.each(function(i, el) {
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
    toggleCellExpansion = function(td, bool) {
      var ellipsis, tr;
      tr = td.parents('tr');
      ellipsis = td.find('.ellipsis');
      if (bool) {
        ellipsis.height(ellipsis.data('max-height'));
        if (!tr.hasClass('open')) {
          return tr.addClass('open');
        }
      } else {
        ellipsis.height(ellipsis.data('min-height'));
        if (tr.hasClass('open')) {
          return tr.removeClass('open');
        }
      }
    };
    expandCell = function(td) {
      return toggleCellExpansion(td, true);
    };
    collapseCell = function(td) {
      return toggleCellExpansion(td, false);
    };
    return $('.nav-menu-button').on('click', function(e) {
      $('#nav').toggleClass('active');
      controls.append(expandAll);
      return new SlidingObject(controls[0], table[0]);
    });
  });

}).call(this);
