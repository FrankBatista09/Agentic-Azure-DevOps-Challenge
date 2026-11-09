FROM node:15.5.1-alpine AS build

WORKDIR /app

# node-sass 5 compiles from source when its prebuilt binding cannot be downloaded.
# These tools exist only in the build stage; the final nginx image does not contain them.
RUN apk add --no-cache python3 make g++

COPY package.json package-lock.json .npmrc ./
RUN npm ci

ARG REACT_APP_API_URL
ENV REACT_APP_API_URL=$REACT_APP_API_URL

COPY . .
RUN npm run build

FROM nginx:1.21.6-alpine

COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
