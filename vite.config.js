
import { defineConfig } from 'vite'
import inertia from '@inertiajs/vite'
import react, { reactCompilerPreset } from '@vitejs/plugin-react';
import babel from '@rolldown/plugin-babel'
// vite_ruby
import RubyPlugin from 'vite-plugin-ruby'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
      inertia(),
      react(),
      babel({ presets: [reactCompilerPreset()] }),
      RubyPlugin(),
  ],
});

