// vim:sw=2 ts=2 et si fdm=marker:

liberator.log('_vimperatorrc.js loading');

(function () {

  // Plugins                                                                     {{{
  liberator.glovalVariables.plugin_loader_roots = "~/dev/github/vimpr/vimperator-plugins"
  liberator.globalVariables.plugin_loader_plugins = <>
    _libly
    auto_reload
    auto_source
    char-hints-mod2
    copy
    multi_requester
  </>.toString().split(/\s+/).filter(function(n) !/^!/.test(n));
  // }}}

})();


liberator.log('_vimperatorrc.js loaded');
liberator.registerObserver('enter', function () liberator.echo('Initialized.'));

