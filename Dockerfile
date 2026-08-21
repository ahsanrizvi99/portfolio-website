FROM nginx:1.27-alpine

LABEL org.opencontainers.image.title="ahsan-rizvi-portfolio" \
      org.opencontainers.image.description="Personal portfolio site" \
      org.opencontainers.image.authors="ahsanrizvi1961@gmail.com"

# Replace the default nginx landing page with the site
RUN rm -rf /usr/share/nginx/html/*
COPY site/ /usr/share/nginx/html/

EXPOSE 80

# nginx:alpine already sets the right CMD, but being explicit
# makes the intent obvious to whoever reads this in evaluation.
CMD ["nginx", "-g", "daemon off;"]
