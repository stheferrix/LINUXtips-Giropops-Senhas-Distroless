# Day 3 - Challenge 1
# LINUXtips-Giropops-Senhas Distroless with chainguard-images

This repository contain the project files to implement an application using a Dockerfile with chainguard for a distroless approach.

You can check the first example of this application in this repository [stheferrix/LINUXtips-Giropops-Senhas](https://github.com/stheferrix/LINUXtips-Giropops-Senhas) and can better understand how the application works.

1. Create a repository in Github
1. Create an Docker image to implement the application Giropops-Senhas using Chainguard images.
   The main goal is create an smallest image and with as few vulnerabilities as possible
1. Upload the image in Dockerhub
1. Upload the Dockerfile in Github
1. Test the image with Trivy
1. Sign the image with Cosign and update the Dockerhub image

## Distroless

"Distroless" images contain only your application and its runtime dependencies. They do not contain package managers, shells or any other programs you would expect to find in a standard Linux distribution.

Reference [GoogleContainerTools/distroless](https://github.com/GoogleContainerTools/distroless)

## Chainguard

Chainguard Images is a collection of container images designed for minimalism and security.
Many of these images are distroless; they contain only an application and its runtime dependencies. There is no shell or package manager.

Reference [chainguard-images](https://github.com/chainguard-images)

## Creating Dockerfile

First version
Fix Error
Final Version

## Redis image

## Result

## Trivy

## Cosign
