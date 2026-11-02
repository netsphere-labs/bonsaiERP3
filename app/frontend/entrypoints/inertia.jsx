
// See https://www.reddit.com/r/reactjs/comments/1f36087/react_with_inertia_js/

import { createInertiaApp } from '@inertiajs/react'
import { createRoot, hydrateRoot } from 'react-dom/client';
import { StrictMode } from 'react';

// All packages except `@mantine/hooks` require styles imports
import '@mantine/core/styles.css';
import { MantineProvider } from '@mantine/core';


createInertiaApp({
  pages: "../pages",

  serverHead: true,

  title: (title) => title || "Bonsai Erp",

  strictMode: true,

  defaults: {
    form: {
      forceIndicesArrayFormatInFormData: false,
      withAllErrors: true,
    },
    visitOptions: () => {
      return { queryStringArrayFormat: "brackets" }
    },
  },

    // @note setup: function() { ... の短縮構文
    setup({ el, App, props }) {
        //createRoot(el).render(<App {...props} />)
        const inertiaApp = (
<StrictMode>
  <MantineProvider withGlobalStyles withNormalizeCSS>
    <App {...props} /> here is <code>entrypoints/inertia.jsx</code>
  </MantineProvider>
</StrictMode>
        );

        if (import.meta.env.DEV) {
            createRoot(el).render(inertiaApp);
        } else {
            // `hydrateRoot()` renders static code from server-side and makes it interactive
            hydrateRoot(el, inertiaApp);
        }
    },
}).catch((error) => {
  // This ensures this entrypoint is only loaded on Inertia pages
  // by checking for the presence of the root element (#app by default).
  // Feel free to remove this `catch` if you don't need it.
  if (document.getElementById("app")) {
    throw error
  } else {
    console.error(
      "Missing root element.\n\n" +
      "If you see this error, it probably means you loaded Inertia.js on non-Inertia pages.\n" +
      'Consider moving <%= vite_javascript_tag "inertia.jsx" %> to the Inertia-specific layout instead.',
    )
  }
});


