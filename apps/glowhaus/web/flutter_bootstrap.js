{{flutter_js}}
{{flutter_build_config}}

// Removes the CSS spinner from index.html once the app has started.
_flutter.loader.load({
  onEntrypointLoaded: async (engineInitializer) => {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
    document.getElementById('glow-loading')?.remove();
  },
});
