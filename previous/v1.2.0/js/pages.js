(function() {
  $(function() {
    var afterInstall, collapseCell, expandCell, hs, pres, toc, tocList, toggleCellExpansion;
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
    $('tr').each(function() {
      var table, tds, tr;
      tr = $(this);
      table = tr.parents('table');
      tr.addClass('no-padding');
      tds = tr.find('td');
      tds.each(function() {
        var newContent, td;
        td = $(this);
        newContent = $("<div>" + (td.html()) + "</div>");
        td.html('');
        td.append(newContent);
        if (tr.height() - 27 > 10) {
          newContent.addClass('ellipsis');
          if (!table.hasClass('ellipsis')) {
            table.addClass('ellipsis');
          }
        }
        newContent.attr('data-min-height', 27);
        newContent.attr('data-max-height', tr.height());
        return newContent.height(27);
      });
      return tr.click(function() {
        return tr.find('td div.ellipsis').each(function() {
          var d;
          d = $(this);
          if (d.height() === d.data('min-height')) {
            return expandCell(d.parents('td'));
          } else {
            return collapseCell(d.parents('td'));
          }
        });
      });
    });
    return $('table').each(function() {
      var controls, expandAll, table;
      if ($(this).find('.ellipsis').length === 0) {
        return;
      }
      table = $(this).wrap('<div class="table-wrapper"/>').parent();
      controls = $('<div class="table-controls"></div>');
      table.append(controls);
      expandAll = $('<button class="expand" title="expand/collapse"><i class="icon-collapse"></i><i class="icon-collapse-top"></i></button>');
      expandAll.click(function() {
        var expanded;
        expandAll.toggleClass('expanded');
        expanded = expandAll.hasClass('expanded');
        return table.find('.ellipsis').each(function() {
          var td;
          td = $(this).parents('td');
          return toggleCellExpansion(td, expanded);
        });
      });
      controls.append(expandAll);
      return new spectacular.SlidingObject(controls[0], table[0]);
    });
  });

}).call(this);
