// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
    app: {
        baseURL: '/', // backend=/backend/, frontend=/
    },
    vite: {
        server: {
            hmr: {
                clientPort: 8080,
                port: 24679, // backend=24678, frontend=24679
                protocol: 'ws',
            }
        },
    },
})
