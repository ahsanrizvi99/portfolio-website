# Portfolio Website — Jenkins CI to Docker Hub

Personal portfolio site, containerised with nginx and published to Docker Hub by a
Jenkins pipeline. **Deployment is deliberately manual** — Jenkins stops once the image
is pushed.

```
GitHub  ->  Jenkins CI  ->  Docker image build  ->  Docker Hub  ->  manual pull & run  ->  browser
```

## Repository layout

```
.
├── site/
│   ├── index.html      # the portfolio page
│   └── style.css
├── Dockerfile          # nginx:alpine + static site, serves on port 80
├── Jenkinsfile         # Checkout -> Build -> Tag -> Docker Hub Login -> Push
├── .dockerignore
└── README.md
```

## Pipeline stages

| Stage | Action | Result |
|---|---|---|
| Checkout | Clone the repo into the Jenkins workspace | Workspace holds the project |
| Build | `docker build` using the Dockerfile | Local image created |
| Tag | Apply `<repo>:<build-number>` and `<repo>:latest` | Image ready to publish |
| Docker Hub Login | `withCredentials` + `--password-stdin` | Authenticated, no secrets in source |
| Push | Push both tags | Tags visible on Docker Hub |

No deploy stage exists by design.

## Jenkins setup

1. Store a Docker Hub **access token** (not the account password) as a
   *Username with password* credential with the ID `dockerhub-creds`.
2. Create a Pipeline job → *Pipeline script from SCM* → this repository →
   Script Path `Jenkinsfile`.
3. Update `IMAGE_NAME` in the `Jenkinsfile` to your own Docker Hub namespace.

## Manual deployment

Run on the Docker host after a successful build:

```bash
docker pull <dockerhub-username>/portfolio:latest
docker rm -f portfolio 2>/dev/null || true
docker run -d --name portfolio -p 8080:80 <dockerhub-username>/portfolio:latest
docker ps
curl -I http://localhost:8080
```

Then open `http://<server-ip>:8080` in a browser.

## Local preview without Jenkins

```bash
docker build -t portfolio:dev .
docker run --rm -p 8080:80 portfolio:dev
```
