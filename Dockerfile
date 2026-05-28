# syntax=docker/dockerfile:1

FROM mcr.microsoft.com/playwright:v1.49.1-noble AS builder
WORKDIR /app

ENV NEXT_TELEMETRY_DISABLED=1
ENV BROWSER_DISABLE_GPU=true

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

FROM mcr.microsoft.com/playwright:v1.49.1-noble AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV BROWSER_DISABLE_GPU=true

COPY package*.json ./
RUN npm install --omit=dev

COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.js ./next.config.js

EXPOSE 3000
CMD ["sh", "-c", "npm run start -- -p ${PORT:-3000}"]
