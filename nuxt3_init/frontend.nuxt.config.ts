// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
    app: {
        baseURL: '/', // backend=/backend/, frontend=/
    },
    vite: {
        server: {
            hmr: {
                port: 24679, // backend=24678, frontend=24679
                clientPort: 8080, // non_ssl=8080, ssl=8443
                protocol: 'ws', // non_ssl=ws, ssl=wss
            }
        },
    },
})
