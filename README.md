# Day 3 - Challenge 1
# LINUXtips-Giropops-Senhas Distroless with chainguard-images

This repository contain the project files to implement an application using a Dockerfile with chainguard for a distroless approach.

[Distroless](##distroless)

[Chainguard](##chainguard)

[Create Dockerfile](##create-dockerfile)

[Redis](##redis)

[Result](##result)

[Trivy](##trivy)

[Cosign](##cosign)

You can check the first example of this application in this repository [stheferrix/LINUXtips-Giropops-Senhas](https://github.com/stheferrix/LINUXtips-Giropops-Senhas) and can better understand how the application works.

Challenge steps do complete:

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

To run this application we need to keep in our minds use python images, because the application is develope in python.
Starting at this point we can find python images provide by chainguard: [python-chainguard](https://edu.chainguard.dev/chainguard/chainguard-images/reference/python/).
We have too types of images for python:

1. python:latest that contains minimal runtime image
1. python:latest-dev it is a variant that contains pip and a shell

Using the latest-dev version we we would overload the size with dependences that we not want.
The main idea is keep the image small as it is possible and the guide suggest to create a multistage image to enable use of pip to install the requirements at the same we can preserve the image size:

```
FROM cgr.dev/chainguard/python:latest-dev as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt --user

FROM cgr.dev/chainguard/python:latest
WORKDIR /app
# Make sure you update Python version in path
COPY --from=builder /home/nonroot/.local/lib/python3.12/site-packages /home/nonroot/.local/lib/python3.12/site-packages
COPY main.py .
ENTRYPOINT [ "python", "/app/main.py" ]
```

Modify our current image to fit the model suggested, we would have something like that:

```
FROM cgr.dev/chainguard/python:latest-dev as builder
WORKDIR /app
COPY ./giropops-senhas/requirements.txt .
RUN pip install -r requirements.txt

FROM cgr.dev/chainguard/python:latest
COPY ./giropops-senhas /app
WORKDIR /app
COPY --from=builder /home/nonroot/.local/lib/python3.12/site-packages /home/nonroot/.local/lib/python3.12/site-packages
EXPOSE 5000
ENV REDIS_HOST=172.17.0.2
ENV FLASK_APP=app.py

ENTRYPOINT ["flask", "run", "--host=0.0.0.0"]
```

However running the application that way, we got an error regarding the exec of flask.
That happens because we need using python to execute flask. 
If you change the entrypoint line to `ENTRYPOINT ["python", "flask", "run", "--host=0.0.0.0"]` will don't work. 
To solve this error seee the guide page of the image in [Details](https://edu.chainguard.dev/chainguard/chainguard-images/reference/python/image_specs/), there is indicating what you must to use in entrypoint to calls python, in this case `/usr/bin/python`.

So the final version of the docker image with the error fix is:

```
FROM cgr.dev/chainguard/python:latest-dev as builder
WORKDIR /app
COPY ./giropops-senhas/requirements.txt .
RUN pip install -r requirements.txt

FROM cgr.dev/chainguard/python:latest
COPY ./giropops-senhas /app
WORKDIR /app
COPY --from=builder /home/nonroot/.local/lib/python3.12/site-packages /home/nonroot/.local/lib/python3.12/site-packages
EXPOSE 5000
ENV REDIS_HOST=172.17.0.2
ENV FLASK_APP=app.py

ENTRYPOINT ["/usr/bin/python", "-m", "flask", "run", "--host=0.0.0.0"]
```

## Redis image

The application needs Redis has been running and following previously statement to run images with few vulnerabilities we will run Redis image by Chainguard too.
You can find the image and details [here](https://edu.chainguard.dev/chainguard/chainguard-images/reference/redis/).

But to summarize you just need execute the following steps:

1. Pull the image: `docker pull cgr.dev/chainguard/redis:latest`
1. Run the container: `docker run -d -p 6379:6379 --name redis cgr.dev/chainguard/redis`
1. If you want, check the ip address is the same that was indicate in the Dockerfile: `docker inspect redis`

## Result

### Create the Docker image:

`docker image build -t stheferri/linuxtips-giropops-senhas-distroless:1.0 .`

![image](https://github.com/stheferrix/LINUXtips-Giropops-Senhas-Distroless/blob/main/assets/create-image.PNG)

### Current size:

![size](https://github.com/stheferrix/LINUXtips-Giropops-Senhas-Distroless/blob/main/assets/size-image.PNG)

### Run container:

`docker run -d -p 5000:5000 --name giropops-senhas-distroless stheferri/linuxtips-giropops-senhas-distroless:1.0`

![container](https://github.com/stheferrix/LINUXtips-Giropops-Senhas-Distroless/blob/main/assets/run-container.PNG)

![container2](https://github.com/stheferrix/LINUXtips-Giropops-Senhas-Distroless/blob/main/assets/container-ls.PNG)

### Result:

![result](https://github.com/stheferrix/LINUXtips-Giropops-Senhas-Distroless/blob/main/assets/result.PNG)

### Push image to Dockerhub:

`docker push stheferri/linuxtips-giropops-senhas-distroless:1.0`

![dockerpush](https://github.com/stheferrix/LINUXtips-Giropops-Senhas-Distroless/blob/main/assets/docker-push.PNG)

![dockerhub](https://github.com/stheferrix/LINUXtips-Giropops-Senhas-Distroless/blob/main/assets/dockerhub.PNG)

## Trivy

Trivy is a comprehensive and versatile security scanner. Trivy has scanners that look for security issues, and targets where it can find those issues.

Reference [aquasecurity/trivy](https://github.com/aquasecurity/trivy)

Trivy will help to verify and check vulnerabilities in the image that we created and using in this process and we can see if using the chainguard images has some effect finally:

### Check vulnerabilities in image:

`trivy image stheferri/linuxtips-giropops-senhas-distroless:1.0`

![dockerpush](https://github.com/stheferrix/LINUXtips-Giropops-Senhas-Distroless/blob/main/assets/trivy-giropops.PNG)

`trivy image cgr.dev/chainguard/redis`

![dockerpush](https://github.com/stheferrix/LINUXtips-Giropops-Senhas-Distroless/blob/main/assets/trivy-redis.PNG)

## Cosign

Cosign verifies the authenticity of the image to ensure that the image has not been altered or compromised since it was signed.

Reference [cosign](https://docs.sigstore.dev/signing/quickstart/)

After installed generate a key-pair resulting in cosign.key and cosign.pub:

`cosign generate-key-pair`

To sign your image it must first be on dockerhub and then:

`cosign sign -key cosign.key stheferri/linuxtips-giropops-senhas-distroless:1.0`

To verify:

`cosign verify --key cosign.pub stheferri/linuxtips-giropops-senhas-distroless:1.0`

![cosign](https://github.com/stheferrix/LINUXtips-Giropops-Senhas-Distroless/blob/main/assets/cosign.PNG)


