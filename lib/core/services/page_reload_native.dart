/// Never called on native — cloud sync (and therefore a restore that needs
/// a reload) is web-only. Present so native builds compile.
void reloadPage() {
  throw UnsupportedError('reloadPage is only supported on the web build.');
}
