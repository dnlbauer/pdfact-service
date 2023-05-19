# pdfact-service
[![License](https://img.shields.io/github/license/dnlbauer/pdfact-service)](./LICENSE)
[![actions](https://github.com/dnlbauer/pdfact-service/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/dnlbauer/pdfact-service/actions)
[![Docker](https://img.shields.io/docker/pulls/dnlbauer/pdfact-service)](https://hub.docker.com/r/dnlbauer/pdfact-service/tags)

A Webservice to analyze the content of PDF Documents using a HTTP API. This is a simple HTTP wrapper around [ad-freiburg/pdfact](https://github.com/ad-freiburg/pdfact) and builds the container image directly from their source.

## Usage
Start the service:
```bash
> docker run -p 80:80 dnlbauer/pdfact-service

[2022-11-27 12:36:38 +0000] [1] [INFO] Starting gunicorn 20.1.0
[2022-11-27 12:36:38 +0000] [1] [INFO] Listening at: http://0.0.0.0:80 (1)
[2022-11-27 12:36:38 +0000] [1] [INFO] Using worker: gthread
[2022-11-27 12:36:38 +0000] [7] [INFO] Booting worker with pid: 7
```

PDFs can be `POST`ed to `/analyze` as multipart file request. The response will contain the output of `pdfact`. The response format can be specified using the correct MIME `Accept` header; `pdfact` van provide json, xml and plain text as output format.

```bash
> curl -H "Accept: application/json" -F file=@testfile.pdf localhost:80/analyze

{"paragraphs": [
  {"paragraph": {
    "role": "page-header",
    "positions": [{
      "minY": 642.6,
      "minX": 210.3,
      "maxY": 652.6,
      "maxX": 401.6,
      "page": 1
    }],
    "text": "This is a test PDF document."
  }},
  {"paragraph": {
    "role": "body",
    "positions": [{
      "minY": 628.5,
      "minX": 91.2,
      "maxY": 636.6,
      "maxX": 520.8,
      "page": 1
    }],
    "text": "If you can read this, you are lucky."
  }}
]}
```

Supported cli arguments (`--units`, `--roles`) can be supplied as http parameters. Example:
```bash
> curl ... localhost:80/analyze?roles=body&units=words
```

## Thanks
All credits go to the Algorithms and Data Structures Group from
University of Freiburg for [ad-freiburg/pdfact](https://github.com/ad-freiburg/pdfact).

## License
Published under CC0. Do whatever you want :-)

*(but also check the license of pdfact if you are going to use the image as is).*
