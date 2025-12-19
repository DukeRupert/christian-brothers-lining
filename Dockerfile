# Stage 1: Build Hugo site
FROM hugomods/hugo:exts AS hugo-builder
WORKDIR /src
COPY . .
RUN hugo --gc --minify

# Stage 2: Final image with Caddy
FROM caddy:2-alpine

# Copy Hugo static site
COPY --from=hugo-builder /src/public /srv

# Copy Caddyfile
COPY Caddyfile /etc/caddy/Caddyfile

EXPOSE 80

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
