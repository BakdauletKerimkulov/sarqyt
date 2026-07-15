/// Mixin for auto-dispose Notifiers to safely check if still mounted after
/// async gaps. Wire up in `build()` with `ref.onDispose(setUnmounted)`.
mixin NotifierMounted {
  bool _mounted = true;
  void setUnmounted() => _mounted = false;
  bool get mounted => _mounted;
}
